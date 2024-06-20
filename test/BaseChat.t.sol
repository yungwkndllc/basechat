// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {BaseChat} from "../src/BaseChat.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ArbetTest is Test {
    BaseChat public basechat;

    address yungwknd = 0x6140F00e4Ff3936702E68744f2b5978885464cbB;
    address yungwknd2 = 0x6140F00E4Ff3936702e68744f2b5978885464CBc;

    function setUp() public {
        vm.startPrank(yungwknd);
        basechat = new BaseChat();

        vm.deal(yungwknd, 100 ether);
        vm.deal(yungwknd2, 100 ether);
        vm.stopPrank();
    }

    function testChat() public {
        vm.startPrank(yungwknd);
        vm.warp(25 hours);
        // Send a message!
        basechat.chat("Hello, world!");

        // Get the messages
        BaseChat.Message[] memory messages = basechat.getMessages();
        assertEq(messages.length, 1);
        assertEq(messages[0].message, "Hello, world!");
        assertEq(messages[0].sender, yungwknd);

        // Warp forward 10 hours
        vm.warp(block.timestamp + 10 hours);

        // Send another message!
        basechat.chat("Hello, world2");

        // Should be 2 messages
        messages = basechat.getMessages();
        assertEq(messages.length, 2);
        assertEq(messages[0].message, "Hello, world!");
        assertEq(messages[1].message, "Hello, world2");

        // Warp forward 15 more hours
        vm.warp(block.timestamp + 15 hours);

        // Should only be 1 message left
        messages = basechat.getMessages();
        assertEq(messages.length, 1);

        // Should be the 2nd one
        assertEq(messages[0].message, "Hello, world2");

        // Send another message
        basechat.chat("Hello, world3");

        // Should be 2 messages
        messages = basechat.getMessages();
        assertEq(messages.length, 2);
        assertEq(messages[0].message, "Hello, world2");
        assertEq(messages[1].message, "Hello, world3");

        vm.stopPrank();
    }
}
