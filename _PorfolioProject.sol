// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Data {
    // Data types Constrcut and Mappings
 enum Status {NotExist, Pending, Approved, Rejected}
    struct landregistry {
    Status status;
    uint LandId; 
    string Area; 
    string  City; 
    string State; 
    uint LandPrice; 
    uint PropertyPID; 
    address payable currOwner;
  }
struct LandInspector {
 
    address Id; 
    string Name; 
    uint Age; 
    string Designation; 
}

struct Seller  {
    Status status;
    string Name; 
    uint Age; 
    string City; 
    string CNIC; 
    string Email; 
}

struct Buyer {
    Status status;
    string  Name; 
    uint  Age; 
    string  City; 
    string  CNIC; 
    string  Email;
}

    mapping(uint => landregistry) public lands; 
    mapping(address => LandInspector) public InspectorMapping; 
    mapping(address => Seller) public SellerMapping; 
    mapping(address => Buyer) public BuyerMapping; 
    mapping(address => bool) public isBuyerExist;
    mapping(address => bool) public isSellerExist;
    mapping(uint => bool) public isLandExist;
}


contract Conditions is Data {
       address public _owner;
// Conditional Checks, modifiers
   constructor() {
        _owner = msg.sender;
    }
        modifier onlyowner() {
        require( isOwnwer(),"you must be the contract Owner");
        _;
    }
    function isOwnwer() public view returns(bool) {
      return (msg.sender == _owner);
    }
    modifier isLandInspector(address _address) {
        require(InspectorMapping[_address].Id == _address, "Your are not authorized to perform this action");
        _;
    }
    modifier checkIfLandExist(uint _landId) {
         require(isLandExist[_landId],"this land doeen't exist");
         _;
    }


    event SellerAdded(string _name, uint _age, string city , string cnic , string email);
    event sellerUpdated(string _name, uint _age, string city , string cnic , string email);
    event LandAdded(uint landId, address owner);
    event BuyerAdded(string _name, uint _age, string city , string cnic , string email);
    event BuyerUpdated(string _name, uint _age, string city , string cnic , string email);

}






