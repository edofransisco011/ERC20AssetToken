// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import the ERC20Pausable contract instead of the standard ERC20
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// No need to import Pausable.sol separately, it's included in ERC20Pausable

/**
 * @title SimulatedAssetToken
 * @dev ERC20 token contract designed to represent a simulated real-world asset.
 * It provides standard ERC20 functionality and includes owner-controlled features
 * like setting asset information URI, managing token supply within a cap, and pausing transfers.
 * Inherits from OpenZeppelin's ERC20Pausable for core token logic with pausing built-in,
 * and Ownable for ownership management.
 */
// Inherit from ERC20Pausable (instead of ERC20) and Ownable
contract SimulatedAssetToken is ERC20Pausable, Ownable {

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
    // Constructor remains the same, calls the ERC20 part of ERC20Pausable
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
    // No need for 'whenNotPaused' modifier here because _mint handles it via ERC20Pausable
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
    // No need for 'whenNotPaused' modifier here because _burn handles it via ERC20Pausable
    function burn(uint256 amount) public onlyOwner {
        _burn(msg.sender, amount);
    }

    /**
     * @dev Pauses all token transfers, approvals, minting, and burning operations.
     * Only the contract owner can call this function.
     * See {ERC20Pausable} and {Pausable}.
     */
    function pause() public onlyOwner {
        _pause(); // Internal OpenZeppelin function to pause
    }

    /**
     * @dev Unpauses the contract, re-enabling all token operations.
     * Only the contract owner can call this function.
     * See {ERC20Pausable} and {Pausable}.
     */
    function unpause() public onlyOwner {
        _unpause(); // Internal OpenZeppelin function to unpause
    }

    // Standard ERC20 functions like transfer, transferFrom, approve, etc.
    // are inherited from ERC20Pausable and will automatically respect the paused state.
    // The 'paused()' view function (from Pausable) is also available to check the state.
}