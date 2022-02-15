// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./interfaces/IBEP20.sol";

contract MonToken is IBEP20 {

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    string _name = "Mon Token";
    string _symbol = "MT";
    uint8 _decimals = 18;
    uint256 _totalSupply = 10000 * 10 ** 18;
    address _owner;

    constructor() {
        _owner = msg.sender;
        balances[_owner] = _totalSupply;
    }

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }
    function decimals() public override view returns (uint8) {
        return _decimals;
    }
    function symbol() public override view returns (string memory) {
        return _symbol;
    }
    function name() public view override returns (string memory) {
        return _name;
    }
    function getOwner() public view override returns (address) {
        return _owner;
    }

    function balanceOf(address owner) public view override returns(uint256) {
        return balances[owner];
    }

    function transfer(address to, uint256 amount) public override returns(bool) {
        require(amount <= balanceOf(msg.sender), "Le montant est trop eleve");
        balances[to] += amount;
        balances[msg.sender] -= amount;
        
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns(uint256) {
        return allowed[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns(bool) {
        
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns(bool) {
        require(allowed[from][to] >= amount, "Allowance too low");
        require(balances[from] >= amount, "Le montant est trop eleve");
        balances[from] -= amount;
        balances[to] += amount;

        emit Transfer(from, to, amount);
        return true;
    }

}