contract  LandRegistration is Conditions  {

//Logic functions

    function registerSeller(
        string memory _name, 
        uint _Age,
        string memory _city,
        string memory _CNIC ,
        string memory _email
    )
    public  
    {
   require( !isBuyerExist[msg.sender],
       "You already have Buyer Account with this address, try another address");
       if(!isSellerExist[msg.sender]){
        SellerMapping[msg.sender] = Seller(Status.Pending,_name,_Age,_city,_CNIC,_email); 
        isSellerExist[msg.sender] = true;
        emit SellerAdded(_name,_Age,_city,_CNIC,_email); 
       }else{
        SellerMapping[msg.sender].Name = _name;
        SellerMapping[msg.sender].Age = _Age;
        SellerMapping[msg.sender].City = _city;
        SellerMapping[msg.sender].CNIC = _CNIC;
        SellerMapping[msg.sender].Email = _email;
        emit sellerUpdated(_name,_Age,_city,_CNIC,_email);
     }
      

}
    function approveSellers(address _sellerAddress) public isLandInspector(msg.sender) 
        returns (bool)
    {
        require( isSellerExist[_sellerAddress],"this Seller does not exist");
        // require(userRoles[_newUser] != Role.Visitor);
        SellerMapping[_sellerAddress].status = Status.Approved;
        return true;
    }
    function addNewLand(
        uint _LandId,
        string memory _Area, 
        string memory  _City, 
        string memory _State, 
        uint _LandPrice, 
    uint _PropertyPID ) public {
        
        require(SellerMapping[msg.sender].status == Status.Approved, "you are not approved to add Land");
         lands[_LandId] = landregistry(Status.Pending, _LandId,_Area,  _City, _State, _LandPrice, _PropertyPID,payable(msg.sender));
         isLandExist[_LandId] = true;
         emit LandAdded(_LandId,msg.sender);

    }

    function approveLand(uint _landId) public isLandInspector(msg.sender) 
    checkIfLandExist(_landId)
     returns (bool) 
    {
        lands[_landId].status = Status.Approved;
        return true;
    }
    function RejectLand(uint _landId) public isLandInspector(msg.sender)
    checkIfLandExist(_landId)
    returns (bool)
    {
        lands[_landId].status = Status.Rejected;
        return true;
    }

    function checkSellerStatus(address _address) public view returns(string memory) {
          require(isSellerExist[_address], "this seller doesnt exist");
          return (SellerMapping[_address].status == Status.Approved ? "Approved"
         : (SellerMapping[_address].status == Status.Rejected) ? "Rejected" : "Pending");
    }

    function getLandDetails(uint _landId) public view returns(
        Status,
        uint,
        string memory,
        string memory,
        string memory,
        uint,
        uint
    ) {
      return ( lands[_landId].status,
        lands[_landId].LandId, 
        lands[_landId].Area, 
        lands[_landId].City, 
        lands[_landId].State, 
        lands[_landId].LandPrice, 
        lands[_landId].PropertyPID );
    }

    function checkLandOwner(uint _landId) public view returns(address) {
      return (
          lands[_landId].currOwner
      );
    }

    
    function registerBuyer(
        string memory _name, 
        uint _Age,
        string memory _city,
        string memory _CNIC ,
        string memory _email
    )
        public {
         require( !isSellerExist[msg.sender],"You already have Seller Account with this address, try another address");
         if(!isBuyerExist[msg.sender]){
            BuyerMapping[msg.sender] = Buyer(Status.Pending,_name,_Age,_city,_CNIC,_email); 
            isBuyerExist[msg.sender] = true;
            emit BuyerAdded(_name,_Age,_city,_CNIC,_email);      
          }
         else{
            BuyerMapping[msg.sender].Name = _name;
            BuyerMapping[msg.sender].Age = _Age;
            BuyerMapping[msg.sender].City = _city;
            BuyerMapping[msg.sender].CNIC = _CNIC;
            BuyerMapping[msg.sender].Email = _email;
            emit BuyerUpdated(_name,_Age,_city,_CNIC,_email);
           }
        }

    function approveBuyer(address _Buyeraddress) public isLandInspector(msg.sender)
        returns (bool)
        {
        require(isBuyerExist[_Buyeraddress],"this buyer doent exist");
        // require(userRoles[_newUser] != Role.Visitor);
        BuyerMapping[_Buyeraddress].status = Status.Approved;
            return true;
        }

    function checkBuyerStatus(address _address) public view returns(string memory) {
         
         require(isBuyerExist[_address], "this seller doesn't exist");
         return (BuyerMapping[_address].status == Status.Approved ? "Approved"
         : (BuyerMapping[_address].status == Status.Rejected) ? "Rejected" : "Pending");
        }




    function BuyLand(uint _landId) public checkIfLandExist(_landId) payable{
      require(
       lands[_landId].status == Status.Approved &&
       isBuyerExist[msg.sender] &&
       BuyerMapping[msg.sender].status == Status.Approved,
      "Either Buyer or Land doesnot exist or approved");

      require(lands[_landId].LandPrice == msg.value, "You must pay full amount");
      lands[_landId].currOwner = payable(msg.sender);
      lands[_landId].currOwner.transfer(msg.value);
      
    }



    function transferOwnerShip(address payable _address,uint _landId) public checkIfLandExist(_landId)  {
      
      require(lands[_landId].status == Status.Approved, "Your Property is not approved yet");
      lands[_landId].currOwner = _address;
    }



    function checkLandStatus(uint _landId) public view checkIfLandExist(_landId) returns(string memory) {
         return (lands[_landId].status == Status.Approved ? "Approved"
         :(lands[_landId].status == Status.Rejected) ? "Rejected"
         : "Pending");
    }


    function ContractOwnerInfo() public view returns(address){// Address of owner who has deployed the project
         return _owner;
    } 

   function getLandCity(uint _landId) public view checkIfLandExist(_landId)
    returns(string memory) {//City of given LandId
         return (lands[_landId].City);
    }

    function GetLandPrice(uint _landId) public view checkIfLandExist(_landId) returns(uint) { //To check the price of given LandId
         return(lands[_landId].LandPrice);
    } 

    function GetLandArea(uint _landId) public view checkIfLandExist(_landId) returns(string memory) {//To get Land Area of Specific landId;
         return(lands[_landId].Area);
    }

    function isBuyer(address _address) public view returns(string memory) {//To check if the address is in Buyer Mapping or Not
         return (isBuyerExist[_address] ? "true" : "false"); 
    } 

    function isSeller(address _address) public view returns(string memory) {//To check if this address exist in Seller Mapping or not
         return (isSellerExist[_address] ? "true" : "false");
    } 

    function AddLandInspector(//add as many landInspectors you wish
         address Id, 
         string memory Name, 
         uint Age, 
         string memory Designation

    ) public onlyowner {
         InspectorMapping[Id] = LandInspector(Id,Name,Age,Designation);
    }

}
