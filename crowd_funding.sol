// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract croudFunding{

    mapping(address => uint) contributors;
    address public manager;
    uint public minimum;
    uint public deadline;
    uint public target;
    uint public raisedAnount;
    uint public no_ofContributors;

    struct Request{
        string desc;
        address payable recipient;
        uint value;
        bool completed;
        uint totalVoters;
        mapping(address => bool) voters;

    }

    mapping(uint => Request) requests;
    uint public totalRequest;

    constructor(uint _target , uint _deadline){
        target = _target;
        deadline = block.timestamp + _deadline;
        minimum = 1 ether;
        manager = msg.sender;
    }

    receive() external payable {}

    modifier onlyManager {
        require(msg.sender == manager);
        _;
    }

    modifier contributer {
        require(contributors[msg.sender] > 0);
        _;
    }

    function donate() public payable{

        require(block.timestamp < deadline , "time is over");
        require(msg.sender != manager, "manager can not donate");
        require(msg.value >= minimum, "can not donate below minimum");

        if(contributors[msg.sender]==0){
            no_ofContributors ++;
        }

        contributors[msg.sender] += msg.value;
        raisedAnount += msg.value;

    }

    function getContractBalance() view public returns(uint){
        return address(this).balance;
    }

    function refund() public contributer{

        require(raisedAnount < target && block.timestamp > deadline , "fund is raised successfully");
        // require(contributors[msg.sender] > 0 , "you are not a contributer");
        // (bool sent, bytes memory data) = payable(msg.sender).call{value: contributors[msg.sender]}("");
        payable(msg.sender).transfer(contributors[msg.sender]);
        contributors[msg.sender] = 0;

    }

    function createRequests(string memory _desc, address payable _recipient, uint _value) public onlyManager{

        // require(msg.sender == manager, "you are not a manager");
        Request storage newRequest = requests[totalRequest];
        totalRequest ++;
        newRequest.desc = _desc;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;

    }

    function voteRequest(uint _requestNo) public contributer{

        // require(contributors[msg.sender] > 0 , "you are not a contributer");
        Request storage newRequest = requests[_requestNo];
        require(newRequest.voters[msg.sender] == false , "you already voted");
        newRequest.voters[msg.sender] = true;
        newRequest.totalVoters ++;

    }

    function makePayment(uint _requestNo) public onlyManager{

        require(raisedAnount >= target , "target is not achevied");
        // require(msg.sender == manager, "you are not a manager");
        Request storage newRequest = requests[_requestNo];
        require(newRequest.completed == false , "payment already done");
        require(newRequest.totalVoters > no_ofContributors/2 , "not suppoted by the contributors");
        newRequest.recipient.transfer(newRequest.value);
        newRequest.completed = true;

    }

}