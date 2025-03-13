// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "lib/forge-std/src/Test.sol";
import "src/Voting.sol";
import "src/VegaVote.sol";

contract VotingTest is Test {
    Voting public voting;
    VegaVote public vegatoken;
    address public admin = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address public u1 = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
    address public u2 = address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);

    function setUp() public {
        vegatoken = new VegaVote(1000000 * 10 ** 18);

        voting = new Voting(address(vegatoken));

        vm.prank(voting.owner());
        voting.transferOwnership(admin);

        vegatoken.transfer(u1, 1000 * 10 ** 18);
        vegatoken.transfer(u2, 1000 * 10 ** 18);
    }

    function testStakeTokens() public {
        vm.prank(u1);
        vegatoken.approve(address(voting), 500 * 10 ** 18);

        vm.prank(u1);
        voting.stakeTokens(500 * 10 ** 18, 2 * 365 days);

        assertEq(voting.stacked(u1), 500 * 10 ** 18);
        assertEq(voting.periods(u1), 2 * 365 days);
    }

    function testCastVote() public {
        vm.prank(admin);
        voting.createVote("new bridge", block.timestamp + 1 days, 1000);

        vm.prank(u1);
        vegatoken.approve(address(voting), 500 * 10 ** 18);
        vm.prank(u1);
        voting.stakeTokens(500 * 10 ** 18, 2 * 365 days);

        vm.prank(u1);
        voting.castVote(1, true);

        (,,, uint256 thl, uint256 t_pos, uint256 t_neg,) = voting.votes(1);
        assertEq(t_pos, 500 * 10 ** 18 * (2 * 365 days) ** 2);
        assertEq(t_neg, 0);
    }

    function testEndVote() public {
        vm.prank(admin);
        voting.createVote("new bridge", block.timestamp + 1 days, 1000);

        vm.prank(u1);
        vegatoken.approve(address(voting), 500 * 10 ** 18);
        vm.prank(u1);
        voting.stakeTokens(500 * 10 ** 18, 2 * 365 days);

        vm.prank(u1);
        voting.castVote(1, true);

        (,,,,,, bool active) = voting.votes(1);
        assertEq(active, false);

    }
}