// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract SubscriptionManagement {
    address public owner;

    struct Plan {
        uint256 id;
        string name;
        uint256 price; // in wei
        uint256 duration; // in seconds
    }

    struct Subscriber {
        uint256 planId;
        uint256 endTime;
    }

    uint256 public planCount;
    mapping(uint256 => Plan) public plans;
    mapping(address => Subscriber) public subscribers;

    event PlanCreated(uint256 id, string name, uint256 price, uint256 duration);
    event Subscribed(address subscriber, uint256 planId, uint256 endTime);
    event Unsubscribed(address subscriber, uint256 planId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier validPlanId(uint256 _planId) {
        require(_planId > 0 && _planId <= planCount, "Invalid plan ID");
        _;
    }

    constructor() {
        owner = msg.sender;
        planCount = 0;
    }

    // Function to create a new subscription plan
    function createPlan(string memory _name, uint256 _price, uint256 _duration) public onlyOwner {
        require(bytes(_name).length > 0, "Plan name cannot be empty");
        require(_price > 0, "Plan price must be greater than zero");
        require(_duration > 0, "Plan duration must be greater than zero");

        planCount++;
        plans[planCount] = Plan(planCount, _name, _price, _duration);

        emit PlanCreated(planCount, _name, _price, _duration);
    }

    // Function for a subscriber to subscribe to a plan
    function subscribe(uint256 _planId) public payable validPlanId(_planId) {
        Plan memory plan = plans[_planId];
        require(msg.value == plan.price, "Incorrect payment amount");

        // Check if the user is already subscribed
        if (subscribers[msg.sender].endTime > block.timestamp) {
            revert("Already subscribed to a plan");
        }

        subscribers[msg.sender] = Subscriber(_planId, block.timestamp + plan.duration);

        emit Subscribed(msg.sender, _planId, block.timestamp + plan.duration);

        // Assert to ensure the subscription was recorded correctly
        assert(subscribers[msg.sender].planId == _planId);
        assert(subscribers[msg.sender].endTime == block.timestamp + plan.duration);
    }

    // Function for a subscriber to unsubscribe from their current plan
    function unsubscribe() public {
        require(subscribers[msg.sender].endTime > block.timestamp, "Subscription already expired or does not exist");

        uint256 planId = subscribers[msg.sender].planId;
        delete subscribers[msg.sender];

        emit Unsubscribed(msg.sender, planId);

        // Assert to ensure the subscriber's record was deleted
        assert(subscribers[msg.sender].planId == 0);
        assert(subscribers[msg.sender].endTime == 0);
    }

    // Function to check the subscription status of a subscriber
    function getSubscriptionStatus(address _subscriber) public view returns (bool, uint256) {
        Subscriber memory subscriber = subscribers[_subscriber];
        if (subscriber.endTime > block.timestamp) {
            return (true, subscriber.endTime);
        } else {
            return (false, 0);
        }
    }

    // Function for the contract owner to withdraw contract funds
    function withdrawFunds() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        payable(owner).transfer(balance);

        // Assert to ensure the contract balance is zero after withdrawal
        assert(address(this).balance == 0);
    }
}
