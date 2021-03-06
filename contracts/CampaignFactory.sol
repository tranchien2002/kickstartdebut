pragma solidity ^0.4.21;
import "./Campaign.sol";

contract CampaignFactory {
    address[] public campaigns;
    mapping(address => bool) verifyCampaigns;
    function createCampaign(uint _fundCall, uint _timeLock, uint _minimumContribution) public returns(address){
        address campaign = address(new Campaign(msg.sender, _fundCall, _timeLock, _minimumContribution));
        campaigns.push(campaign);
        return campaign;
    }
    
    function getAllCampaigns() view public returns (address[]) {
        return campaigns;
    }

    function checkCampaign(address _campaignAddress) view public returns (bool) {
        return verifyCampaigns[_campaignAddress];
    }
    
    function() payable public {}
}
