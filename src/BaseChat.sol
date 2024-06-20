// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// @author: yungwknd

import "@openzeppelin/contracts/utils/structs/DoubleEndedQueue.sol";

// 💬
contract BaseChat {
    using DoubleEndedQueue for DoubleEndedQueue.Bytes32Deque;

    struct Message {
        string message;
        address sender;
        uint timestamp;
    }

    DoubleEndedQueue.Bytes32Deque queue;
    mapping(bytes32 => Message) private messagesMap;

    function chat(string memory message) public {
        Message memory userMessage = Message({
            message: message,
            sender: msg.sender,
            timestamp: block.timestamp
        });
        bytes32 messageId = keccak256(abi.encode(userMessage));
        messagesMap[messageId] = userMessage;
        queue.pushBack(messageId);

        // Remove all messages with timestamp older than 24 hours
        bool upToDate = false;
        while (!upToDate) {
            // Check the first message
            bytes32 messageIdToRemove = queue.at(0);
            upToDate = true;
            // Decode the message
            Message memory oldestMessage = messagesMap[messageIdToRemove];

            // If the message is older than 24 hours, remove it
            if (oldestMessage.timestamp < block.timestamp - 24 hours) {
                queue.popFront();
                delete messagesMap[messageIdToRemove];
            } else {
                upToDate = true;
            }
        }
    }

    function getMessages() public view returns (Message[] memory) {
        uint256 queueLength = queue.length();

        uint numberOfValidMessages = queueLength;
        for (uint256 i = 0; i < queueLength; i++) {
            bytes32 messageId = queue.at(i);
            Message memory message = messagesMap[messageId];
            if (message.timestamp < block.timestamp - 24 hours) {
                numberOfValidMessages--;
                continue;
            }
            break;
        }

        Message[] memory messages = new Message[](numberOfValidMessages);

        uint invalidMessages = queueLength - numberOfValidMessages;
        for (uint256 i = invalidMessages; i < queueLength; i++) {
            bytes32 messageId = queue.at(i);
            messages[i - invalidMessages] = messagesMap[messageId];
        }

        return messages;
    }
}
