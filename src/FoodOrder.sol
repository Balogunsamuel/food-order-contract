//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/// @title  FoodOrder Contract
/// @author Balogun Samuel
/// @notice This contract is designed to act as an intermediary between the selle and the buyer of food, that when you order the food and pay then the contract wont release the amount until you food is delivered.
contract FoodOrder {
    error FoodOrder__OnlyTheOwnerCanDoThis();
    error FoodOrder__ThisSpecficOrderDoesNotExist();
    error FoodOrder__NoOrderExistToGetThePrice();
    error FoodOrder__TheInvoiceDoesntExist();

    address payable private immutable owner;
    address[] public s_customers;

    struct Order {
        uint256 ID;
        string foodMenu;
        uint256 quantity;
        uint256 price;
        uint256 safePayment;
        uint256 orderDate;
        uint256 deliveryDate;
        bool created;
    }

    struct Invoice {
        uint256 ID;
        uint orderNo;
        bool created;
    }

    mapping(uint256 => Order) orders;
    mapping(uint256 => Invoice) invoices;

    uint256 orderseq;
    uint256 invoiceseq;

    event PriceOfOrder(uint256 orderID, uint256 price);

    constructor() {
        owner = payable(msg.sender);
    }

    function sendOrder(string memory foodMenu, uint256 quantity) public {
        orderseq++;

        // we passed the needed members of the struct as params so we can call them
        orders[orderseq] = Order(
            orderseq,
            foodMenu,
            quantity,
            0,
            0,
            0,
            0,
            true
        );
    }

    function checkOrder(
        uint ID
    )
        public
        view
        returns (
            address _customer,
            string memory foodMenu,
            uint quantity,
            uint price,
            uint safePayment
        )
    {
        if (!orders[ID].created) {
            revert FoodOrder__ThisSpecficOrderDoesNotExist();
        }

        return (
            _customer,
            orders[ID].foodMenu,
            orders[ID].quantity,
            orders[ID].price,
            orders[ID].safePayment
        );
    }

    function sendPrice(uint orderNo, uint price) public {
        if (owner != msg.sender) {
            revert FoodOrder__OnlyTheOwnerCanDoThis();
        }
        if (!orders[orderNo].created) {
            revert FoodOrder__ThisSpecficOrderDoesNotExist();
        }

        orders[orderNo].price = price;
        emit PriceOfOrder(orderNo, price);
    }

    ///
    /// @param orderNo the number tagged to the according to the order made in the contract
    function getPrice(uint orderNo) external view returns (uint256) {
        if (!orders[orderNo].created) {
            revert FoodOrder__NoOrderExistToGetThePrice();
        }
        uint256 priceOfFood = orders[orderNo].price;
        return priceOfFood;
    }

    /// @param orderNo the number tagged to the according to the order made in the contract
    function sendSafepayment(uint orderNo) public payable {
        if (!orders[orderNo].created) {
            revert FoodOrder__ThisSpecficOrderDoesNotExist();
        }

        orders[orderNo].safePayment = msg.value;
        s_customers.push(msg.sender);
    }

    ///  When the payment has been confirmed from the customers the sendInvoice will be processed.
    /// @param orderNo the number tagged to the according to the order made in the contract
    /// @param order_date date the order was made
    function sendInvoice(uint orderNo, uint order_date) public {
        if (owner != msg.sender) {
            revert FoodOrder__OnlyTheOwnerCanDoThis();
        }
        if (!orders[orderNo].created) {
            revert FoodOrder__ThisSpecficOrderDoesNotExist();
        }

        invoiceseq++;

        invoices[invoiceseq] = Invoice(invoiceseq, orderNo, true);

        orders[orderNo].orderDate = order_date;
    }

    ///
    /// @param invoiceID the invoice identification
    /// @param deliveryDate date of delivery
    function markOrderDelivered(uint invoiceID, uint deliveryDate) public {
        if (!invoices[invoiceID].created) {
            revert FoodOrder__TheInvoiceDoesntExist();
        }

        Invoice storage _invoice = invoices[invoiceID];
        Order storage _order = orders[_invoice.orderNo];

        _order.deliveryDate = deliveryDate;

        owner.transfer(_order.safePayment);
    }

    ///
    /// @param invoiceID the invoice identification
    /// @return _customer addresss of the customer
    /// @return orderNo the number tagged to the according to the order made in the contract
    /// @return invoice_date the date the invoice was generated
    function getInvoice(
        uint invoiceID
    ) public view returns (address _customer, uint orderNo, uint invoice_date) {
        if (!invoices[invoiceID].created) {
            revert FoodOrder__TheInvoiceDoesntExist();
        }
        //require(invoices[invoiceID].created, "The invoice doesn't exist");

        Invoice storage _invoice = invoices[invoiceID];
        Order storage _order = orders[_invoice.orderNo];

        return (_customer, _order.ID, _order.orderDate);
    }

    /// To get the owner of the deployed contract
    function getOwner() external view returns (address) {
        return owner;
    }

    /// the current customer of the contract in buying from the seller
    function getCustomer(
        uint256 customerIndex
    ) external view returns (address) {
        return s_customers[customerIndex];
    }
}
