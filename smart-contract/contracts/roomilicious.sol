//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

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

    uint constant LISTING_FEE = 1 ether;
    uint constant APPLICATION_FEE = 1 ether;    
    
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
        DepositPaid,
        Decline,
        MoveIn
    }

    Property[] private PropertyList;
    mapping(uint => bool) private propertyIDs;

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
    modifier requireDeposit(uint propertyID) {
        require(msg.value == PropertyList[propertyID].MonthlyRent,"Deposit amount is incorrect");
        _;
    }

    /// @notice this modifier checks to make sure only property owner can perform this action
    modifier requirePropertyOwner(uint propertyID) {
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

    /// @notice this modifier checks to make sure deposit has been paid
    // modifier requireDepositPaid (uint applicationID) 
    // {
    //     require(Application[applicationID].DepositPaid > 0,"no deposit has been paid"); 
    //     _;
    // }
    

/******************************************************************
                    EVENTS
******************************************************************/
    event LogDeposit(address sender);
    event LogForListing(uint sku);
    event LogForApplicationReceived(uint sku);
    event LogForVerification(uint sku);
    event LogForApply(uint applicantID);
    event PropertyApproveEvent(uint PropertyID);
    event PropertyRejectEvent(uint PropertyID);
    event DeclineApplicantEvent(uint applicationID);    
    event StartRentalProcessEvent(address applicant);
    event MoveInEvent(uint applicationID);
    event TenantApprovedEvent(uint applicationID);
    event ApplicationCreatedEvent(uint applicationID);
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
        requireListingFee
        returns (uint propertyID)
    {
        payable(this).transfer(msg.value);

        uint propertyID = PropertyList.length + 1;

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
    function applyToProperty(uint propertyID, uint monthlyIncome)
        public
        payable
        requireValidProperty(propertyID)
        requireApplicationFee
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
    requirePropertyOwner(PropertyList[ApplicationList[applicationID].PropertyID].ID)    
    public {
        ApplicationList[applicationID].Status = RentalStatus.Decline;
        emit DeclineApplicantEvent(applicationID);
    }

    /// @notice interested in renting to applicant, so moving forward with the tenants background check
    function startRentalProcess(uint applicationID) 
    requirePropertyOwner(PropertyList[ApplicationList[applicationID].PropertyID].ID)    
    public {
        ApplicationList[applicationID].Status = RentalStatus.StartRentalProcess;
        emit StartRentalProcessEvent(ApplicationList[applicationID].Applicant);
    }

     /// @notice applicant can submit deposit to secure the place
    function submitDeposit(uint applicationID) 
    public 
    whenNotPaused
    //requireDeposit(Application[applicationID].PropertyID)
    nonReentrant
    payable 
    {
        ApplicationList[applicationID].Status = RentalStatus.DepositPaid;
        ApplicationList[applicationID].Deposit = msg.value;
        payable(this).transfer(msg.value);   
    }

     /// @notice applicant can get the refund should the process is rejected . This utilize the Re-entrency guard pattern.
    function refundDeposit(uint applicationID) 
    //requireDepositPaid(applicationID) 
    whenNotPaused 
    nonReentrant
    public         
    {
        uint deposit = Application[applicationID].Deposit;
        Application[applicationID].Deposit = 0;        
        Application[applicationID].Status = RentalStatus.Refunded;
        Application[applicationID].Applicant.transfer(msg.value);        
        RefundDepositEvent(applicationID, deposit);        
    }

    /// @notice oracles send the creditscore and income verification
    function submitTenantResearch(uint applicationID, uint creditScore)
        public
        returns (bool)
    {
        ApplicationList[applicationID].CreditScore = creditScore;
        if (isQualified(applicationID) == true) 
        {
            //go to multi concensus here.
        }
        return true;
    }

    /// @notice Is the tenant qualified for rental
    function isQualified(uint applicationID) private returns (bool) 
    {
        ApplicationList[applicationID].Status = RentalStatus
            .MinQualificationApproved;
        emit TenantApprovedEvent(applicationID);
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
