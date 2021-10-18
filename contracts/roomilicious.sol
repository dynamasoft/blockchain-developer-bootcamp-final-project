//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract roomilicious {
   
    string private greeting;

    constructor(string memory _greeting) {
        console.log("Deploying a Greeter with greeting:", _greeting);
        greeting = _greeting;
    }

    function listRoom() public payable returns (bool)
    {
        return true;
    }


    function postProfile() public payable returns (bool)
    {
        return true;
    }


    function submitDeposit() public payable returns (bool)
    {
        return true;
    }

    function refundDeposit() public returns (bool)
    {
        return true;
    }

    function fetchTenantQualification(address account) public 
    {
        return;
    }

    function submitTenantQualification(address account)  public  returns (bool)
    {
        return true;
    }

    function moveIn(address account)  public returns (bool)
    {
        return true;
    }

}
