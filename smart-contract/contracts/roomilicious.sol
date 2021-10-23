//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @title Roomilicious - Housing sharing market for finding a perfect roommates
/// @author Smith Tanny
/// @notice This contract manages the rental application and payment from both landlord and housemate. It also manage the approval of the applicant through a multi sig consensus.
/// @dev All function calls are currently implemented without side effects
contract Roomilicious is Ownable, Pausable, ReentrancyGuard {


    /******************************************************************
        STATE VARIABLES DECLARATION
    ******************************************************************/

    uint constant LISTING_FEE = 1 wei;
    uint constant APPLICATION_FEE = 1 wei;    
    
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
        uint ID;
        string Address;
        address Owner;
        uint TotalHousemates;        
        uint MonthlyRent;
        ListingStatus Status;
    }  

    enum RentalStatus {
        ApplicationCreated,
        StartRentalProcess,
        MinQualificationApproved,
        MinQualificationRejected,
        Approved,        
        Decline,
        DepositPaid,
        Refunded,
        MoveIn
    }

    mapping(uint => Property) private PropertyList;
    uint [] private PropertyIDs;

    struct Application {
        uint ID;
        uint PropertyID;
        address Applicant;
        RentalStatus Status;
        uint MonthlyIncome;
        uint MonthlyRent;
        uint CreditScore;
        uint Deposit;
        // bool IsDepositPaid;
        // bool IsDepositReturned;
        // bool MeetMinQualification;
        // bool RequireMultiConsensus;
        // bool IsApproved;
        // uint ApplicationTimeStamp;
        // uint MoveInTimeStamp;
    }
    Application[] private ApplicationList;
    mapping(uint => bool) private ApplicationIDs;

    /******************************************************************
        MODIFIER
    ******************************************************************/
     /// @notice this modifier checks to make sure the property exists
    modifier requireValidProperty(uint propertyID) {
        //check if the object is null
        require(PropertyList[propertyID].Owner != address(0), "property does not exist");
        _;
    }

    /// @notice this modifier checks to make sure the property pay a fee before listing the property
    modifier requireValidFund(uint amount)
    {
        require(msg.value == amount, "invalid amount");
        _;
    }

    /// @notice this modifier checks to make sure only property owner can perform this action
    modifier requirePropertyOwner(uint propertyID) {        
        require(msg.sender == PropertyList[propertyID].Owner, "Must be the property owner to perform this action");
        _;
    }

    /// @notice this modifier checks to make sure only property a valid caller can perform this action
    modifier verifyCaller (address _address) 
    {
        require(msg.sender == _address); 
        _;
    }

    // @notice this modifier checks to make sure deposit has been paid
    modifier requireDepositPaid (uint applicationID) 
    {
        require(ApplicationList[applicationID].Deposit > 0,"no deposit has been paid"); 
        _;
    }
    

