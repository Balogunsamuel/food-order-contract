//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {FoodOrder} from "../src/FoodOrder.sol";
import {DeployFoodOrder} from "../script/DeployFoodOrder.s.sol";

contract FoodOrderTest is Test {
    FoodOrder foodOrder;

    uint256 public constant SEND_VALUE = 0.1 ether;
    address USER = makeAddr("user");
    uint256 public constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFoodOrder deployer = new DeployFoodOrder();
        foodOrder = deployer.run();

        vm.deal(USER, STARTING_BALANCE);
    }

    function testGetOwner() public {
        assertEq(foodOrder.getOwner(), msg.sender);
    }

    function testSendOrder() public {
        // Simulate customer sending an order
        string memory foodMenu = "Burger";
        uint256 quantity = 2;

        // Send the order
        vm.prank(USER);
        foodOrder.sendOrder(foodMenu, quantity);

        // Fetch and verify the order details
        (
            ,
            string memory fetchedFoodMenu,
            uint256 fetchedQuantity,
            ,

        ) = foodOrder.checkOrder(1);

        assertEq(fetchedFoodMenu, foodMenu, "Food menu should match");
        assertEq(fetchedQuantity, quantity, "Quantity should match");
    }

    function testRevertsIfChecksOrdersFails() public {
        vm.prank(USER);
        vm.expectRevert(
            FoodOrder.FoodOrder__ThisSpecficOrderDoesNotExist.selector
        );
        foodOrder.checkOrder(0);
    }

    function testRevertsIfSendPriceIsNotOwner() public {
        uint256 orderNo = 1;
        uint256 quantity = 2;

        vm.prank(USER);
        vm.expectRevert(FoodOrder.FoodOrder__OnlyTheOwnerCanDoThis.selector);
        foodOrder.sendPrice(orderNo, quantity);
    }

    function testSendPrice() public {
        // Simulate owner sending a price
        uint256 orderNo = 1;
        uint256 price = 100;
        string memory foodMenu = "Burger";
        uint256 quantity = 2;

        vm.prank(USER);
        foodOrder.sendOrder(foodMenu, quantity);

        // Send the price
        vm.prank(msg.sender);
        foodOrder.sendPrice(orderNo, price);

        // Fetch and verify the price
        uint256 fetchedPrice = foodOrder.getPrice(orderNo);

        assertEq(fetchedPrice, price, "Price should match");
    }

    function testSendSafepayment() public payable {
        // Simulate customer sending a safe payment
        uint256 orderNo = 1;
        uint256 price = 100;
        string memory foodMenu = "Burger";
        uint256 quantity = 2;
        uint256 paymentAmount = 150;

        // send the order
        vm.prank(USER);
        foodOrder.sendOrder(foodMenu, quantity);

        // Send the price
        vm.prank(msg.sender);
        foodOrder.sendPrice(orderNo, price);

        // Send the safe payment
        foodOrder.sendSafepayment{value: paymentAmount}(orderNo);

        // Fetch and verify the safe payment amount
        (, , , , uint256 fetchedSafePayment) = foodOrder.checkOrder(orderNo);

        assertEq(
            fetchedSafePayment,
            paymentAmount,
            "Safe payment should match"
        );
    }

    function testRevertsOnlyOwnerCanSendInvoice() public {
        // Simulate customer sending a safe payment
        uint256 orderNo = 1;
        uint256 price = 100;
        string memory foodMenu = "Burger";
        uint256 quantity = 2;
        uint256 paymentAmount = 150;

        // send the order
        vm.prank(USER);
        foodOrder.sendOrder(foodMenu, quantity);

        // Send the price
        vm.prank(msg.sender);
        foodOrder.sendPrice(orderNo, price);

        // Send the safe payment
        foodOrder.sendSafepayment{value: paymentAmount}(orderNo);

        // Simulate owner sending an invoice
        uint256 invoiceDate = block.timestamp;

        // Send the invoice
        vm.prank(USER);
        vm.expectRevert();
        foodOrder.sendInvoice(orderNo, invoiceDate);
    }

    function testSendInvoice() public {
        // Simulate customer sending a safe payment
        uint256 orderNo = 1;
        uint256 price = 100;
        string memory foodMenu = "Burger";
        uint256 quantity = 2;
        uint256 paymentAmount = 150;

        // send the order
        vm.prank(USER);
        foodOrder.sendOrder(foodMenu, quantity);

        // Send the price
        vm.prank(msg.sender);
        foodOrder.sendPrice(orderNo, price);

        // Send the safe payment
        foodOrder.sendSafepayment{value: paymentAmount}(orderNo);

        // Simulate owner sending an invoice
        uint256 invoiceDate = block.timestamp;

        // Send the invoice
        vm.prank(msg.sender);
        foodOrder.sendInvoice(orderNo, invoiceDate);

        // Fetch and verify the invoice details
        (, uint256 fetchedOrderNo, ) = foodOrder.getInvoice(1);

        assertEq(fetchedOrderNo, orderNo, "Invoice order number should match");
    }

    function testIfTheCustomerIsAddedToTheCustomersArray() public {
        // Simulate customer sending a safe payment
        uint256 orderNo = 1;
        uint256 price = 100;
        string memory foodMenu = "Burger";
        uint256 quantity = 2;
        uint256 paymentAmount = 150;

        // send the order
        vm.prank(USER);
        foodOrder.sendOrder(foodMenu, quantity);

        // Send the price
        vm.prank(msg.sender);
        foodOrder.sendPrice(orderNo, price);

        // Send the safe payment
        vm.prank(USER);
        foodOrder.sendSafepayment{value: paymentAmount}(orderNo);
        address customer = foodOrder.getCustomer(0);
        assertEq(customer, USER);
    }

    // function testRevertsIfInvoiceCreatedIsFalse() public {
    //     // Send the invoice
    //     vm.prank(msg.sender);
    //     foodOrder.sendInvoice(orderNo, invoiceDate);
    // }

    function testMarkDelivered() public {
        // Simulate customer sending a safe payment
        uint256 orderNo = 1;
        uint256 price = 100;
        string memory foodMenu = "Burger";
        uint256 quantity = 2;
        uint256 paymentAmount = 150;

        // send the order
        vm.prank(USER);
        foodOrder.sendOrder(foodMenu, quantity);

        // Send the price
        vm.prank(msg.sender);
        foodOrder.sendPrice(orderNo, price);

        // Send the safe payment
        foodOrder.sendSafepayment{value: paymentAmount}(orderNo);

        // Simulate owner sending an invoice
        uint256 invoiceDate = block.timestamp;

        // Send the invoice
        vm.prank(msg.sender);
        foodOrder.sendInvoice(orderNo, invoiceDate);

        uint256 deliveryDate = block.timestamp + 30 seconds;
        uint8 invoiceID = 1;
        foodOrder.markOrderDelivered(invoiceID, deliveryDate);
    }
}
