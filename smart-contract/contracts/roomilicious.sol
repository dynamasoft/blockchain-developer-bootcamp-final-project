//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

/// @title Roomilicious - Housing sharing market place contract
/// @author Smith Tanny
/// @notice This contract manage the rental application and payment from both landlord and housemate. It also manage the approval of the applicant through a multi consensus approval.
/// @dev All function calls are currently implemented without side effects
contract Roomilicious {

uint256 constant LISTING_FEE = 1 ether;
uint256 constant APPLICATION_FEE = 1 ether;
    
    enum PropertyStatus
    {
        Pending,
        Listed
    }    

    struct Property
    {
        uint ID;
        string Address;     
        address Owner;           
        // uint TotalHousematesCount;
        // uint AvailableBedroom;        
         uint MonthlyRent;
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

    Property [] private PropertyList;
    mapping(uint => bool) private propertyIDs;
    //address [] PropertyListingKeys;

    struct Application
    {
        uint ID;
        uint PropertyID; 
        address Applicant;
        RentalStatus Status;
        uint MonthlyIncome;
        uint MonthlyRent;       
        uint CreditScore;
        // bool IsDepositPaid;
        // bool IsDepositReturned;
        // bool MeetMinQualification;
        // bool RequireMultiConsensus;
        // bool IsApproved;
        // uint256 ApplicationTimeStamp;    
        // uint256 MoveInTimeStamp;    
    }
    Application [] private ApplicationList;
    mapping(uint => bool) private ApplicationIDs;


/******************************************************************
MODIFIER
******************************************************************/
  
//   modifier isOwner() {
//         require(owner == msg.sender, "Caller is not the owner");
//         _;    
//     }

//     modifier paidEnough(uint256 _price) {
//         require(msg.value >= _price);
//         _;
//     }

modifier requireValidProperty(uint propertyID)
{
    require(propertyIDs[propertyID], "property does not exist");
    _;
}

modifier requireListingFee()
{
    require(msg.value == LISTING_FEE, "Listing fee amount is incorrect");
    _;
}

modifier requireApplicationFee()
{
    require(msg.value == APPLICATION_FEE, "Application fee amount is incorrect");
    _;
}

modifier requirePropertyOwner(uint propertyID)
{
     require(msg.sender == PropertyList[propertyID].Owner, "Must be the property owner to reject applicant");
    _;
}

/******************************************************************
EVENT
******************************************************************/
 event LogForListing(uint sku);
 event LogForApplicationReceived(uint sku);
 event LogForVerification(uint sku);
 event LogForApply(uint applicantID);
 event DeclineApplicantEvent(uint applicationID);
 //event InitateTenantResearchEvent(address account, uint monthlyRent);
 event StartRentalProcessEvent(address applicant);
 event MoveInEvent(uint applicationID);
 event TenantApprovedEvent(uint applicationID);
 event ApplicationCreatedEvent(uint applicationID);
 
 /******************************************************************
MAIN CODE
******************************************************************/
//constructor, I might be adding a seperate contract here to seperate the application logic from the data repository
    constructor() {        
    }

    /// @notice List the property by home owner
    /// @param propertyAddress address    
    function listProperty(string memory propertyAddress, uint rent) public 
    requireListingFee
    payable 
    returns (uint propertyID)    
    {        
        payable(this).transfer(msg.value);

        uint propertyID = PropertyList.length+1;

        PropertyList.push(Property({
            ID: propertyID,
            Address: propertyAddress, 
            Owner: msg.sender,           
            MonthlyRent:rent
        }));
        
        propertyIDs[propertyID] = true;
        return propertyID;
    }

   
    function getAllProperties() public view returns(Property [] memory)
    {
        return PropertyList;
      
    }

    function applyToProperty(uint propertyID, uint monthlyIncome)
    requireValidProperty(propertyID)
    requireApplicationFee
    payable
    public returns(uint applicationID)
    {
        uint applicationID = ApplicationList.length+1;
        uint monthlyRent = PropertyList[propertyID].MonthlyRent;

        ApplicationList.push(Application({
            ID: applicationID,
            PropertyID: propertyID,
            Applicant: msg.sender,
            MonthlyRent: monthlyRent,
            MonthlyIncome:monthlyIncome, //this will be filled up by oracles.            
            Status: RentalStatus.ApplicationCreated,
            CreditScore:0
        }));
        
        ApplicationIDs[applicationID] = true;   
        //console.log("from contract applicationID %s", applicationID);
        emit ApplicationCreatedEvent(applicationID);
    }

    function declineApplicant(uint applicationID) public
    {        
        ApplicationList[applicationID].Status = RentalStatus.Decline;
        emit DeclineApplicantEvent(applicationID);
    }

    function startRentalProcess(uint applicationID) public 
    {
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
    function submitTenantResearch(uint applicationID, uint creditScore) public returns (bool) 
    {
        ApplicationList[applicationID].CreditScore = creditScore;
        if(isQualified(applicationID) == true)
        {
            //go to multi concensus here.
        }
        return true;
    }

    function isQualified(uint applicationID) 
    private    
    returns(bool)
    {        
        ApplicationList[applicationID].Status = RentalStatus.MinQualificationApproved;
        emit TenantApprovedEvent(applicationID);
        return true;
    }

    //tenant move in, set the status to move in.
    function moveIn(uint applicationID) public
    {     
        ApplicationList[applicationID].Status = RentalStatus.MoveIn;
        emit MoveInEvent(applicationID);        
    }


    fallback() external payable {}
}


  // Property [] memory properties = new Property[](PropertyListingKeys.length);

        // console.log("there are '%s' currently listed", PropertyListingKeys.length);

        // for(uint i=1; i< PropertyListingKeys.length;i++)
        // {
        //     Property memory item = PropertyList[i];
        //     properties[i] = item;
        // }
        
        // return properties;