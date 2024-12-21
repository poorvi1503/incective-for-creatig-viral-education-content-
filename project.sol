// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VirtualStudyMeetup {
    
    struct Meetup {
        uint id;
        address organizer;
        string title;
        uint256 timestamp;
        uint reward;
        bool completed;
    }

    mapping(uint => Meetup) public meetups;
    uint public meetupCount;
    address public owner;
    mapping(address => uint) public balances;

    event MeetupCreated(
        uint id,
        address organizer,
        string title,
        uint256 timestamp,
        uint reward
    );

    event MeetupCompleted(
        uint id,
        address organizer,
        uint reward
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier onlyOrganizer(uint _id) {
        require(meetups[_id].organizer == msg.sender, "Only the organizer can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createMeetup(string memory _title, uint256 _timestamp, uint _reward) public {
        require(_timestamp > block.timestamp, "Timestamp must be in the future");
        require(_reward > 0, "Reward must be greater than 0");

        meetupCount++;
        meetups[meetupCount] = Meetup(meetupCount, msg.sender, _title, _timestamp, _reward, false);

        emit MeetupCreated(meetupCount, msg.sender, _title, _timestamp, _reward);
    }

    function completeMeetup(uint _id) public onlyOrganizer(_id) {
        Meetup storage meetup = meetups[_id];
        require(!meetup.completed, "Meetup already completed");
        require(block.timestamp >= meetup.timestamp, "Meetup time has not passed yet");

        meetup.completed = true;
        balances[meetup.organizer] += meetup.reward;

        emit MeetupCompleted(_id, meetup.organizer, meetup.reward);
    }

    function withdrawRewards() public {
        uint balance = balances[msg.sender];
        require(balance > 0, "No rewards to withdraw");
 
        balances[msg.sender] = 0; 
        payable(msg.sender).transfer(balance);
    }

    function fundContract() public payable onlyOwner {
        require(msg.value > 0, "Funding amount must be greater than 0");
    }

    function getMeetup(uint _id) public view returns (Meetup memory) {
        return meetups[_id];
    }

    fallback() external payable {}

    receive() external payable {}
}
  