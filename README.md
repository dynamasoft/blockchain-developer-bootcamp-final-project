## Roomilicious

Introduction

Roomilicious is a secure house sharing platform marketplace. This platform helps the landlord market their empty sparebedrooms and to find compatible housemates to share the home. The platform gives everyone the peace of mind in the rental process by ensuring that all party can transact safely powered by blockchain technology.

Problem Statement

Rental process is a very complex process ranging from the house search, application process, payments and finding the house mates compatibility.  On the top of this, there are many scammers who posted a fake property in behalf of the landlord to steal the applicant deposit fund. There are a huge lack of trust because of this in this rental process begging for a better solution to ease the mind of both involved parties.

Solution

Roomilicious is a room sharing marketplace that leverages smart contract to keep the privacy of both tenant and landlord and simultaneously ensuring the integrity of the rental process. On the top of this Roomilicous also uses a multiparty concensus for the housemates compatibility. Each existing roommate in the property to up or down vote the new housemate based on their preferences. The deposit is stored in the smart contract and 100% guarantee to be returned when the applicant is rejected.

Scope of Project

1. Landlord lists a property for rent. 
2. Applicant applies to the property with an application fee.
3. Landlord approves the property.
4. Roomilicious calls oracles to get credit and income information.
5. If approved, applicant pays the deposit to secure the place.

OUT OF SCOPE
6. If there more than 1 existing housemate, it will go through a multi party concensus.
7. If rejected, the deposit will be transfered back to the tenant, other wise the tenant is good to go to move in. 

![image](https://user-images.githubusercontent.com/11653682/137765650-96b574b0-1665-4d3f-981b-e9cc1a06717f.png)

Project Directory Structure
1. smart-contract
   This project uses hardhat, waffle and chai test framework.  This folder contains files and subfolders for write smart contract and testing.
   Please following steps to run the test 
   1. Go to smart contract folder from the terminal
   2. npm install
   3. npx hardhat test
   4. npx hardhat run scripts/deploy.js --network localhost
   5. npx hardhat node (if you want to test the dapp locally)


2. client
   this project is using react js as front end and ethers.js to connect to the blockchain. To run locally please follow the steps below:
   1. Go to smart client folder from the terminal
   2. npm install
   3. npm run build
   4. npm start

   ** Note if you want to test using local node without any interaction with metamask, go to app.js line
   
  const start = async () => {
    await contract.initialize(false);  <-- true for local interaction without metamask, or false for using metamask
    displayMessage("Contract initialized.");


   This project had also deployed to https://dynamasoft.github.io

3. server
   This is to run the oracle but currently is out of scope. Oracle is temporarily moved to the front end for the accessbility and testing.

------------------------------------------------- PROJECT RUBRIK DETAIL ---------------------------------------------------------------
questions here : https://courses.consensys.net/courses/take/blockchain-developer-bootcamp-registration-2021/assignments/27500647-final-project-submission
answers:
1. Front end can be access here: https://dynamasoft.github.io/blockchain-developer-bootcamp-final-project/

2. Information request is found in this page.

3. 2 design patterns used here are:
   1. Access Control using inheriting Ownable class
   2. Pausable
   3. Oracles to process the tenant income and credit score.
   more info can be found on the design_pattern_decisions.md

4. 3 security measures have been implemented in this contract
   1. Using specific compiler pragma 
   2. Using reentrancy guard
   3. Using modifier for validation   
   more info can be found on the avoiding_common_atack.md

5. 6 unit testing was done. The test is basically around creating a property, approve the applicant, get deposit and refund the deposit.

6. Network: Ropsten
   Deploy Contract Address: 0xE76E14297D76b4B83A675353c789D6a7a662273F
   https://ropsten.etherscan.io/address/0xE76E14297D76b4B83A675353c789D6a7a662273F

7. DAPP. Please look at contract.js
   Detect MetaMask: Yes
   Connects to the current account: Yes. Since there are 3 different parties in here ( smart contract creator, homeowner, and applicant), I made it easier for dapp test and allow 1 account to be used so simplify the demo.
   Displays information from your smart contract: PropertyID and ApplicationID
   Allows a user to submit a transaction to update smart contract state: Yes.
   Updates the frontend if the transaction is successful or not: Yes look at the process behind the scene.

8. https://dynamasoft.github.io/blockchain-developer-bootcamp-final-project/

9. Readme file is included

10. Screencast. can be found in here.




Some troubleshooting tips:
sometimes you might get an error that the nonce is too high, in this case, close your smart contract terminal and rerun the   npx hardhat node
