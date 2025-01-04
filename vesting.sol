// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}// import "hardhat/console.sol";

contract ETHVesting {
    struct User {
        uint256 investedAmount;    // In Wei (ETH)
        uint256 claimedAmount;     // Token amount claimed
        uint256 vestingStart;      // Timestamp when vesting starts
        uint256 vestingDuration;   // Duration of the vesting in seconds
        uint256 lastClaimTime;     // Last time tokens were claimed
        bool isActive;             // Whether the user is registered and active
    }

    address public owner;         // Owner of the contract
    IERC20 public vestingToken;   // The MVK token (ERC20) to be distributed
    uint256 public cliffPeriod;   // Minimum time the user must wait before claiming tokens
    uint256 public claimFrequency; // The frequency of token claims after the cliff period
    uint256 public totalInvested; // Total ETH invested by users
    uint256 public totalUsers;    // Total number of users

    mapping(address => User) public users; // Mapping to store user information

    event UserRegistered(address indexed user, uint256 ethAmount, uint256 duration);
    event TokensClaimed(address indexed user, uint256 amount);
    event VestingParamsSet(address indexed token, uint256 cliffPeriod, uint256 claimFrequency);
    event ETHWithdrawn(address indexed owner, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _; 
    }

    modifier onlyActiveUser() {
        require(users[msg.sender].isActive, "Not registered for vesting");
        _; 
    }

    constructor() {
        owner = msg.sender;
    }

    // Set the vesting parameters: token address, cliff period, and claim frequency
    function setVestingParams(address _vestingToken, uint256 _cliffPeriod, uint256 _claimFrequency) external onlyOwner {
        require(_vestingToken != address(0), "Invalid token address");
        require(_cliffPeriod > 0, "Invalid cliff period");
        require(_claimFrequency > 0, "Invalid claim frequency");
        require(address(vestingToken) == address(0), "Already initialized");

        vestingToken = IERC20(_vestingToken);
        cliffPeriod = _cliffPeriod;
        claimFrequency = _claimFrequency;

        emit VestingParamsSet(_vestingToken, _cliffPeriod, _claimFrequency);
    }

    // User sends ETH and vesting occurs without token conversion, tokens will be claimed later
    function registerVesting(uint256 _vestingDuration) external payable {
        require(address(vestingToken) != address(0), "Vesting token not set");
        require(_vestingDuration > cliffPeriod, "Duration must exceed cliff period");
        require(msg.value > 0, "Must send ETH to register");

        // Create or update user data
        users[msg.sender] = User({
            investedAmount: msg.value,
            claimedAmount: 0,
            vestingStart: block.timestamp,
            vestingDuration: _vestingDuration,
            lastClaimTime: block.timestamp,
            isActive: true
        });

        totalInvested += msg.value;
        totalUsers++;

        emit UserRegistered(msg.sender, msg.value, _vestingDuration);
    }

    // User can claim MVK tokens after the cliff period and based on claim frequency
    function claimTokens() external onlyActiveUser {
        User storage user = users[msg.sender];

        require(block.timestamp >= user.vestingStart + cliffPeriod, "Cliff period not reached");
        require(block.timestamp >= user.lastClaimTime + claimFrequency, "Claim frequency not reached");

        uint256 elapsedTime = block.timestamp - user.vestingStart;
        uint256 totalClaimable;

        if (elapsedTime >= user.vestingDuration) {
            totalClaimable = user.investedAmount; // Fully vested, claim all MVK tokens
        } else {
            totalClaimable = (user.investedAmount * elapsedTime) / user.vestingDuration; // Proportional vesting
        } 

        uint256 toClaim = totalClaimable - user.claimedAmount;

        // console.log("Total Claimable: ", totalClaimable);
        // console.log("Claimed Amount: ", user.claimedAmount);
        // console.log("To Claim: ", toClaim);



        require(toClaim > 0, "Nothing to claim");
        require(vestingToken.balanceOf(address(this)) >= toClaim, "Insufficient tokens in contract");

        user.claimedAmount += toClaim;
        user.lastClaimTime = block.timestamp;

        require(vestingToken.transfer(msg.sender, toClaim), "Token transfer failed");

        emit TokensClaimed(msg.sender, toClaim);
    }

    // Withdraw ETH from the contract (only accessible by the owner)
    function withdrawETH() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");

        (bool sent, ) = owner.call{value: balance}("");
        require(sent, "Failed to send ETH");

        emit ETHWithdrawn(owner, balance);
    }

    // Get the balance of ETH and MVK tokens in the contract
    function getContractBalance() external view returns (uint256 ethBalance, uint256 tokenBalance) {
        return (address(this).balance, vestingToken.balanceOf(address(this)));
    }
}




// address public ethStorage;

// // Add this function to set storage address
// function setETHStorage(address _ethStorage) external onlyOwner {
//     require(_ethStorage != address(0), "Invalid address");
//     ethStorage = _ethStorage;
// }

// // Updated registerVesting function
// function registerVesting(uint256 _vestingDuration) external payable {
//     require(address(vestingToken) != address(0), "Vesting token not set");
//     require(_vestingDuration > cliffPeriod, "Duration must exceed cliff period");
//     require(msg.value > 0, "Must send ETH to register");
//     require(ethStorage != address(0), "ETH storage not set");

//     // Forward ETH to storage address
//     (bool sent, ) = ethStorage.call{value: msg.value}("");
//     require(sent, "Failed to send ETH to storage");

//     users[msg.sender] = User({
//         investedAmount: msg.value,
//         claimedAmount: 0,
//         vestingStart: block.timestamp,
//         vestingDuration: _vestingDuration,
//         lastClaimTime: block.timestamp,
//         isActive: true
//     });

//     totalInvested += msg.value;
//     totalUsers++;

//     emit UserRegistered(msg.sender, msg.value, _vestingDuration);
// }