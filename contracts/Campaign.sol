pragma solidity ^0.4.21;

contract Campaign {
    address public owner;
    uint public fundCall;
    uint public remainingFund;
    uint public timeLock;
    address[] public contributors;
    mapping(address => uint) public contributions;
    mapping(address => bool) public approvers;
    uint public approversCount;
    event NewCampaign(address owner, uint fundCall, uint timeLock);
    bool complete = false;
    
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

    /*
        Contribute to campaign
        Contribution must be greater than 0
        Current time must before expired time
        Address becomes contributor of campaign 
        If total contribution greater than minimumContribution, address become approver for request receive fund when campaign is successful
     */
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
        if(address(this).balance >= fundCall){
            complete = true;
            remainingFund = address(this).balance;    
        } 
    }
    /*
        Check address has donated and address is not locked address(0x0)
     */
    function isContributor(address who) internal view returns(bool) {
        if (who != 0x0 && contributions[who] > 0) {
            return true;
        }
        return false;
    }
    

    /*
        Get list address of contributors
    */
    function getAllContributors() public view returns(address[]) {
        return contributors;
    }

    /*
        Get current balance of campaign  
     */    
    function currentBalance() public view returns(uint) {
        return address(this).balance;
    }
    

    /*
        Refund contribution for contributor when campaign is unsuccessful
        Current time must be less than expiry time
        Current balance must be less than fundCall
        Address is must be contributor and has not withdrawn 
     */
    function refund() public {
        require(now >= timeLock && address(this).balance < fundCall, "Not eligible");
        require(isContributor(msg.sender), "You have not contributed yet");
        msg.sender.transfer(contributions[msg.sender]);
        contributions[msg.sender] = 0;
    }
    

    /*
        Create request to withdraw money
        Only owner of campaign can create request to withraw money
     */
    function createRequest(uint _value, address _recipient) public _onlyOnwner _exceedBalance(_value) _enoughFund _finalRequestDone{
        Request memory newRequest = Request({
            value: _value,
            recipient: _recipient,
            complete: false,
            approvalCount: 0
        });
        requests.push(newRequest);
    }
    
    /*
        Donator approve request to withraw of campaign's owner
        Donator has one occasion to vote 
     */
    function approveRequest(uint index) public {
        Request storage request = requests[index];
        require(approvers[msg.sender], "Caller must be a approver");
        require(!request.approvals[msg.sender], "Approver has already voted");
        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }
    
    /*
        Owner can cancel request
        Request must be uncomplete 
    */
    function cancelRequest(uint index) public _onlyOnwner{
        Request storage request = requests[index];
        require(!request.complete, "Request has already completed");
        request.complete = true;
    }

    /*
        Owner withdraw when request is successful
        Request must be uncomplete
        Request must be successful voting
     */
    function withdrawRequest(uint index) public _onlyOnwner{
        Request storage request = requests[index];
        
        require(request.approvalCount > (approversCount / 2), "Not enough votes");
        require(!request.complete, "Request has already completed");

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
        require(complete, "Must enough fundCall");
        _;
    }
    
    modifier _finalRequestDone() {
        uint finalRequest = requests.length - 1;
        require(requests[finalRequest].complete, "Final request must be done before create new request");
        _;
    }
}
