// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SubscriptionManagement {
    address public owner; // Address of the contract owner

    struct Plan {
        uint256 id; // Unique identifier for the subscription plan
        string name; // Name of the subscription plan
        uint256 price; // Price of the subscription plan in wei
        uint256 duration; // Duration of the subscription plan in seconds
    }

    struct Subscriber {
        uint256 planId; // ID of the subscribed plan
        uint256 endTime; // Timestamp when the subscription ends
    }

    uint256 public planCount; // Counter for the number of subscription plans
    mapping(uint256 => Plan) public plans; // Mapping of plan IDs to Plan structs
    mapping(address => Subscriber) public subscribers; // Mapping of subscriber addresses to Subscriber structs

    event PlanCreated(uint256 id, string name, uint256 price, uint256 duration); // Event emitted when a new plan is created
    event Subscribed(address subscriber, uint256 planId, uint256 endTime); // Event emitted when a subscriber subscribes to a plan
    event Unsubscribed(address subscriber, uint256 planId); // Event emitted when a subscriber unsubscribes from a plan

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action"); // Restricts access to only the contract owner
        _;
    }

    modifier validPlanId(uint256 _planId) {
        require(_planId > 0 && _planId <= planCount, "Invalid plan ID"); // Ensures the plan ID is valid
        _;
    }

    constructor() {
        owner = msg.sender; // Sets the contract deployer as the initial owner
        planCount = 0; // Initializes planCount to zero
    }

    // Function to create a new subscription plan
    function createPlan(string memory _name, uint256 _price, uint256 _duration) public onlyOwner {
        require(bytes(_name).length > 0, "Plan name cannot be empty"); // Ensures the plan name is not empty
        require(_price > 0, "Plan price must be greater than zero"); // Ensures the plan price is greater than zero
        require(_duration > 0, "Plan duration must be greater than zero"); // Ensures the plan duration is greater than zero

        planCount++; // Increments the plan counter
        plans[planCount] = Plan(planCount, _name, _price, _duration); // Adds the new plan to the plans mapping

        emit PlanCreated(planCount, _name, _price, _duration); // Emits an event indicating a new plan has been created
    }

    // Function for a subscriber to subscribe to a plan
    function subscribe(uint256 _planId) public payable validPlanId(_planId) {
        Plan memory plan = plans[_planId]; // Retrieves the plan from the plans mapping
        require(msg.value == plan.price, "Incorrect payment amount"); // Ensures the subscriber pays the correct amount for the plan

        subscribers[msg.sender] = Subscriber(_planId, block.timestamp + plan.duration); // Records the subscriber and subscription end time

        emit Subscribed(msg.sender, _planId, block.timestamp + plan.duration); // Emits an event indicating a successful subscription
    }

    // Function for a subscriber to unsubscribe from their current plan
    function unsubscribe() public {
        require(subscribers[msg.sender].endTime > block.timestamp, "Subscription already expired or does not exist"); // Ensures the subscriber has an active subscription

        uint256 planId = subscribers[msg.sender].planId; // Retrieves the plan ID of the subscriber
        delete subscribers[msg.sender]; // Removes the subscriber's subscription record

        emit Unsubscribed(msg.sender, planId); // Emits an event indicating successful unsubscription
    }

    // Function to check the subscription status of a subscriber
    function getSubscriptionStatus(address _subscriber) public view returns (bool, uint256) {
        Subscriber memory subscriber = subscribers[_subscriber]; // Retrieves the subscription details of the subscriber

        if (subscriber.endTime > block.timestamp) {
            return (true, subscriber.endTime); // Returns true and the end time if the subscription is active
        } else {
            return (false, 0); // Returns false and 0 if the subscription is inactive or does not exist
        }
    }

    // Function for the contract owner to withdraw contract funds
    function withdrawFunds() public onlyOwner {
        payable(owner).transfer(address(this).balance); // Transfers the contract balance to the owner
    }
}
