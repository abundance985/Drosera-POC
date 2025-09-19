// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract HoneypotTrap {
    address public owner;
    mapping(address => bool) public attackers;
    event TrapTriggered(address indexed attacker, uint256 timestamp);

    constructor() {
        owner = msg.sender;
    }

    // Fake withdraw function that looks like it should send ETH
    // In a real grabby contract someone might expect funds to be released here
    function withdraw() public {
        // Mark caller as attacker and emit an event
        attackers[msg.sender] = true;
        emit TrapTriggered(msg.sender, block.timestamp);
    }

    // Owner-only helper to see all flagged addresses offchain via events or view
    function isAttacker(address _addr) external view returns (bool) {
        return attackers[_addr];
    }

    // Allow contract to receive ETH (so it looks like there's funds)
    receive() external payable {}
    fallback() external payable {}

    // Optional: owner can withdraw for cleanup
    function ownerWithdraw(address payable to) external {
        require(msg.sender == owner, 'Only owner');
        uint256 bal = address(this).balance;
        if (bal > 0) {
            to.transfer(bal);
        }
    }
}
