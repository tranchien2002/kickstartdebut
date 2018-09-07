pragma solidity ^0.4.21;

contract Campaign {
    address public owner;
    address[] public donators;
    mapping(address => uint) donations;
    constructor(address _owner) public {
        owner = _owner;
    }
    
    function donate() public payable {
        require(msg.value > 0);
        if(isDonator(msg.sender)) {
            donations[msg.sender] += msg.value;
        } else {
            donators.push(msg.sender);
            donations[msg.sender] = msg.value;
        }
    }
    
    function isDonator(address who) internal view returns(bool) {
        if (who != 0x0 && donations[who] > 0) {
            return true;
        }
        return false;
    }
    
    function withdraw() public {
        require(msg.sender == owner);
        owner.transfer(address(this).balance);
    }
    
    function balanceCampaign() view public returns(uint) {
        return address(this).balance;
    }
    
    function() payable public {}
}