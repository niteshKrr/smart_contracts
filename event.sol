// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract EventContract{

    struct Event{

        address organiser;
        uint date;
        string name;
        uint price;
        uint totalTicket;
        uint ticketRemaining;

    }

    mapping(uint => Event) events;
    mapping(address=>mapping(uint=>uint)) public tickets;
    uint public nextId;

    function createEvent(string memory _name, uint _date, uint _price, uint _totalTicket) public{

        require(_date > block.timestamp, "enter a valid date");
        require(_totalTicket > 0, "minimum no of ticket is required");
        Event storage newEvent = events[nextId];
        newEvent.name = _name;
        newEvent.date = _date;
        newEvent.price = _price;
        newEvent.totalTicket = _totalTicket;
        newEvent.ticketRemaining = _totalTicket;
        nextId ++;

    }


    function buyTicket(uint _id, uint _quantity) public payable{

        require(events[_id].date != 0, "No such event found");
        require(events[_id].date > block.timestamp , "No such event found");

        Event storage newEvent = events[_id];
        require(newEvent.ticketRemaining >= _quantity , "insufficient ticket");
        require(msg.value == (newEvent.price * _quantity) , "insufficient balance for ticket");
        newEvent.ticketRemaining -= _quantity;

        tickets[msg.sender][_id] += _quantity;

    }

    function transferTicket(uint _id, uint _quantity, address _to) public{

        require(events[_id].date != 0, "No such event found");
        require(events[_id].date > block.timestamp , "No such event found");
        require(tickets[msg.sender][_id] >= _quantity, "you have not enough ticket" );

        tickets[msg.sender][_id] -= _quantity;
        tickets[_to][_id] += _quantity;

    }

}