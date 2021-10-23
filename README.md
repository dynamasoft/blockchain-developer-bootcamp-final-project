## Roomilicious

Introduction

Roomilicious is a secure house sharing platform marketplace. This platform helps the landlord market the property and tenants to find and share the living cost with compatible housemates. It gives the everyone a peace of mind in the rental process by ensuring that the deposit paid is safe and secure in the escrow account powered by blockchain technology.

Problem Statement

Rental process is a very complex process ranging from the house search, application process, payments and house mates compatibility.  On the top of this, there are many scammers who acted as a landlord to list fake profile and property to steal the applicant deposit. There are a huge lack of trust in this process begging for a better solution to ease the mind of both involved parties.

Solution

Roomilicious is a room sharing marketplace that leverages smart contract to keep the privacy of both tenant and landlord and at the same time ensuring the integrity of the rental process process. Roomilicous uses a multiparty concensus for the housemates compatibility. The deposit is stored in the smart contract and 100% guarantee to be returned when the applicant be rejected.

Scope of Project.TEST

1. Landlord lists a property for rent. 
2. Applicant applies to the property with application fee.
3. Roomilicious calls oracles to get credit and income information.
4. Renting Approval Process. 
5. If approved, applicant pays the deposit to secure the place.
6. If there more than 1 existing housemate, it will go through a multi party concensus.
7. If rejected, the deposit will be transfered back to the tenant, other wise the tenant is good to go to move in. 

![image](https://user-images.githubusercontent.com/11653682/137765650-96b574b0-1665-4d3f-981b-e9cc1a06717f.png)

Project Directory Structure
1. smart-contract
   this project is using hardhat, waffle and chai in my ethereum test framework.  This folder contains files and subfolders to write smart contract and for testing.
   Please following steps to run the test 
   1. Go to smart contract folder from the terminal
   2. npm install
   3. npx hardhat test

2. client
   this project is using react js as front end. To run locally please follow the steps below:
   1. Go to smart client folder from the terminal
   2. npm install
   3. npm start

   This project had also deployed to https://dynamasoft.github.io


3. server



------------------------------------------------- PROJECT RUBRIK DETAIL ---------------------------------------------------------------
questions here : https://courses.consensys.net/courses/take/blockchain-developer-bootcamp-registration-2021/assignments/27500647-final-project-submission
answers:
1. Front end can be access here: https://dynamasoft.github.io/blockchain-developer-bootcamp-final-project/

2. Information request is found in this page.

3. 2 design patterns used here are:
   1. Access Control using inheriting Ownable class
   2. Pausable
   3. Oracles to process the tenant income and credit score.

4. 3 security measures have been implemented in this contract
   1. Using specific compiler pragma 
   2. Using reentrancy guard
   3. Using modifier for validation
   4. Using pausable contract

5. 15 unit testing was done.

6. Deploy Contract Address: 0xE76E14297D76b4B83A675353c789D6a7a662273F
   https://ropsten.etherscan.io/address/0xE76E14297D76b4B83A675353c789D6a7a662273F

7. DAPP.

8. https://dynamasoft.github.io/blockchain-developer-bootcamp-final-project/

9. Readme file is included

10. Screencast. 



