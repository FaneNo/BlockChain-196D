// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DonationPlatform {
    struct Campaign {
        string id;
        string title;
        string description;
        uint256 goalAmount;
        uint256 raisedAmount;
        address payable recipient;
        address organizer;
        bool isActive;
        uint256 verifierCount;
        mapping(address => bool) hasVerified;
    }

    mapping(string => Campaign) public campaigns;
    string[] public campaignIds;
    
    event CampaignCreated(string campaignId, string title, address organizer, address recipient);
    event DonationReceived(string campaignId, address donor, uint256 amount);
    event CampaignVerified(string campaignId, address verifier);
    event CampaignRemoved(string campaignId);

    modifier campaignExists(string memory _campaignId) {
        require(bytes(campaigns[_campaignId].id).length > 0, "Campaign does not exist");
        _;
    }

    modifier onlyCampaignOrganizer(string memory _campaignId) {
        require(campaigns[_campaignId].organizer == msg.sender, "Only the campaign organizer can call this function");
        _;
    }

    modifier notOrganizer(string memory _campaignId) {
        require(campaigns[_campaignId].organizer != msg.sender, "Campaign organizer cannot verify their own campaign");
        _;
    }

    modifier notRecipient(string memory _campaignId) {
        require(campaigns[_campaignId].recipient != msg.sender, "Recipient cannot verify their own campaign");
        _;
    }

    function createCampaign(
        string memory _id,
        string memory _title,
        string memory _description,
        uint256 _goalAmount,
        address payable _recipient
    ) public {
        require(bytes(_id).length > 0, "Campaign ID cannot be empty");
        require(bytes(campaigns[_id].id).length == 0, "Campaign ID already exists");
        require(_recipient != address(0), "Invalid recipient address");
        
        Campaign storage newCampaign = campaigns[_id];
        newCampaign.id = _id;
        newCampaign.title = _title;
        
        newCampaign.description = _description;
        newCampaign.goalAmount = _goalAmount;
        newCampaign.raisedAmount = 0;
        newCampaign.recipient = _recipient;
        newCampaign.organizer = msg.sender;
        newCampaign.isActive = true;
        newCampaign.verifierCount = 0;
        
        campaignIds.push(_id);
        
        emit CampaignCreated(_id, _title, msg.sender, _recipient);
    }

    function donate(string memory _campaignId) public payable campaignExists(_campaignId) {
        require(campaigns[_campaignId].isActive, "Campaign is not active");
        require(msg.value > 0, "Donation amount must be greater than 0");
        require(msg.value <= campaigns[_campaignId].goalAmount, "Donation amount cannot exceed the goal amount");
        require(msg.sender != address(0), "Invalid donor address"); 
        require(msg.sender != campaigns[_campaignId].recipient, "Donor cannot be the recipient"); 
        require(msg.sender != campaigns[_campaignId].organizer, "Donor cannot be the organizer"); 
        //require(!campaigns[_campaignId].hasVerified[msg.sender], "Donor cannot verify their own campaign");
        require(campaigns[_campaignId].raisedAmount + msg.value <= campaigns[_campaignId].goalAmount, "Donation cannot exceed the goal amount");
        require(campaigns[_campaignId].verifierCount >= 2, "Campaign must have at least two verified");

        
        campaigns[_campaignId].raisedAmount += msg.value;
        
        // Transfer funds directly to the recipient
        campaigns[_campaignId].recipient.transfer(msg.value);
        
        emit DonationReceived(_campaignId, msg.sender, msg.value);
    }

    function verifyCampaign(string memory _campaignId) 
        public 
        campaignExists(_campaignId)
        notOrganizer(_campaignId)
        notRecipient(_campaignId)
    {
        require(!campaigns[_campaignId].hasVerified[msg.sender], "You have already verified this campaign");

        campaigns[_campaignId].hasVerified[msg.sender] = true;

        campaigns[_campaignId].verifierCount++;
        
        emit CampaignVerified(_campaignId, msg.sender);
    }

    function removeCampaign(string memory _campaignId) 
        public 
        campaignExists(_campaignId)
        onlyCampaignOrganizer(_campaignId)
    {
        campaigns[_campaignId].isActive = false;
        
        emit CampaignRemoved(_campaignId);
    }

    // Getter functions
    function getCampaignCount() public view returns (uint256) {
        return campaignIds.length;
    }

    function getCampaignSummary(string memory _campaignId) 
        public 
        view 
        campaignExists(_campaignId)
        returns (
            string memory id,
            string memory title,
            string memory description,
            uint256 goalAmount,
            uint256 raisedAmount,
            address recipient,
            address organizer,
            bool isActive,
            uint256 verifierCount
        )
    {
        Campaign storage campaign = campaigns[_campaignId];
        return (
            campaign.id,
            campaign.title,
            campaign.description,
            campaign.goalAmount,
            campaign.raisedAmount,
            campaign.recipient,
            campaign.organizer,
            campaign.isActive,
            campaign.verifierCount
        );
    }

    function hasVerified(string memory _campaignId, address _verifier) 
        public 
        view 
        campaignExists(_campaignId)
        returns (bool)
    {
        return campaigns[_campaignId].hasVerified[_verifier];
    }
}
