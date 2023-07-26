// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/**
 * @title SocialRecoveryWallet
 * @dev A smart contract that implements social recovery functionality for wallet ownership.
 * Users can register guardians who can collectively vote for a new owner in case of recovery.
 * The proposed new owner must obtain a sufficient number of votes to claim ownership.
 */
contract SocialRecoveryWallet is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    // Storage for the set of registered guardians
    EnumerableSet.AddressSet private guardians;

    // Address of the proposed new owner during a recovery process
    address public proposedOwner;

    // Counter to track the recovery attempts
    uint256 private _recoveryCounter;

    // Mapping to store the number of votes for each guardian in a recovery attempt
    mapping(uint256 => mapping(address => uint256)) public votes;

    /**
     * @dev Execute a generic transaction on behalf of the contract.
     * @param target The target address to execute the transaction on.
     * @param data The transaction data to be executed.
     * @notice Only the contract owner can call this function.
     * @notice The target address must not be 0 and the data length must be greater than 0.
     * @notice The execution fails if the target call does not succeed.
     */
    function execute(
        address target,
        bytes memory data
    ) external payable onlyOwner {
        require(target != address(0), "Invalid target address");
        require(data.length > 0, "Empty data");
        (bool success, bytes memory result) = target.call{value: msg.value}(
            data
        );
        require(success, "Execution failed");
    }

    /**
     * @dev Register a new guardian.
     * @param guardian The address of the new guardian to be registered.
     * @notice Only the contract owner can call this function.
     * @notice The guardian must not be already registered.
     */
    function registerGuardian(address guardian) external onlyOwner {
        require(!guardians.contains(guardian), "Guardian already registered");
        guardians.add(guardian);
    }

    /**
     * @dev Deregister an existing guardian.
     * @param guardian The address of the guardian to be deregistered.
     * @notice Only the contract owner can call this function.
     * @notice The guardian must be registered before deregistering.
     */
    function deregisterGuardian(address guardian) external onlyOwner {
        require(guardians.contains(guardian), "Guardian not registered");
        guardians.remove(guardian);
    }

    /**
     * @dev Function for guardians to vote for a specific address to become the new owner.
     * @param newOwner The address of the proposed new owner.
     * @notice Only registered guardians can call this function.
     * @notice The newOwner address must not be 0, must not be the current owner's address,
     * and must not be the same as the currently proposed owner's address.
     * @notice The vote is counted for the current recovery attempt.
     * @notice If the newOwner receives enough votes, they become the proposed owner.
     */
    function chooseRecoverer(address newOwner) external {
        require(guardians.contains(msg.sender), "Only guardians can vote");
        require(newOwner != address(0), "Invalid address");
        require(newOwner != owner(), "Already owner");
        require(newOwner != proposedOwner, "Already proposed");
        votes[_recoveryCounter][newOwner]++;

        // If the newOwner reaches the required number of votes, set as the proposedOwner
        if (votes[_recoveryCounter][newOwner] >= guardians.length()) {
            proposedOwner = newOwner;
        }
    }

    /**
     * @dev Function to finalize the ownership transfer after enough votes have been received.
     * @notice The caller must be the proposed owner.
     * @notice The proposed owner must have received enough votes to pass the threshold.
     * @notice Ownership transfer occurs, and the proposed owner is reset to address(0) after the process.
     * @notice The recoveryCounter is incremented for the next recovery attempt.
     */
    function recovererClaimOwnership() external {
        require(msg.sender == proposedOwner, "Not the proposed owner");
        _transferOwnership(proposedOwner);
        proposedOwner = address(0);
        _recoveryCounter++;
    }
}
