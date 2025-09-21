// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

/// @title MobileShop - a simple marketplace for phones (optimized & reentrancy-safe)
/// @author Ali Nasirlou
/// @notice This contract demonstrates a minimal marketplace: add product, buy product
/// @dev Uses OpenZeppelin ReentrancyGuard, calldata for gas savings, storage pointers and call() for transfers

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MobileShop is ReentrancyGuard {
    // Counter for product IDs (uint256 is gas-friendly on EVM)
    uint256 public counter;

    // Product struct: compact, owner stored as address (convert to payable only on transfer)
    struct Product {
        uint256 id;
        string name;
        uint256 price; // price in wei
        address owner;
        bool sold;
    }

    // Mapping from productId => Product
    mapping(uint256 => Product) public products;

    // Events with indexed fields for easy off-chain filtering
    event ProductCreated(uint256 indexed id, string name, uint256 price, address indexed owner, bool sold);
    event ProductSold(uint256 indexed id, string name, uint256 price, address indexed newOwner, bool sold);

    /// @notice Add a new product to the marketplace
    /// @dev Uses calldata for the string to save gas. Not payable (no ETH needed to list).
    /// @param _name Product name
    /// @param _price Price in wei (must be > 0)
    function addProduct(string calldata _name, uint256 _price) external {
        require(bytes(_name).length > 0, "ERR: name empty");
        require(_price > 0, "ERR: price zero");

        // increment ID and store product
        counter += 1;
        products[counter] = Product({id: counter, name: _name, price: _price, owner: msg.sender, sold: false});

        emit ProductCreated(counter, _name, _price, msg.sender, false);
    }

    /// @notice Buy a product by id, sending ETH equal (or greater) to product.price
    /// @dev nonReentrant to prevent reentrancy attacks. Uses Checks-Effects-Interactions pattern.
    /// @param _id Product id to buy
    function buyProduct(uint256 _id) external payable nonReentrant {
        // 1) Access storage directly (no memory copy) - cheaper & updates in-place
        Product storage p = products[_id];

        // 2) Checks
        require(p.id != 0 && _id <= counter, "ERR: invalid id");
        require(!p.sold, "ERR: already sold");
        require(msg.value >= p.price, "ERR: not enough ETH");
        require(msg.sender != p.owner, "ERR: seller cannot buy own product");

        // 3) Effects — update contract state BEFORE external calls (prevents reentrancy)
        address payable seller = payable(p.owner);
        address buyer = msg.sender;
        uint256 price = p.price;

        p.owner = buyer;
        p.sold = true;

        // 4) Interactions — external calls after state changes

        // If buyer overpaid, refund the excess first
        if (msg.value > price) {
            uint256 refund = msg.value - price;
            (bool rRefund, ) = payable(buyer).call{value: refund}("");
            require(rRefund, "ERR: refund failed");
        }

        // Pay the seller the product price. Use call to avoid issues with gas stipend.
        (bool sent, ) = seller.call{value: price}("");
        require(sent, "ERR: seller payment failed");

        emit ProductSold(_id, p.name, price, buyer, true);
    }

    /// @notice Retrieve product details (auto-generated getter exists but explicit read helper can be used)
    /// @param _id Product id
    /// @return id, name, price, owner, sold
    function getProduct(uint256 _id)
        external
        view
        returns (
            uint256 id,
            string memory name,
            uint256 price,
            address owner,
            bool sold
        )
    {
        Product storage p = products[_id];
        return (p.id, p.name, p.price, p.owner, p.sold);
    }
}

