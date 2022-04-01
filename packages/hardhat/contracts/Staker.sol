// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    mapping(address => uint256) public balances;
    uint256 public constant threshold = 1 ether;
    uint256 public deadline = block.timestamp + 72 hours;
    bool public openForWithdraw = false;
    mapping(string => bool) private executeCall;
    event Stake(address indexed addr, uint256 amount);

    constructor(address exampleExternalContractAddress) public {
        executeCall["call"] = false;
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

    function stake() public payable {
        require(
            executeCall["call"] == false,
            "Execute has already been called, staking is over"
        );
        require(msg.value > 0, "Insufficient Ether provided");

        balances[msg.sender] = balances[msg.sender] + msg.value;
        emit Stake(msg.sender, msg.value);
    }

    // After some `deadline` allow anyone to call an `execute()` function
    //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
    function execute() external {
        require(block.timestamp > deadline, "Deadline is not over");
        if (block.timestamp > deadline) {
            require(
                executeCall["call"] == false,
                "Execute has already been called"
            );
            executeCall["call"] = true;
            if (address(this).balance > threshold) {
                exampleExternalContract.complete{
                    value: address(this).balance
                }();
            } else {
                openForWithdraw = true;
            }
        }
    }

    // if the `threshold` was not met, allow everyone to call a `withdraw()` function

    // Add a `withdraw()` function to let users withdraw their balance
    function withdraw() external {
        require(openForWithdraw == true, "wallet not open for withdraw");
        require(
            balances[msg.sender] > 0,
            "You do not have a stake to withdraw"
        );
        (bool success, ) = msg.sender.call{value: balances[msg.sender]}("");
        require(success, "Failed to withdraw money");
        balances[msg.sender] = 0;
    }

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        } else {
            return deadline - block.timestamp;
        }
    }

    // Add the `receive()` special function that receives eth and calls stake()
    // Function to receive Ether. msg.data must be empty
    receive() external payable {
        stake();
    }
}
