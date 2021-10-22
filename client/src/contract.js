import { useState } from "react";
import { ethers } from "ethers";
import Roomilicious from "./artifacts/contracts/Roomilicious.sol/Roomilicious.json";
import Config from "./artifacts/contracts/config.json";

export default class Contract {
  constructor() {
    this.LISTING_FEE = ethers.utils.parseUnits("1", "wei");
    this.APPLICATION_FEE = ethers.utils.parseUnits("1", "wei");

    //this.contract;
    //this.accounts = [];
    //this.provider;
    //this.homeOwner1;

    //this.initialize();
    //const provider = new ethers.providers.Web3Provider(window.ethereum);
    //local test

    //const provider = new ethers.providers.Web3Provider(window.ethereum);

    // const contract = new ethers.Contract(
    //   greeterAddress,
    //   Greeter.abi,
    //   provider
    // );
  }

  //using local blockchain hardhat node
  async initialize() {
    try {
      
      //const provider = new ethers.providers.Web3Provider(window.ethereum);
      this.provider = new ethers.providers.JsonRpcProvider(
        "http://127.0.0.1:8545"
      );
      this.accounts = await this.provider.listAccounts();
      //this.accounts = await this.provider.getSigners();
      this.owner = this.accounts[0];
      this.homeOwner1 = this.accounts[1];
      this.applicant1 = this.accounts[2];
      this.propertyID = 0;
      this.applicationID = 0;
    } catch (error) {
      
      console.log(error);
    }
  }

  async listProperty(address, monthlyRent, totalHouseMate) {
        
      let rent = ethers.utils.parseUnits(monthlyRent.toString(), "wei");
      let contract = new ethers.Contract(
        Config,
        Roomilicious.abi,
        this.provider.getSigner(this.homeOwner1)
      );
      let result = await contract.listProperty(address, rent, totalHouseMate, {
        value: this.LISTING_FEE,
      });

      this.propertyID = result.value.toNumber();

      //let result = await contract.getAllProperties();
      return this.propertyID;
      
  }

  async approvePropertyListing(propertyID) {
    let contract = new ethers.Contract(
      Config,
      Roomilicious.abi,
      this.provider.getSigner(this.owner)
    );
    await contract.approvePropertyListing(propertyID);
  }

  async applyToRental(propertyID, monthlyIncome) {
    
    let income = ethers.utils.parseUnits(monthlyIncome.toString(), "wei");
    let contract = new ethers.Contract(
      Config,
      Roomilicious.abi,
      this.provider.getSigner(this.applicant1)
    );
    let result = await contract.applyToProperty(propertyID, income, {
      value: this.APPLICATION_FEE,
    });
    this.applicationID = result.value.toNumber();
    return this.applicationID;
  }

  async declineApplicant(applicationID) {    
      
      let contract = new ethers.Contract(Config,Roomilicious.abi,this.provider.getSigner(this.homeOwner1));
      await contract.declineApplicant(applicationID);
      return true;    
  }

  async startRentalProcess(applicationID, callbackApproved, callbackRejected) {
    debugger;
    try {
      let contract = new ethers.Contract(Config,Roomilicious.abi,this.provider.getSigner(this.homeOwner1));

       //listening to the event to call oracles
       contract.on("StartRentalProcessEvent", (result, event) =>
       {
          debugger;   
          this.oracleRentalVerifier(result.toNumber());
       });


       contract.on("ApplicationApprovedEvent", (result, event) =>
       {
            debugger;            
            callbackApproved(result.toNumber());
       });

       contract.on("ApplicationRejectedEvent", (result, event) =>
       {
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

  async oracleRentalVerifier(applicationID) 
  {
    
    try {
      let contract = new ethers.Contract(Config,Roomilicious.abi,this.provider.getSigner(this.owner));
      await contract.submitTenantResearch(this.applicationID, true);
      await contract.submitTenantResearch(this.applicationID, false);
    }
    catch(error)
    {
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