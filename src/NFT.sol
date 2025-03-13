// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract VotingNFT is ERC721, Ownable {
    uint256 public cnt;

    constructor() ERC721("VotingNFT", "VNFT") Ownable(msg.sender) {}

    function mint(address to, string memory uri) external onlyOwner {
        cnt++;
        _safeMint(to, cnt);
    }
}