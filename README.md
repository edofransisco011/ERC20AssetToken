# ERC20AssetToken

![Solidity](https://img.shields.io/badge/Solidity-%3E%3D0.8.20-blue)
![OpenZeppelin](https://img.shields.io/badge/OpenZeppelin-%5E5.0.0-green)
![Ethereum Testnet](https://img.shields.io/badge/Ethereum-Sepolia%20Testnet-lightgrey)

## Description

This repository contains the smart contract code for `ERC20AssetToken`, an ERC-20 compatible fungible token designed to conceptually represent a **simulated Real-World Asset (RWA)** on the Ethereum blockchain.

Developed as a beginner-level portfolio piece, this project focuses on demonstrating fundamental smart contract development skills and the integration of standard, secure libraries for building tokenized assets.

## Purpose

The primary purpose of this project is to showcase core Solidity development concepts and practices relevant to creating fungible tokens, with a conceptual link to the growing domain of Real-World Asset tokenization. It serves as a practical demonstration of implementing widely-used smart contract patterns and standards.

## Technologies Used

* **Solidity:** The smart contract programming language for Ethereum.
* **OpenZeppelin Contracts:** A library of battle-tested, community-approved smart contracts for implementing standard behaviors (like ERC-20, Ownership, Pausability) and secure patterns.
* **Ethereum Blockchain:** The target blockchain environment (specifically the Sepolia Testnet for deployment).
* **Remix IDE:** The integrated development environment used for coding, compiling, and initial manual testing/deployment.

## Features

The `ERC20AssetToken` contract implements the following features:

* **ERC-20 Standard Compliance:** Full implementation of the ERC-20 fungible token standard, allowing for transfers, balance tracking, approvals, and allowances.
* **Ownership:** Utilizes the `Ownable` pattern from OpenZeppelin, granting a single address (the deployer) administrative control over specific contract functions.
* **Pausability:** Integrates `ERC20Pausable` from OpenZeppelin, enabling the contract owner to pause and unpause sensitive token operations (transfers, minting, burning, approvals) in case of emergencies or necessary maintenance.
* **Maximum Supply Cap:** Enforces a fixed maximum total supply (`MAX_SUPPLY`) for the token, set immutably during contract deployment, preventing arbitrary inflation.
* **Simulated RWA Link:** Includes a state variable (`_assetInfoUri`) and an owner-only function (`setAssetInfoUri`) to store and update a URI pointing to off-chain information or metadata about the simulated real-world asset.
* **Events:** Emits standard ERC-20 events (`Transfer`, `Approval`) and a custom `AssetInfoUriUpdated` event to provide a transparent log of key contract activities.
* **NatSpec Documentation:** Includes comprehensive inline documentation in the Solidity code using the NatSpec format (`///` and `/** */`), enhancing code readability and enabling documentation generation by development tools.
* **Secure Library Usage:** Leverages audited and widely-used contracts from the OpenZeppelin library to minimize security risks associated with implementing standard functionalities from scratch.

## Deployed Contract

This contract has been deployed to the **Sepolia** Ethereum testnet.

* **Testnet:** Sepolia
* **Contract Address:** `[Insert the actual deployed contract address here]`
* **Etherscan Link:** [Insert the link to the contract on sepolia.etherscan.io here]

*Note: As this is a testnet deployment, the tokens and transactions have no real-world value. Testnet explorers like Sepolia Etherscan allow you to view the contract's code (if verified), read public data, and interact with functions.*

## Getting Started / Code

To view the full source code and interact with the deployed contract:

1.  **View on Etherscan:** Visit the [Etherscan link] provided above. You can read public state variables (like `name`, `symbol`, `totalSupply`, `balanceOf`, `owner`, `MAX_SUPPLY`, `paused`, `assetInfoUri`) using the 'Read Contract' tab. You can also interact with transaction-based functions (like `transfer`, `approve`, `mint`, `burn`, `pause`, `unpause`, `setAssetInfoUri`) using the 'Write Contract' tab after connecting a Web3 wallet funded with Sepolia ETH.
2.  **Compile and Deploy Yourself:** The complete Solidity code is provided below. You can copy and paste it into [Remix IDE](https://remix.ethereum.org/) to compile and deploy it yourself on a local Remix VM or another testnet. Alternatively, you can set up a local development environment like Hardhat or Foundry to work with the code.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; // Or the specific version you used

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SimulatedAssetToken
 * @dev ERC20 token contract designed to represent a simulated real-world asset.
 * It provides standard ERC20 functionality and includes owner-controlled features
 * like setting asset information URI, managing token supply within a cap, and pausing transfers.
 * Inherits from OpenZeppelin's ERC20Pausable for core token logic with pausing built-in,
 * and Ownable for ownership management.
 */
contract ERC20AssetToken is ERC20Pausable, Ownable {

    /**
     * @dev Stores a URI pointing to off-chain information or metadata about the simulated asset.
     * This could be an IPFS hash, a URL to a JSON file, etc.
     */
    string private _assetInfoUri;

    /**
     * @dev Defines the maximum total supply of tokens that can ever exist.
     * This is set in the constructor and cannot be changed.
     */
    uint256 public immutable MAX_SUPPLY;

    // Define a new event for when the asset info URI is updated
    event AssetInfoUriUpdated(string newUri, address indexed updatedBy);

    /**
     * @dev Constructor to initialize the token with its name, symbol,
     * an initial supply minted to the deployer, and a maximum total supply.
     * @param name_ The public name of the token (e.g., "Simulated Property Share").
     * @param symbol_ The public symbol of the token (e.g., "SPS").
     * @param initialSupply The initial number of tokens to mint to the contract deployer (considering token decimals).
     * @param maxSupply The maximum total number of tokens that can ever be in circulation (considering token decimals).
     */
    constructor(string memory name_, string memory symbol_, uint256 initialSupply, uint256 maxSupply)
        ERC20(name_, symbol_) // Call the ERC20 constructor (part of ERC20Pausable)
        Ownable(msg.sender) // Call the Ownable parent constructor
    {
        require(initialSupply <= maxSupply, "Initial supply exceeds max supply");
        MAX_SUPPLY = maxSupply;

        _mint(msg.sender, initialSupply); // _mint is now pause-aware via ERC20Pausable
    }

    /**
     * @dev Allows the contract owner to set or update the URI pointing to the asset's information.
     * Only the contract owner can call this function.
     * Emits an {AssetInfoUriUpdated} event.
     * This function does not involve token transfers, so it is NOT affected by pausing.
     * @param assetInfoUri_ The new URI string.
     */
    function setAssetInfoUri(string memory assetInfoUri_) public onlyOwner {
        _assetInfoUri = assetInfoUri_;
        emit AssetInfoUriUpdated(assetInfoUri_, msg.sender);
    }

    /**
     * @dev Returns the current URI pointing to the simulated asset's information.
     */
    function assetInfoUri() public view returns (string memory) {
        return _assetInfoUri;
    }

    /**
     * @dev Allows the contract owner to mint new tokens and assign them to a specified address.
     * This function is restricted to the contract owner.
     * The total supply cannot exceed {MAX_SUPPLY}.
     * This function *is* automatically restricted when the contract is paused because it calls `_mint`,
     * which is overridden in ERC20Pausable to check the paused state.
     * Emits a {Transfer} event.
     * @param to The address that will receive the minted tokens.
     * @param amount The amount of tokens to mint (in the smallest unit, considering decimals).
     */
    function mint(address to, uint256 amount) public onlyOwner {
        require(totalSupply() + amount <= MAX_SUPPLY, "Minting exceeds max supply");
        _mint(to, amount);
    }

    /**
     * @dev Allows the contract owner to burn (destroy) tokens from the caller's balance.
     * This function is restricted to the contract owner.
     * This function *is* automatically restricted when the contract is paused because it calls `_burn`,
     * which is overridden in ERC20Pausable to check the paused state.
     * Emits a {Transfer} event.
     * @param amount The amount of tokens to burn (in the smallest unit, considering decimals).
     */
    function burn(uint256 amount) public onlyOwner {
        _burn(msg.sender, amount);
    }

    /**
     * @dev Pauses all token transfers, approvals, minting, and burning operations.
     * Only the contract owner can call this function.
     * See {ERC20Pausable} and {Pausable}.
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses the contract, re-enabling all token operations.
     * Only the contract owner can call this function.
     * See {ERC20Pausable} and {Pausable}.
     */
    function unpause() public onlyOwner {
        _unpause();
    }
}
