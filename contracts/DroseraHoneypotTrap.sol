// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice The Drosera Trap interface (must be implemented)
interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}

/// @title DroseraHoneypotTrap
/// @notice A Drosera-compatible trap based on the honeypot idea.
///         It lures opportunistic actors with a fake `withdraw()`.
///         Instead of paying out, it flags the caller and records them.
///         Drosera nodes can snapshot `attackerCount` & `lastAttacker`
///         and decide when to trigger a response.
contract DroseraHoneypotTrap is ITrap {
    address public owner;

    /// Mapping of flagged attacker addresses
    mapping(address => bool) public attackers;

    /// Simple on-chain state to make snapshots efficient
    uint256 public attackerCount;
    address public lastAttacker;

    /// Off-chain useful event (not used inside collect/shouldRespond)
    event TrapTriggered(address indexed attacker, uint256 timestamp);

    constructor() {
        owner = msg.sender;
    }

    /// @notice Fake withdraw bait: flags caller if not already flagged
    function withdraw() external {
        if (!attackers[msg.sender]) {
            attackers[msg.sender] = true;
            attackerCount += 1;
            lastAttacker = msg.sender;
            emit TrapTriggered(msg.sender, block.timestamp);
        }
    }

    /// Allow the contract to appear funded
    receive() external payable {}
    fallback() external payable {}

    /// Owner-only cleanup to withdraw ETH
    function ownerWithdraw(address payable to) external {
        require(msg.sender == owner, "Only owner");
        uint256 bal = address(this).balance;
        if (bal > 0) {
            to.transfer(bal);
        }
    }

    // ----------------------------------------------------------------
    // Drosera ITrap interface implementation
    // ----------------------------------------------------------------

    /// @notice Return compact snapshot of current trap state
    /// Encoded as (uint256 attackerCount, address lastAttacker)
    function collect() external view override returns (bytes memory) {
        return abi.encode(attackerCount, lastAttacker);
    }

    /// @notice Analyze snapshots to see if the trap should respond
    /// Expects at least 2 snapshots (previous & latest).
    /// Triggers if attackerCount increased between snapshots.
    function shouldRespond(
        bytes[] calldata data
    ) external pure override returns (bool, bytes memory) {
        if (data.length < 2) {
            return (false, bytes("insufficient snapshots"));
        }

        // Decode previous and latest snapshots
        (uint256 prevCount, address prevLast) =
            abi.decode(data[data.length - 2], (uint256, address));
        (uint256 currCount, address currLast) =
            abi.decode(data[data.length - 1], (uint256, address));

        if (currCount > prevCount) {
            uint256 newlyFlagged = currCount - prevCount;
            bytes memory payload = abi.encode(
                newlyFlagged,
                currLast,
                prevCount,
                currCount
            );
            return (true, payload);
        } else {
            return (false, bytes("no new attackers"));
        }
    }

    /// Helper: quick check if address has been flagged
    function isAttacker(address a) external view returns (bool) {
        return attackers[a];
    }
}
