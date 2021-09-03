pragma solidity ^0.8.7;

contract Inbox {
    string public message;

    constructor(string storage initialMessage) public {
        message = initialMessage;
    }

    function setMessage(string storage newMessage) public {
        message = newMessage;
    }
}