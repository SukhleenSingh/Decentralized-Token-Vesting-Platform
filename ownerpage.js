import React, { useState, useEffect } from "react";
import { ethers } from "ethers";
import ABI from "../contracts/ABI.json";

const CONTRACT_ADDRESS = "0xcFD70Bb21C4071c29d958917d35e6B54846e6109";

function OwnerPage() {
  const [vestingToken, setVestingToken] = useState("");
  const [cliffPeriod, setCliffPeriod] = useState("");
  const [claimFrequency, setClaimFrequency] = useState("");
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

  const handleSetVestingParams = async () => {
    try {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);

      await contract.setVestingParams(vestingToken, cliffPeriod, claimFrequency);
      alert("Vesting parameters set successfully!");
    } catch (error) {
      console.error(error);
      alert("Error setting vesting parameters");
    }
  };

  const handleWithdrawETH = async () => {
    try {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);

      await contract.withdrawETH();
      alert("ETH withdrawn successfully!");
    } catch (error) {
      console.error(error);
      alert("Error withdrawing ETH");
    }
  };

  return (
    <div className="container">
      <h2>Owner Page</h2>
      {connectedAccount ? (
        <p>Connected Wallet: {connectedAccount}</p>
      ) : (
        <button onClick={connectWallet}>Connect Wallet</button>
      )}
      <input
        type="text"
        placeholder="Vesting Token Address"
        value={vestingToken}
        onChange={(e) => setVestingToken(e.target.value)}
      />
      <input
        type="number"
        placeholder="Cliff Period (seconds)"
        value={cliffPeriod}
        onChange={(e) => setCliffPeriod(e.target.value)}
      />
      <input
        type="number"
        placeholder="Claim Frequency (seconds)"
        value={claimFrequency}
        onChange={(e) => setClaimFrequency(e.target.value)}
      />
      <button onClick={handleSetVestingParams}>Set Vesting Params</button>
      <button onClick={handleWithdrawETH}>Withdraw ETH</button>
    </div>
  );
}

export default OwnerPage; 