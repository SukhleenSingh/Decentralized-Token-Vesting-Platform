// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// Importing the OpenZeppelin ERC20 contract
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {

    // Constructor to initialize the token with a name and symbol
    constructor() ERC20("My Vested Token", "MVT") {
        // Mint 1,000,000 tokens to the deployer's address
        _mint(msg.sender, 100000000000 * 10 ** decimals());
    }

    // // Admin function to mint new tokens (can be extended for more control)
    // function mint(address to, uint256 amount) external {
    //     _mint(to, amount);
    // }
}

