pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
    uint256 public constant tokensPerEth = 100;

    YourToken public yourToken;

    constructor(address tokenAddress) {
        yourToken = YourToken(tokenAddress);
    }

    // ToDo: create a payable buyTokens() function:
    function buyTokens() external payable {
        require(msg.value > 0, "Insufficient Ether provided");

        uint256 tokens = tokensPerEth * msg.value;
        yourToken.transfer(msg.sender, tokens);
        emit BuyTokens(msg.sender, msg.value, tokens);
    }

    // ToDo: create a withdraw() function that lets the owner withdraw ETH
    function withdraw() public onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Failed to withdraw money");
    }

    // ToDo: create a sellTokens() function:
    function sellTokens(uint256 amount) public {
        yourToken.transferFrom(msg.sender, address(this), amount);

        uint256 ethAmount = (amount / tokensPerEth);

        (bool success, ) = msg.sender.call{value: ethAmount}("");
    }
}
