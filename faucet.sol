// Version of Solidity compiler this program was written for
pragma solidity ^0.5.1;

contract Faucet {
    address owner;

    // Contract constructor: set owner
    constructor() public {
        owner = msg.sender;
    }

    // Contract destructor
    function destroy() public {
        require(msg.sender == owner);
        selfdestruct(msg.sender);
    }

    // Give out ether to anyone who asks
    function withdraw(uint withdraw_amount) public {
        // Limit withdrawal amount
        require(withdraw_amount <= 0.1 ether);
        require(address(this).balance >= withdraw_amount, "Insufficient balance in faucet for withdrawal request");

        // Send the amount to the address that requested it
        msg.sender.transfer(withdraw_amount);
    }

    // Accept any incoming amount
    function () external payable {}
}
