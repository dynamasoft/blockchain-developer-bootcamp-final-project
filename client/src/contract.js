import { useState } from "react";
import { ethers } from "ethers";
import Roomilicious from "./artifacts/contracts/Roomilicious.sol/Roomilicious.json";
import Config from "./artifacts/contracts/config.json";
import { useScrollTrigger } from "@material-ui/core";

export default class Contract {
  constructor() {
    this.LISTING_FEE = ethers.utils.parseUnits("1", "wei");
    this.APPLICATION_FEE = ethers.utils.parseUnits("1", "wei");
  }

  //using local blockchain hardhat node
  async initialize(useLocalNode) {    
      this.useLocalNode = useLocalNode;

      if (this.useLocalNode) {
        debugger;
        //this is only for local testing using local hardhat node
        this.provider = new ethers.providers.JsonRpcProvider(
          "http://127.0.0.1:8545"
        );
        this.accounts = await this.provider.listAccounts();

        this.owner = this.accounts[0];
        this.homeOwner1 = this.accounts[1];
        this.applicant1 = this.accounts[2];
      } 
      else 
      {
        this.provider = new ethers.providers.Web3Provider(window.ethereum);     
        //await window.ethereum.request({ method: "eth_requestAccounts" }); 
      }

      this.propertyID = 0;
      this.applicationID = 0;  
  }

  async listProperty(address, monthlyRent, totalHouseMate) 
  {
    let rent = ethers.utils.parseUnits(monthlyRent.toString(), "wei");
  
    let contract = new ethers.Contract(
      Config,
      Roomilicious.abi,
      await this.getHomeOwner()
    );

    let result = await contract.listProperty(address, rent, totalHouseMate, {
      value: this.LISTING_FEE,
    });

    this.propertyID = result.value.toNumber();    
    return this.propertyID;
  }

  async approvePropertyListing(propertyID) {
    let contract = new ethers.Contract(
      Config,
      Roomilicious.abi,
      await this.getOwner()
    );
    await contract.approvePropertyListing(propertyID);
  }

  async applyToRental(propertyID, monthlyIncome) {
    let income = ethers.utils.parseUnits(monthlyIncome.toString(), "wei");
    let contract = new ethers.Contract(
      Config,
      Roomilicious.abi, await this.getApplicant()
    );
    let result = await contract.applyToProperty(propertyID, income, {
      value: this.APPLICATION_FEE,
    });
    this.applicationID = result.value.toNumber();
    return this.applicationID;
  }

  async getApplicant()
  {
    if(this.useLocalNode)
    {
        this.provider.getSigner(this.applicant1);
    }
    else
    {
        await window.ethereum.request({ method: "eth_requestAccounts" });
        const signer = this.provider.getSigner();
        return signer;
    }
  }

  async getOwner()
  {
    if(this.useLocalNode)
    {
        this.provider.getSigner(this.owner);
    }
    else
    {
      debugger;
        await window.ethereum.request({ method: "eth_requestAccounts" });
        const signer = await this.provider.getSigner();
        return signer;
    }
  }

  async getHomeOwner()
  {
    debugger;
    if(this.useLocalNode)
    {
        this.provider.getSigner(this.homeOwner1);
    }
    else
    {
        await window.ethereum.request({ method: "eth_requestAccounts" });
        const signer = this.provider.getSigner();
        return signer;
    }
  }

  async declineApplicant(applicationID) {
    let contract = new ethers.Contract(
      Config,
      Roomilicious.abi,
      await this.getHomeOwner()
    );
    await contract.declineApplicant(applicationID);
    return true;
  }

  async startRentalProcess(applicationID, callbackApproved, callbackRejected) {
    debugger;
    try {
      let contract = new ethers.Contract(
        Config,
        Roomilicious.abi,
        await this.getHomeOwner()
      );

      //listening to the event to call oracles
      contract.on("StartRentalProcessEvent", (result, event) => {
        debugger;
        this.oracleRentalVerifier(result.toNumber());
      });

      contract.on("ApplicationApprovedEvent", (result, event) => {
        debugger;
        callbackApproved(result.toNumber());
      });

      contract.on("ApplicationRejectedEvent", (result, event) => {
        debugger;
        callbackRejected(result.toNumber());
      });

      await contract.startRentalProcess(applicationID);

      return true;
    } catch (error) {
      console.log(error);
      return false;
    }
  }

  async oracleRentalVerifier(applicationID) {
    try {
      let contract = new ethers.Contract(
        Config,
        Roomilicious.abi,
        await this.getOwner()
      );
      await contract.submitTenantResearch(this.applicationID, true);
      await contract.submitTenantResearch(this.applicationID, false);
    } catch (error) {
      console.log(error);
    }
  }
}

// const [greeting, setGreetingValue] = useState();

// async function requestAccount() {
//   await window.ethereum.request({ method: "eth_requestAccounts" });
// }

// async function fetchGreeting() {
//   if (typeof window.ethereum !== "undefined") {
//     const provider = new ethers.providers.Web3Provider(window.ethereum);
//     const contract = new ethers.Contract(
//       greeterAddress,
//       Greeter.abi,
//       provider
//     );
//     try {
//       const data = await contract.greet();
//       console.log("data: ", data);
//     } catch (err) {
//       console.log("Error: ", err);
//     }
//   }
// }

// // call the smart contract, send an update
// async function setGreeting() {
//   if (!greeting) return;

//   if (typeof window.ethereum !== "undefined") {
//     await requestAccount();
//     const provider = new ethers.providers.Web3Provider(window.ethereum);
//
//     const signer = provider.getSigner();

//     const contract = new ethers.Contract(greeterAddress, Greeter.abi, signer);
//     const transaction = await contract.setGreeting(greeting);
//     await transaction.wait();
//     fetchGreeting();
//   }
// }
