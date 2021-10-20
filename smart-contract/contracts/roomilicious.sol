//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Roomilicious - Housing sharing market for finding a perfect roommates
/// @author Smith Tanny
/// @notice This contract manages the rental application and payment from both landlord and housemate. It also manage the approval of the applicant through a multi sig consensus.
/// @dev All function calls are currently implemented without side effects
contract Roomilicious is Ownable {


    /******************************************************************
        STATE VARIABLES DECLARATION
    ******************************************************************/

    uint256 constant LISTING_FEE = 1 ether;
    uint256 constant APPLICATION_FEE = 1 ether;    
    
    enum PropertyStatus {
        Pending,
        Rejected,
        Listed
    }
    
    enum ListingStatus 
    {
        Pending,
        Approved,
        Rejected        
    }

    struct Property {
        uint256 ID;
        string Address;
        address Owner;
        uint TotalHousemates;        
        uint256 MonthlyRent;
        ListingStatus Status;
    }  

    enum RentalStatus {
        ApplicationCreated,
        StartRentalProcess,
        MinQualificationApproved,
        MinQualificationRejected,
        Approved,
        Decline,
        MoveIn
    }

    Property[] private PropertyList;
    mapping(uint256 => bool) private propertyIDs;

    struct Application {
        uint256 ID;
        uint256 PropertyID;
        address Applicant;
        RentalStatus Status;
        uint256 MonthlyIncome;
        uint256 MonthlyRent;
        uint256 CreditScore;
        // bool IsDepositPaid;
        // bool IsDepositReturned;
        // bool MeetMinQualification;
        // bool RequireMultiConsensus;
        // bool IsApproved;
        // uint256 ApplicationTimeStamp;
        // uint256 MoveInTimeStamp;
    }
    Application[] private ApplicationList;
    mapping(uint256 => bool) private ApplicationIDs;

    /******************************************************************
        MODIFIER
    ******************************************************************/
     /// @notice this modifier checks to make sure the property exists
    modifier requireValidProperty(uint256 propertyID) {
        require(propertyIDs[propertyID], "property does not exist");
        _;
    }

    /// @notice this modifier checks to make sure the property pay a fee before listing the property
    modifier requireListingFee() {
        require(msg.value == LISTING_FEE, "Listing fee amount is incorrect");
        _;
    }

    /// @notice this modifier checks to make sure the housemate pay the application fee before applying to a property
    modifier requireApplicationFee() {
        require(
            msg.value == APPLICATION_FEE,
            "Application fee amount is incorrect"
        );
        _;
    }

    /// @notice this modifier checks to make sure only property owner can perform this action
    modifier requirePropertyOwner(uint256 propertyID) {
        require(
            msg.sender == PropertyList[propertyID].Owner,
            "Must be the property owner to perform this action"
        );
        _;
    }

    /// @notice this modifier checks to make sure only property a valid caller can perform this action
    modifier verifyCaller (address _address) 
    {
        require(msg.sender == _address); 
        _;
    }

/******************************************************************
                    EVENTS
******************************************************************/
    event LogDeposit(address sender);
    event LogForListing(uint256 sku);
    event LogForApplicationReceived(uint256 sku);
    event LogForVerification(uint256 sku);
    event LogForApply(uint256 applicantID);
    event PropertyApproveEvent(uint PropertyID);
    event PropertyRejectEvent(uint PropertyID);
    event DeclineApplicantEvent(uint256 applicationID);    
    event StartRentalProcessEvent(address applicant);
    event MoveInEvent(uint256 applicationID);
    event TenantApprovedEvent(uint256 applicationID);
    event ApplicationCreatedEvent(uint256 applicationID);

    /******************************************************************
        MAIN CODE
    ******************************************************************/    
    //this will also 
    constructor() 
    {     
    }

    /// @notice List the property by home owner
    /// @param propertyAddress address of the property, rent, and existing housemate
    function listProperty(string memory propertyAddress, uint rent, uint totalHousemates)
        public
        payable
        requireListingFee
        returns (uint256 propertyID)
    {
        payable(this).transfer(msg.value);

        uint256 propertyID = PropertyList.length + 1;

        PropertyList.push(
            Property({
                ID: propertyID,
                Address: propertyAddress,
                Owner: msg.sender,
                MonthlyRent: rent,
                TotalHousemates : totalHousemates,
                Status: ListingStatus.Pending
            })
        );

        propertyIDs[propertyID] = true;
        return propertyID;
    }


    /// @notice Approve listing, only contract owner can do it to prevent scammer from listng fake properties
    /// @param propertyID ID of the property
    function approvePropertyListing(uint propertyID)
    onlyOwner
    public 
    {
        PropertyList[propertyID].Status = ListingStatus.Approved;
        emit PropertyApproveEvent(propertyID);
    }
    
    /// @notice Approve listing, only contract owner can do it to take fake property down
    /// @param propertyID ID of the property
    function rejectedPropertyListing(uint propertyID)
    onlyOwner
    public 
    {
        PropertyList[propertyID].Status = ListingStatus.Rejected;
        emit PropertyRejectEvent(propertyID);
    }

    /// @notice Get all the listed properties
    function getAllProperties() public view returns (Property[] memory) {
        return PropertyList;
    }

    /// @notice Allow housemates to apply to a property    
    function applyToProperty(uint256 propertyID, uint256 monthlyIncome)
        public
        payable
        requireValidProperty(propertyID)
        requireApplicationFee
        returns (uint256 applicationID)
    {
        uint256 applicationID = ApplicationList.length + 1;
        uint256 monthlyRent = PropertyList[propertyID].MonthlyRent;

        ApplicationList.push(
            Application({
                ID: applicationID,
                PropertyID: propertyID,
                Applicant: msg.sender,
                MonthlyRent: monthlyRent,
                MonthlyIncome: monthlyIncome, //this will be filled up by oracles.
                Status: RentalStatus.ApplicationCreated,
                CreditScore: 0
            })
        );

        ApplicationIDs[applicationID] = true;        
        emit ApplicationCreatedEvent(applicationID);
    }

    /// @notice decline applicant for any reason.
    function declineApplicant(uint256 applicationID)
    requirePropertyOwner(PropertyList[ApplicationList[applicationID]].PropertyID)    
    public {
        ApplicationList[applicationID].Status = RentalStatus.Decline;
        emit DeclineApplicantEvent(applicationID);
    }

    /// @notice interested in renting to applicant, so moving forward with the tenants background check
    function startRentalProcess(uint256 applicationID) 
    requirePropertyOwner(PropertyList[ApplicationList[applicationID]].PropertyID)    
    public {
        ApplicationList[applicationID].Status = RentalStatus.StartRentalProcess;
        emit StartRentalProcessEvent(ApplicationList[applicationID].Applicant);
    }

    //applicant can submit deposit to secure the place
    function submitDeposit() public payable returns (bool) {
        return true;
    }

    //applicant can get the refund should the process is rejected
    function refundDeposit() public returns (bool) {
        return true;
    }

    //oracles send the creditscore and income verification
    function submitTenantResearch(uint256 applicationID, uint256 creditScore)
        public
        returns (bool)
    {
        ApplicationList[applicationID].CreditScore = creditScore;
        if (isQualified(applicationID) == true) {
            //go to multi concensus here.
        }
        return true;
    }

    function isQualified(uint256 applicationID) private returns (bool) {
        ApplicationList[applicationID].Status = RentalStatus
            .MinQualificationApproved;
        emit TenantApprovedEvent(applicationID);
        return true;
    }

    //tenant move in, set the status to move in.
    function moveIn(uint256 applicationID) public {
        ApplicationList[applicationID].Status = RentalStatus.MoveIn;
        emit MoveInEvent(applicationID);
    }

    fallback() external payable {
        require(msg.data.length == 0);
        emit LogDeposit(msg.sender);
    }
}

// Property [] memory properties = new Property[](PropertyListingKeys.length);

// console.log("there are '%s' currently listed", PropertyListingKeys.length);

// for(uint i=1; i< PropertyListingKeys.length;i++)
// {
//     Property memory item = PropertyList[i];
//     properties[i] = item;
// }

// return properties;
