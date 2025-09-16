# 📱 MobileShop Smart Contract

A simple decentralized marketplace for buying and selling mobile phones, built with Solidity.  
This project demonstrates how to use **structs, mappings, events, and Ether transfers** in a secure smart contract.

---

## 🚀 Features
- Add new mobile products with name and price  
- Buy listed products securely using ETH  
- Ownership transfer after purchase  
- Events for product creation and purchase  
- Implements **Check-Effects-Interactions** pattern to prevent reentrancy attacks  

---

## 🛠️ Tech Stack
- Solidity `^0.8.20`  
- Remix IDE (for testing and deployment)  
- Ethereum Virtual Machine (EVM)  

---

## 📂 Contract Overview
### `ProductAdd(string _name, uint _price)`
- Adds a new product to the shop  
- Emits `creatProduct` event  

### `productSold(uint _id)`
- Buys a product by sending ETH equal to its price  
- Transfers ownership to the buyer  
- Transfers ETH securely to the seller  
- Emits `productSell` event  

---

## 🔒 Security
- Validations with `require` (price > 0, valid product id, buyer != seller, enough ETH)  
- Prevents reentrancy using **Check-Effects-Interactions** pattern  

---

## 📖 How to Use
1. Deploy the contract in Remix  
2. Use `ProductAdd` to add a mobile with name & price  
3. Copy the product ID and call `productSold` with ETH to purchase it  
4. Ownership is transferred, and the seller receives payment  

---

## 📝 License
This project is licensed under the **GPL-3.0 License**.
