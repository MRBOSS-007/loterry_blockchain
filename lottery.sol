// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
    address public manager;
    address[] public participants;
    address public winner;
    uint256 public managerFee ;

    constructor() {
        manager = msg.sender;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Only the manager can call this function.");
        _;
    }

    modifier minimumParticipants(uint minParticipants) {
        require(participants.length >= minParticipants, "Not enough participants to select a winner.");
        _;
    }

    function enter() external payable {
        require(msg.value == 2 ether, "Entry fee is 2 ether.");
        participants.push(msg.sender);
    }

    function getBalance() view public  onlyManager returns(uint) {
        return address(this).balance;
    }

    function random() private view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, participants.length, blockhash(block.number - 1))));
    }

    function selectWinner() public onlyManager minimumParticipants(3) {
        uint index = random() % participants.length;
        winner = participants[index];
    }

    function transferFunds() public onlyManager {
         uint totalbalance = address(this).balance;
         require(winner != address(0), "No winner selected yet.");
        require(totalbalance > 0, "No funds to transfer.");
        uint totalBalance = address(this).balance;
        uint winnerPrize = (totalBalance * 90) / 100; // 90% to the winner
        uint managerPrize = (totalBalance * 10) / 100 + managerFee; // 10% to the manager

        payable(winner).transfer(winnerPrize);
        payable(manager).transfer(managerPrize);

        managerFee = 0; // Reset manager's fee
        winner = address(0); // Reset the winner
    }
}
