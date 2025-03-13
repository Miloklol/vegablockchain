// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract Voting is Ownable {
    IERC20 public vegatoken;
    uint256 public vote_cnt;
    uint256 public constant max_per = 4 * 365 days;

    struct Vote {
        uint256 id;
        string dscr;
        uint256 ddl;
        uint256 tr;
        uint256 t_pos;
        uint256 t_neg;
        bool active;
    }

    mapping(uint256 => Vote) public votes;
    mapping(address => uint256) public stacked;
    mapping(address => uint256) public periods;
    mapping(address => mapping(uint256 => bool)) public voted;

    event VoteCreated(uint256 id, string dscr, uint256 ddl, uint256 tr);
    event VoteCasted(uint256 id, address voter, bool vote);
    event VoteEnded(uint256 id, uint256 t_pos, uint256 t_neg);

    constructor(address _vegatoken) Ownable(msg.sender) {
        vegatoken = IERC20(_vegatoken);
    }

    function createVote(string memory dscr, uint256 ddl, uint256 tr) external onlyOwner {
        require(ddl > block.timestamp, "Deadline");
        votes[++vote_cnt] = Vote(vote_cnt, dscr, ddl, tr, 0, 0, true);
        emit VoteCreated(vote_cnt, dscr, ddl, tr);
    }

    function stakeTokens(uint256 amount, uint256 period) external {
        require(period <= max_per, "Too long");
        vegatoken.transferFrom(msg.sender, address(this), amount);
        stacked[msg.sender] += amount;
        periods[msg.sender] = period;
    }

    function castVote(uint256 voteId, bool vote) external {
        Vote storage v = votes[voteId];
        require(v.active, "Vnot active");
        require(block.timestamp <= v.ddl, "Deadline passed");
        require(!voted[msg.sender][voteId], "Already voted");

        uint256 votingPower = stacked[msg.sender] * periods[msg.sender] ** 2;
        if (vote) v.t_pos += votingPower;
        else v.t_neg += votingPower;

        voted[msg.sender][voteId] = true;
        emit VoteCasted(voteId, msg.sender, vote);

        if (v.t_pos >= v.tr || v.t_neg >= v.tr) _endVote(voteId);
    }

    function _endVote(uint256 voteId) internal {
        Vote storage v = votes[voteId];
        v.active = false;
        emit VoteEnded(voteId, v.t_pos, v.t_neg);
    }
}