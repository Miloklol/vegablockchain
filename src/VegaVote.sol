// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract VegaVote is ERC20, Ownable {
    constructor(uint256 initialSupply) ERC20("VegaVote", "VGV") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply);
    }
}