//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract roomilicious {
    enum RoommateRentalStatus {
        Search,
        Application,
        Verification,
        SystemApproval,
        RoommateApproval,
        Approved,
        MoveIn
    }

    /******************************************************************
MODIFIER
******************************************************************/

    modifier paidEnough(uint256 _price) {
        require(msg.value >= _price);
        _;
    }

    //constructor, I might be adding a seperate contract here to seperate the application logic from the data repository
    constructor() {}

    //constructor, I might be adding a seperate contract here to seperate the application logic from the data repository
    function listRoom() public payable returns (bool) {
        return true;
    }

    //housemate can post the profile to look for housing
    function postProfile() public payable returns (bool) {
        return true;
    }

    //applicant can submit deposit to secure the place
    function submitDeposit() public payable returns (bool) {
        return true;
    }

    //applicant can get the refund should the process is rejected
    function refundDeposit() public returns (bool) {
        return true;
    }

    //send requestapplicant can get the refund should the process is rejected
    function fetchTenantQualification(address account) public {
        return;
    }

    //oracles send the creditscore and income verification
    function submitTenantQualification(address account) public returns (bool) {
        return true;
    }

    //tenant move in, set the status to move in.
    function moveIn(address account) public returns (bool) {
        return true;
    }
}
