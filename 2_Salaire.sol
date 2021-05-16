// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;

contract Salaire {
    
    
    address[] employees = [0xdD870fA1b7C4700F2BD7f44238821C26f7392148, 0x583031D1113aD414F02576BD6afaBfb302140225, 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB, 0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c];
    uint totalReceived = 0;
    uint totalWithdrawn = 0;
    uint public totalBalance = 0;
    address public adminAddress;
    
    event EvTotalBalance(uint amount);
    
    mapping(address => uint) withdrawnAmounts;
    
    /* When ether is sent to the contract it updates local variables */
    fallback() external {
        updateTotalReceived();
        updateTotalBalance();
    }
    
    /* Updates total ether received */
    function updateTotalReceived() internal {
        totalReceived = totalReceived + msg.value;
    }
    
    /* Updates total ether withdrawn */
    function updateTotalWithdrawn(uint amount) internal {
        totalWithdrawn += amount;
    }
    
    /* Updates total balance variable */ 
    function updateTotalBalance() internal {
        totalBalance = totalReceived - totalWithdrawn;
        emit EvTotalBalance(totalBalance);
    }
    
    /* Receives an adminAddress so that someone can have control over the contract */
    constructor(address _adminAddress) {
        updateTotalReceived();
        adminAddress = _adminAddress;
    }
    
    /* Works as a condition, identifies if an address
    calling a function is authorized to withdraw */
    modifier canWithdraw() {
        bool contains = false;
        for(uint i=0; i < employees.length; i++) {
            if (msg.sender == employees[i]) {
                contains = true;
            }
        }
        require(contains, "You're not authorized to withdraw funds from this address");
        _;
    }
    
    
    /* Condition checking if caller is an admin */
    modifier isAdmin() {
        require(msg.sender == adminAddress, "This function can only be called by an admin");
        _;
    }
    
    /* Allows everyone to deposit on this address via a function */
    function deposit() public payable {
        updateTotalReceived();
        updateTotalBalance();
    }

    /* Function permitting adminAddress to withdraw all the funds */
    function withdrawAll() public isAdmin {
        payable(msg.sender).transfer(totalBalance);
        updateTotalWithdrawn(totalBalance);
        updateTotalBalance();
    }
    
    /* Function allowing and calculating how much an employee can withdraw */
    function withdraw() public canWithdraw {
        uint amountAllocated = totalReceived/employees.length;
        uint amountWithdrawn = withdrawnAmounts[msg.sender];
        uint amount = amountAllocated - amountWithdrawn;
        address payable msgsender = payable(msg.sender);
        withdrawnAmounts[msg.sender] = amountWithdrawn + amount;
        
        if(amount > 0) {
            msgsender.transfer(amount); 
            updateTotalWithdrawn(amount);
            updateTotalBalance();
        }
    } 
}

