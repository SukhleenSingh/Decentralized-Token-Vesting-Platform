import React, { useState, useEffect } from "react";
import { ethers } from "ethers";
import ABI from "../contracts/ABI.json";

const CONTRACT_ADDRESS = "0xcFD70Bb21C4071c29d958917d35e6B54846e6109";

function UserPage() {
  const [vestingDuration, setVestingDuration] = useState("");
  const [ethAmount, setEthAmount] = useState("");
  const [connectedAccount, setConnectedAccount] = useState(null);

  useEffect(() => {
    connectWallet();
  }, []);

  const connectWallet = async () => {
    if (window.ethereum) {
      try {
        const accounts = await window.ethereum.request({
          method: "eth_requestAccounts",
        });
        setConnectedAccount(accounts[0]);
      } catch (error) {
        console.error("Error connecting to wallet:", error);
      }
    } else {
      alert("MetaMask is not installed!");
    }
  };

  const handleRegisterVesting = async () => {
    if (!vestingDuration || !ethAmount) {
      alert("Please enter both ETH amount and vesting duration");
      return;
    }

    try {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);

      const ethValue = ethers.utils.parseEther(ethAmount); // Convert ETH to wei
      const tx = await contract.registerVesting(vestingDuration, { value: ethValue });
      await tx.wait();

      alert("Vesting registered successfully!");
    } catch (error) {
      console.error("Error registering vesting:", error);
      if (error.message.includes("execution reverted: Vesting token not set")) {
        alert("Vesting token is not set. Please notify the owner.");
      } else if (error.message.includes("UNPREDICTABLE_GAS_LIMIT")) {
        alert("Transaction failed. Please try again later.");
      } else {
        alert("Error registering vesting. Please check the console for details.");
      }
    }
  };

  return (
    <div className="container">
      <h2>User Page</h2>
      {connectedAccount ? (
        <p>Connected Wallet: {connectedAccount}</p>
      ) : (
        <button onClick={connectWallet}>Connect Wallet</button>
      )}
      <input
        type="number"
        placeholder="Vesting Duration (seconds)"
        value={vestingDuration}
        onChange={(e) => setVestingDuration(e.target.value)}
      />
      <input
        type="text"
        placeholder="ETH Amount"
        value={ethAmount}
        onChange={(e) => setEthAmount(e.target.value)}
      />
      <button onClick={handleRegisterVesting}>Register Vesting</button>
    </div>
  );
}

export default UserPage;