/******************************************************************
                    EVENTS
******************************************************************/
    event LogDeposit(address sender);
    event LogForListing(uint sku);
    event LogForApplicationReceived(uint sku);
    event LogForVerification(uint sku);
    event LogForApply(uint applicantID);
    event PropertyListedEvent(uint PropertyID);
    event PropertyApproveEvent(uint PropertyID);
    event PropertyRejectEvent(uint PropertyID);
    event DeclineApplicantEvent(uint applicationID);    
    event StartRentalProcessEvent(uint applicationID);
    event MoveInEvent(uint applicationID);
    event TenantApprovedEvent(uint applicationID);
    event ApplicationCreatedEvent(uint applicationID);
    event ApplicationApprovedEvent(uint applicationID);
    event ApplicationRejectedEvent(uint applicationID);
    event DepositPaidEvent(uint applicationID);
    event RefundDepositEvent(uint applicationID, uint deposit);           

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
        requireValidFund(LISTING_FEE)
        returns (uint propertyID)
    {        
        payable(this).transfer(msg.value);

        uint propertyID = PropertyIDs.length + 1;     
        PropertyList[propertyID] = 
            Property({
                ID: propertyID,
                Address: propertyAddress,
                Owner: msg.sender,
                MonthlyRent: rent,
                TotalHousemates : totalHousemates,
                Status: ListingStatus.Pending
            });        
        
        PropertyIDs.push(propertyID);
        //emit PropertyListedEvent(propertyID);
        return propertyID;
    }


    /// @notice Approve listing, only contract owner can do it to prevent scammer from listng fake properties
    /// @param propertyID ID of the property
    function approvePropertyListing(uint propertyID)
    //onlyOwner //disable for testing purposes
    public 
    {
        PropertyList[propertyID].Status = ListingStatus.Approved;
        emit PropertyApproveEvent(propertyID);
    }
    
    /// @notice Approve listing, only contract owner can do it to take fake property down
    /// @param propertyID ID of the property
    function rejectedPropertyListing(uint propertyID)
    //onlyOwner //disable for testing purposes
    public 
    {
        PropertyList[propertyID].Status = ListingStatus.Rejected;
        emit PropertyRejectEvent(propertyID);
    }

    /// @notice Get all the listed properties
    function getAllProperties() public view returns (Property[] memory) 
    {    
        Property [] memory properties = new Property[](PropertyIDs.length);        

         for(uint i=0; i< PropertyIDs.length;i++)
         {
            uint propertyID = PropertyIDs[i];            
            properties[i] = PropertyList[propertyID];            
         }

        return properties; 
    }

    /// @notice Allow housemates to apply to a property    
    function applyToProperty(uint propertyID, uint monthlyIncome)
        public
        payable
        requireValidProperty(propertyID)
        requireValidFund(APPLICATION_FEE)
        returns (uint applicationID)
    {
        uint applicationID = ApplicationList.length + 1;
        uint monthlyRent = PropertyList[propertyID].MonthlyRent;

        ApplicationList.push(
            Application({
                ID: applicationID,
                PropertyID: propertyID,
                Applicant: msg.sender,
                MonthlyRent: monthlyRent,
                MonthlyIncome: monthlyIncome, //this will be filled up by oracles.
                Status: RentalStatus.ApplicationCreated,
                CreditScore: 0,
                Deposit:0
            })
        );

        ApplicationIDs[applicationID] = true;        
        emit ApplicationCreatedEvent(applicationID);
    }

    /// @notice decline applicant for any reason.
    function declineApplicant(uint applicationID)
    requirePropertyOwner(ApplicationList[applicationID].PropertyID)    
    public {
        ApplicationList[applicationID].Status = RentalStatus.Decline;
        emit DeclineApplicantEvent(applicationID);
    }

    /// @notice interested in renting to applicant, so moving forward with the tenants background check
    function startRentalProcess(uint applicationID) 
    requirePropertyOwner(PropertyList[ApplicationList[applicationID].PropertyID].ID)    
    public {
        ApplicationList[applicationID].Status = RentalStatus.StartRentalProcess;
        console.log("calling StartRentalProcessEvent from the contract");
        emit StartRentalProcessEvent(applicationID);
    }

     /// @notice applicant can submit deposit to secure the place
    function payDeposit(uint applicationID) 
    public 
    whenNotPaused
    requireValidFund(PropertyList[ApplicationList[applicationID].PropertyID].MonthlyRent)
    nonReentrant
    payable 
    {
        ApplicationList[applicationID].Status = RentalStatus.DepositPaid;
        ApplicationList[applicationID].Deposit = msg.value;
        payable(this).transfer(msg.value);   
        emit DepositPaidEvent(applicationID);
    }

     /// @notice applicant can get the refund should the process is rejected . This utilize the Re-entrency guard pattern.
    function refundDeposit(uint applicationID) 
    requireDepositPaid(applicationID) 
    whenNotPaused     
    nonReentrant
    payable
    public         
    {
        //effect
        uint deposit = ApplicationList[applicationID].Deposit;
        ApplicationList[applicationID].Deposit = 0;     
        ApplicationList[applicationID].Status = RentalStatus.Refunded;

        //interaction
        payable(ApplicationList[applicationID].Applicant).transfer(msg.value);        
        emit RefundDepositEvent(applicationID, deposit);        
    }

    /// @notice in case of an attack, only owner can refund the deposit.
    function withdrawDeposityByOwner(uint applicationID) 
    requireDepositPaid(applicationID) 
    nonReentrant
    onlyOwner
    payable
    public         
    {
        //effect
        uint deposit = ApplicationList[applicationID].Deposit;
        ApplicationList[applicationID].Deposit = 0;     
        ApplicationList[applicationID].Status = RentalStatus.Refunded;

        //interaction
        payable(ApplicationList[applicationID].Applicant).transfer(msg.value);        
        emit RefundDepositEvent(applicationID, deposit);        
    }

    /// @notice oracles send the creditscore and income verification
    function submitTenantResearch(uint applicationID, bool passed)
        public
        returns (bool)
    {
        if(passed)
        {
            ApplicationList[applicationID].Status = RentalStatus.MinQualificationApproved;
            emit ApplicationApprovedEvent(applicationID);
        }
        else
        {
            ApplicationList[applicationID].Status = RentalStatus.MinQualificationRejected;
            emit ApplicationRejectedEvent(applicationID);
        }        
        return true;
    }   

    /// @notice Tenant is ready to move in 
    function moveIn(uint applicationID,  uint timestamp) public {
        ApplicationList[applicationID].Status = RentalStatus.MoveIn;
        emit MoveInEvent(applicationID);
    }

    /// @notice fallback function 
    fallback() external payable {
        require(msg.data.length == 0);
        emit LogDeposit(msg.sender);
    }
}
