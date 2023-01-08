// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Auction{

    address payable public auctioneer;

    uint public st_time;
    uint public ed_time;

    enum Auc_state{started, running, ended, canceled}

    Auc_state public auctionState;

    // uint public heigestBid;
    uint public heighestPayableBid;
    uint public bidInc;

    address payable public heigestBidder;

    mapping(address => uint) public  bids;

    constructor(){
        auctioneer = payable(msg.sender);
        auctionState = Auc_state.started;
        st_time = block.number;
        ed_time = st_time + 240;
        bidInc = 1 ether;
    }


    modifier notOwner(){
        require(msg.sender != auctioneer, "you are owner");
        _;
    }

    modifier Owner(){
        require(msg.sender == auctioneer, "you are not a owner");
        _;
    }

    modifier started(){
        require(block.number > st_time, "auction not started yet");
        _;
    }

    modifier beforeEnded(){
        require(block.number <= ed_time, "aucion is ended");
        _;
    }

    function min(uint _a , uint _b) private pure returns(uint){
        if(_a < _b){
            return _a;
        }
        else{
            return _b;
        }
    }

    function auctionCancel() public Owner{
        auctionState = Auc_state.canceled;
    }

    function bid() public payable notOwner started beforeEnded{

        require(auctionState == Auc_state.running, "auction is cancel or ended" );
        require(msg.value >= 1 ether, "pay ether for bid");

        uint currentBid = bids[msg.sender] + msg.value;
        require(currentBid > heighestPayableBid , "add more ether for bid" );
        bids[msg.sender] = currentBid;

        if(currentBid < bids[heigestBidder]){
            heighestPayableBid = min(currentBid , bids[heigestBidder]);
        }
        else{
            heighestPayableBid = min(currentBid , bids[heigestBidder]+bidInc);
        }

        heigestBidder = payable(msg.sender);

    }

    function finalizeAuc() public {
        require(auctionState == Auc_state.canceled || block.number > ed_time);
        require(msg.sender == auctioneer || bids[msg.sender] > 0);

        address payable person;
        uint value;

        if(auctionState == Auc_state.canceled){
            person = payable(msg.sender);
            value = bids[msg.sender];
        }
        else{

            if(msg.sender == auctioneer){
                person = auctioneer;
                value = heighestPayableBid;
            }
            else{

                if(msg.sender == heigestBidder){
                    person = heigestBidder;
                    value = bids[heigestBidder] - heighestPayableBid;
                }
                else{
                    person = payable(msg.sender);
                    value = bids[msg.sender];
                }
            }
        }

        bids[msg.sender] = 0;
        person.transfer(value);
    }



}