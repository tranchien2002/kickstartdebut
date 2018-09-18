pragma solidity ^0.4.21;

contract Campaign {
    address public owner;
    uint public fundCall;
    uint public timeLock;
    address[] public contributors;
    mapping(address => uint) public contributions;
    mapping(address => bool) public approvers;
    uint public approversCount;
    event NewCampaign(address owner, uint fundCall, uint timeLock);
    
    struct Request {
        uint value;
        address recipient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;
    }
    Request[] public requests;
    uint public minimumContribution;
    
    constructor(address _owner, uint _fundCall, uint _timeLock, uint _minimumContribution) public {
        require(_fundCall != 0 && _timeLock != 0 && _minimumContribution != 0);
        owner = _owner;
        fundCall = _fundCall * 1 wei;
        timeLock = now + _timeLock * 1 seconds;
        minimumContribution = _minimumContribution;
        emit NewCampaign(_owner, _fundCall, _timeLock);
    }
    
    function contribute() public payable {
        require(msg.value > 0);
        require(now < timeLock);
        if(!isContributor(msg.sender)) {
            contributors.push(msg.sender);
        }
        if((contributions[msg.sender] + msg.value) >= minimumContribution) {
            approvers[msg.sender] = true;    
            approversCount++;
        }
        contributions[msg.sender] += msg.value;
        
    }
    
    function isContributor(address who) internal view returns(bool) {
        if (who != 0x0 && contributions[who] > 0) {
            return true;
        }
        return false;
    }
    
    function getAllContributors() public view returns(address[]) {
        return contributors;
    }
    
    function currentBalance() public view returns(uint) {
        return address(this).balance;
    }
    
    function refund() public {
        require(now >= timeLock && address(this).balance < fundCall, "Not eligible");
        require(isContributor(msg.sender), "You have not contributed yet");
        msg.sender.transfer(contributions[msg.sender]);
        contributions[msg.sender] = 0;
    }
    
    function createRequest(uint _value, address _recipient) public _onlyOnwner _exceedBalance(_value) _enoughFund {
        Request memory newRequest = Request({
            value: _value,
            recipient: _recipient,
            complete: false,
            approvalCount: 0
        });
        requests.push(newRequest);
    }
    
    function approveRequest(uint index) public {
        Request storage request = requests[index];
        require(approvers[msg.sender]);
        require(!request.approvals[msg.sender]);
        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }
    
    function completeRequest(uint index) public {
        Request storage request = requests[index];
        
        require(request.approvalCount > (approversCount / 2), "Not enough votes");
        require(!request.complete);
        
        request.recipient.transfer(request.value);
        request.complete = true;
    }
    
    function getRequestsCount() public view returns (uint) {
        return requests.length;
    }
    
    modifier _exceedBalance(uint _value){
        require(_value <= address(this).balance, "Out of balance");
        _;
    }
    
    modifier _onlyOnwner(){
        require(msg.sender == owner, "Only owner can do");
        _;
    }
    
    modifier _campaignExpired() {
        require(now >= timeLock, "Must enough time");
        _;
    }
    
    modifier _enoughFund() {
        require(address(this).balance >= fundCall, "Must enough fundCall");
        _;
    }
    
}
