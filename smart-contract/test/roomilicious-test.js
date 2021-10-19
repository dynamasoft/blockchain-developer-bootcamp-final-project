const { expect } = require("chai");
const { ethers } = require("hardhat");

const LISTING_FEE = ethers.utils.parseUnits("1.0", "ether");
const APPLICATION_FEE = ethers.utils.parseUnits("1.0", "ether");

describe("Landlord testing", function () {
  let instance;
  let provider = ethers.provider;
  let propertyOwners = [];
  let applicants = [];

  before("setup contract", async () => {
    const Roomilicious = await ethers.getContractFactory("Roomilicious");
    instance = await Roomilicious.deploy();
    await instance.deployed();
    let accounts = await ethers.getSigners();
    let contractOwner = accounts[0];

    for (let i = 1; i < accounts.length; i++) {
      if (i < 10) {
        propertyOwners.push(accounts[i]);
      } else {
        applicants.push(accounts[i]);
      }
    }

    // for (const account of propertyOwners)
    // {
    //   console.log("property owner: " + account.address + " balance :" + await provider.getBalance(account.address));
    // }

    // for (const account of applicants)
    // {
    //   console.log("applicant: " + account.address + " balance :" + await provider.getBalance(account.address));
    // }
  });

  after("clean up", async () => {
    // for (const account of propertyOwners)
    // {
    //   console.log("property owner: " + account.address + " balance :" + await provider.getBalance(account.address));
    // }
    // for (const account of applicants)
    // {
    //   console.log("applicant: " + account.address + " balance :" + await provider.getBalance(account.address));
    // }
  });

  it("Landlord - list property", async function () {
    await instance
      .connect(propertyOwners[0])
      .listProperty("1234 main street", { value: LISTING_FEE });
    await instance
      .connect(propertyOwners[1])
      .listProperty("5564 main street", { value: LISTING_FEE });
    var properties = await instance.getAllProperties();
    expect(properties.length).to.equal(2);
  });

  it("Housemate - apply to non existing house", async function () {
    debugger;
    var revert = false;

    try {
      let invalidPropertyID = 100;
      var properties = await instance.getAllProperties();
      let applicationID = 0;
      applicationID = await instance
        .connect(applicants[0])
        .applyToProperty(invalidPropertyID, { value: APPLICATION_FEE });
    } catch {
      revert = true;
    }
    expect(revert).to.equal(true);

  });

  it("Housemate - apply to rental", async function () {
    debugger;
    var properties = await instance.getAllProperties();
    let applicationID = 0;
    applicationID = await instance
      .connect(applicants[0])
      .applyToProperty(properties[0].ID, { value: APPLICATION_FEE });
    expect(applicationID).to.not.equal(0);
  });


  it("Housemate - apply to rental", async function () {
    debugger;
    var properties = await instance.getAllProperties();
    let applicationID = 0;
    applicationID = await instance
      .connect(applicants[0])
      .applyToProperty(properties[0].ID, { value: APPLICATION_FEE });
    expect(applicationID).to.not.equal(0);
  });










  // it("Should return the new greeting once it's changed", async function () {
  //   const Greeter = await ethers.getContractFactory("Greeter");
  //   const greeter = await Greeter.deploy("Hello, world!");
  //   await greeter.deployed();

  //   expect(await greeter.greet()).to.equal("Hello, world!");

  //   const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

  //   // wait until the transaction is mined
  //   await setGreetingTx.wait();

  //   expect(await greeter.greet()).to.equal("Hola, mundo!");
  // });
});
