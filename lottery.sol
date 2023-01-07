// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Lottery{
    address public  manager;
    address payable[]  public players;

    constructor(){
        manager = msg.sender;
    }

    function alerady_enter() public view returns(bool){
        for(uint i =0 ; i< players.length ; i++){
            if(msg.sender == players[i]){
                return true;
            }
        }
        return false;
    }

    function enter() payable public {
        require(msg.sender != manager, "manager can not enter");
        require(alerady_enter() == false, "you already enter" );
        require(msg.value >= 1 ether, "entery fee is less than 1 ether");
        players.push(payable(msg.sender));
    }

    function random() public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,players)));
    }

    function pickwinner() public{
        require(msg.sender == manager, "you are not manager");
        uint index = random()%players.length; // winner index
        // address contractAddress = address(this);
        // players[index].transfer(contractAddress.balance);
        players[index].transfer(cont_bal());
        players = new address payable[](0);
    }

    function allplayers() public view returns( address payable[] memory){
        return players;
    }

    function cont_bal() public view returns(uint) {
        return address(this).balance;
    }

}