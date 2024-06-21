# Decentralised_Subscription_Management_System

This Solidity program is a decentralized subscription management system that allows service providers to create subscription plans and manage subscribers. It demonstrates the advanced syntax and functionality of the Solidity programming language, and serves as a practical example for those who are familiar with Solidity and want to develop more complex smart contracts.

## Description

This project is a Solidity contract that implements a decentralized subscription management system on the Ethereum blockchain. The contract allows the owner to create subscription plans, users can subscribe to these plans by paying the specified price, and it manages subscription duration and payments in a decentralized manner. This project serves as a comprehensive introduction to building decentralized applications (dApps) with Solidity, and can be used as a foundation for more complex projects in the future.

## Getting Started

### Executing Program

To run this program, you can use Remix, an online Solidity IDE. Follow these steps:

1. **Visit Remix**: Go to the Remix website at [Remix Ethereum](https://remix.ethereum.org/).

2. **Create a New File**: Click on the "+" icon in the left-hand sidebar to create a new file. Save the file with a `.sol` extension (e.g., `SubscriptionManagement.sol`). Copy and paste the following code into the file:

    ```solidity
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

    ```

3. **Compile the Code**: Click on the "Solidity Compiler" tab in the left-hand sidebar. Ensure the "Compiler" option is set to `0.8.18` (or another compatible version), and then click on the "Compile SubscriptionManagement.sol" button.

4. **Deploy the Contract**: Click on the "Deploy & Run Transactions" tab in the left-hand sidebar. Select the `SubscriptionManagement` contract from the dropdown menu, and then click on the "Deploy" button.

5. **Interact with the Contract**: Once the contract is deployed, you can interact with it by creating subscription plans, subscribing to plans, checking subscription statuses, unsubscribing, and withdrawing funds. Follow these steps:

   - **Create a Subscription Plan**:
     - Locate the `createPlan` function.
     - Input the plan details (e.g., `"Basic Plan"`, `1000000000000000000` for 1 ETH in wei, `604800` for one week in seconds).
     - Click "transact" to create the plan.

   - **Subscribe to a Plan**:
     - Locate the `subscribe` function.
     - Input the plan ID (`1` if it's the first plan created).
     - Input the exact price of the plan in the "Value" field above the function.
     - Click "transact" to subscribe to the plan.

   - **Check Subscription Status**:
     - Locate the `getSubscriptionStatus` function.
     - Input your address (e.g., `msg.sender`).
     - Click "call" to check if you are subscribed and get the subscription end time.

   - **Unsubscribe from a Plan**:
     - Locate the `unsubscribe` function.
     - Click "transact" to unsubscribe from the current plan.

   - **Withdraw Funds**:
     - Ensure you have some Ether in the contract balance (from subscriptions).
     - Locate the `withdrawFunds` function.
     - Click "transact" to transfer the contract balance to the owner's address.

## Authors

Metacrafter Vanshit Aggarwal  
@VanshitAggarwal

## License

This project is licensed under the MIT License - see the [License.md](License.md) file for details.
