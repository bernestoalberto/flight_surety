pragma solidity >=0.4.0 <0.6.0;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyData {
    using SafeMath for uint256;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner;                                      // Account used to deploy contract
    bool private operational = true;                                    // Blocks all state changes throughout the contract if false

        struct Flight {
        bool isRegistered;
        uint8 statusCode;
        uint256 updatedTimestamp;     
        address airline;
        uint8 price;
    }
    mapping(bytes32 => Flight) private flights;

    uint airlinesRegistered;
    uint flightsRegistered;
    struct Airline {
        uint registrationNumb;
        address airline;
        bool isFunded;
    }
    mapping(address => Airline) private airlines;

    struct PurchasedInsurance {
        uint256 purchaseAmount;
        address owner;
    }
    mapping(bytes32 => PurchasedInsurance) private insurance;


    struct Accounts {
        uint256 creditAmount;
    }
    mapping(address => Accounts) private account;

    struct NewAirline {
        uint votes;
    }
    mapping(address => NewAirline) private newAirline;

    struct TempStruct {
        uint tempInt;
    }
    mapping(address => TempStruct) private tempMap;

    struct TempStruct1 {
        address airline;
        uint statusCode;
        bool isRegistered;  
    }
    mapping(bytes32 => TempStruct1) private tempMap1;

    struct TempStruct2 {
        bool isRegistered;
        uint8 statusCode;
        uint256 updatedTimestamp;     
        address airline;

        //this works
        // address airline;
        // uint statusCode;

        //this works
        // address airline;
        // uint statusCode;
        // bool isRegistered;            
    }
    mapping(bytes32 => TempStruct2) private tempMap2;


    struct TempStruct3 {
        address temp0;
        bool temp1;
        bool temp2;   
        bool temp3;  
        bool temp4;   
        bool temp5;        
    }
    mapping(bytes32 => TempStruct3) private tempMap3;

    uint256 insuranceBalance;

    address initialAirline;

    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/


    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */
    constructor
                                (
                                   address airlineAddress 
                                ) 
                                public 
    {
        contractOwner = msg.sender;
           flightsRegistered = 0;
        airlinesRegistered = 0;
        initialAirline = airlineAddress;
        //registerAirline(airlineAddress);
        //contractOwner = appAddress;
    }

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in 
    *      the event there is an issue that needs to be fixed
    */
    modifier requireIsOperational() 
    {
        require(operational, "Contract is currently not operational");
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner()
    {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }
    
    //Modifier that checks if a flight exists
    modifier flightExists(bytes32 flight)
    {
        require(flights[flight].updatedTimestamp != 0, "Flight does not exist");
        _;
    }

    //Modifier that checks if a flight exists
    modifier isFundedBro()
    {
        require(airlines[msg.sender].isFunded == true, "Flight does not exist");
        _;
    }

    modifier hasVotes(address airlineAddress)
    {
        require(airlinesRegistered < 5 || newAirline[airlineAddress].votes >= airlinesRegistered.div(2), "Airline does not have enough votes");
        _;
    }

    //Modifier that checks if a submitted ether value is equal to 10 ether
    modifier requireEtherEqualTo10()
    {
        require(msg.value == 10 ether, "Ether required must be 10.");
        _;
    }


    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
    * @dev Get operating status of contract
    *
    * @return A bool that is the current operating status
    */      
    function isOperational() 
                            public 
                            view 
                            returns(bool) 
    {
        return operational;
    }


    /**
    * @dev Sets contract operations on/off
    *
    * When operational mode is disabled, all write transactions except for this one will fail
    */    
    function setOperatingStatus
                            (
                                bool mode
                            ) 
                            external
                            requireContractOwner 
    {
        operational = mode;
    }

     //Query whether flight is available
    function isFlightRegistered(bytes32 flight) view external returns (bool)
    {
        if (flights[flight].updatedTimestamp == 0) {
            return false;
        }   
        return true;
    }

    function processFlightStatus(address airline, string calldata flight, uint256 timestamp, uint8 statusCode)  external
    {
        //TODO
        //flights[flight].updatedTimestamp = 1;
    }
      //View insurance purchased for flight
    function viewInsurancePurchasedForFlight(bytes32 flight) public view returns(uint256)
    {
        uint256 amount = insurance[flight].purchaseAmount;
        return amount;
    }

    //View Credited Account Balance
    function viewCreditedAccount() view public returns(uint256)
    {
        address creditAddress = msg.sender;
        uint256 amount = account[creditAddress].creditAmount;
        return amount;
    }

 

    function returnInitialAirline() view external returns(address)
    {
        return initialAirline;
    }

    function returnAirlineFunded(address airline) view public returns(bool)
    {
        bool isFunded = airlines[airline].isFunded;
        return isFunded;
    }

    function returnAirlinesRegistered() view external returns(uint)
    {
        return airlinesRegistered;
    }
 

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

   /**
    * @dev Add an airline to the registration queue
    *      Can only be called from FlightSuretyApp contract
    *
    */   
   function registerAirline(address airlineAddress) external isFundedBro hasVotes(airlineAddress)
    {
        airlinesRegistered = airlinesRegistered.add(1);
        Airline memory _newAirline = Airline(airlinesRegistered,airlineAddress,false);
        airlines[airlineAddress] = _newAirline;
    }


    function getFlightPrice(bytes32 flightKey)
    external
    view
    returns (uint8)
    {
        uint8  price = flights[flightKey].price;
        return price;
    }


  function registerInitialAirline() external  
    {
        airlinesRegistered = airlinesRegistered.add(1);
        Airline memory __newAirline = Airline(airlinesRegistered,initialAirline,false);
        airlines[initialAirline] = __newAirline;
    }   

    function fundAirline() external payable requireEtherEqualTo10
    {
        airlines[msg.sender].isFunded = true;
        insuranceBalance = insuranceBalance.add(msg.value);
    }
   /**
    * @dev Buy insurance for a flight
    *
    */   
    function buy
                            (                             
                            )


                            external
                            payable
    {

    }


function isAirline(address airline) view public returns(bool) 
    {
        // airlines[airline].registrationNumb = 4;
        // return false;
        bool isValidAirline = false;
        if (airlines[airline].registrationNumb != 0)
        {
            isValidAirline = true;
        }

        return isValidAirline;         
    }

    function castVoteForNewAirline(address inewAirline) public isFundedBro  //need modifier to mkae sure votes doesn't get cast twice
    {
        if (newAirline[inewAirline].votes == 0)
        {
            NewAirline memory newAirlineEntry = NewAirline(1);
            newAirline[inewAirline] = newAirlineEntry;
        }
        else
        {
            newAirline[inewAirline].votes = newAirline[inewAirline].votes.add(1);
        }
    }

    function registerFlight(bytes32 flight, uint timeStamp,uint8 statusCode,address airlineAddress) requireIsOperational external
    {
        //works in test, not in dapp
        // Flight memory newFlight = Flight(true,statusCode,timeStamp,contractOwner);
        // flights[flight] = newFlight;
        // flightsRegistered = flightsRegistered.add(1);

        //works in dapp
        // TempStruct1 memory newThing = TempStruct1(airlineAddress,statusCode,true);
        // tempMap1[flight] = newThing;

        //does not work in dapp
        // TempStruct2 memory newFlight = TempStruct2(true,statusCode,timeStamp,contractOwner);
        // tempMap2[flight] = newFlight;
        // flightsRegistered = flightsRegistered.add(1);

        //works in dapp
        TempStruct3 memory newFlight = TempStruct3(airlineAddress,true,true,true,false,false);
        tempMap3[flight] = newFlight;
        flightsRegistered = flightsRegistered.add(1);

    }
    /**
     *  @dev Credits payouts to insurees
    */
    function creditInsurees
                                (
                                    bytes32 flight
                                )
                                external
                                returns(uint256)
    {
        address creditAddress = msg.sender;
        uint256 amount0 = insurance[flight].purchaseAmount.div(2);
        uint256 amount1 = insurance[flight].purchaseAmount;
        //uint256 returnAmount = amount0.add(amount1);
        account[creditAddress].creditAmount = amount1.add(amount0).add(account[creditAddress].creditAmount);
        return account[creditAddress].creditAmount;
    }
    

    /**
     *  @dev Transfers eligible payout funds to insuree
     *
    */
    function pay
                            (
                            )
                            external
                            
    {
        require(account[msg.sender].creditAmount > 0);
        uint256 prev = account[msg.sender].creditAmount;
         account[msg.sender].creditAmount = 0;
        insuranceBalance-= prev;
        msg.sender.transfer(prev);
    }

   /**
    * @dev Initial funding for the insurance. Unless there are too many delayed flights
    *      resulting in insurance payouts, the contract should be self-sustaining
    *
    */   
    function fund
                            (   
                            )
                            public
                            payable
    {
        insuranceBalance = msg.value;
    }

    function getFlightKey
                        (
                            address airline,
                            string memory flight,
                            uint256 timestamp
                        )
                        pure
                        internal
                        returns(bytes32) 
    {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    /**
    * @dev Fallback function for funding smart contract.
    *
    */
    function() 
                            external 
                            payable 
    {
        fund();
    }

  function test() public pure returns (bool)
    {
        return false;
    }

    function test1() external
    {
        flightsRegistered = flightsRegistered.add(50);
        //flightsRegistered = 50;
    }

    function test2() view external returns (uint256)
    {
        // noregistered = flightsRegistered;
        // return noregistered;
        return flightsRegistered;
    }

    function test3() pure external returns (bool)
    {
        return true;
    }
}

