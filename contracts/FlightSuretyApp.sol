pragma solidity >=0.4.24;

// It's important to avoid vulnerabilities due to numeric overflow bugs
// OpenZeppelin's SafeMath library, when used correctly, protects agains such bugs
// More info: https://www.nccgroup.trust/us/about-us/newsroom-and-events/blog/2018/november/smart-contract-insecurity-bad-arithmetic/

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

/************************************************** */
/* FlightSurety Smart Contract                      */
/************************************************** */
contract FlightSuretyApp {
    using SafeMath for uint256; // Allow SafeMath functions to be called for all uint256 types (similar to "prototype" in Javascript)

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    //Operation variables
    uint constant M = 3; //Number of confirmations require to stop operation
    bool private operational = true;            // Blocks all state changes throughout the contract if false
    address[] multiCalls = new address[](0);

    address private contractOwner;          // Account used to deploy contract
    FlightSuretyData flightSuretyData;

    // Flight status codees
    uint8 private constant STATUS_CODE_UNKNOWN = 0;
    uint8 private constant STATUS_CODE_ON_TIME = 10;
    uint8 private constant STATUS_CODE_LATE_AIRLINE = 20;
    uint8 private constant STATUS_CODE_LATE_WEATHER = 30;
    uint8 private constant STATUS_CODE_LATE_TECHNICAL = 40;
    uint8 private constant STATUS_CODE_LATE_OTHER = 50;

    // Fee to be paid when registering airline
    uint256 public constant REGISTRATION_FEE_AIRLINES = 10 ether;

    // Maximum insurance fee that can be accepted
    uint256 public constant MAX_INSURANCE_PASSENGER = 1 ether;

    // Number of airlines that can register before consensus requirement
    uint256 public constant AIRLINE_NUM_BEFORE_CONS = 4;
    address[] consensusVotes = new address[](0); //Array to record votes for Consensus

    struct Flight {
        bool isRegistered;
        uint8 statusCode;
        uint256 updatedTimestamp;        
        address airline;
        string flightNumber;
    }
    mapping(bytes32 => Flight) private flights;

    /********************************************************************************************/
    /*                                       Events                                             */
    /********************************************************************************************/
    event AirlineRegistered(address _airline); //Event triggered when Airline is Registered
    event AirlineFunded(address _airline); //Event triggered when Airline is Funded
    event InsureesCredited(string _flightNumber); //Event triggered when Passenger is paid insurance
    event PassengerInsured(); //Event triggered when passenger purchases insurance
    event FlightRegistered(string _flight);//Event triggered when flight is registered

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
         // Modify to call data contract's status
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

    /**
    * @dev Modifier that requires the flight to be registered before it can be insured
    */
    modifier requireIsFlightRegistered(address airline, string memory flight, uint time)
    {
        require(isFlightRegistered(airline, flight, time) == true, "Flight is not insured");
        _;
    }

    /********************************************************************************************/
    /*                                       CONSTRUCTOR                                        */
    /********************************************************************************************/

    /**
    * @dev Contract constructor
    *
    */
    constructor(address dataContract) public 
    {
        contractOwner = msg.sender;
        flightSuretyData = FlightSuretyData(dataContract);
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    function isOperational() 
                            public 
                            view 
                            returns(bool) 
    {
        return operational;  // Modify to call data contract's status
    }

    function isFlightRegistered
        (
            address airline, 
            string memory flight, 
            uint timestamp
        ) 
        public 
        view 
        returns(bool) 
    {
        bytes32 key = getFlightKey(airline, flight, timestamp);
        return flights[key].isRegistered;  // Modify to call data contract's status
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
        requireIsOperational
    {
        require(mode != operational, "New mode must be different from existing mode");
        require(flightSuretyData.isFunded(msg.sender), "Caller is not a funded airline.");

        bool isDuplicate = false;
        for(uint c=0; c<multiCalls.length; c++) {
            if (multiCalls[c] == msg.sender) {
                isDuplicate = true;
                break;
            }
        }
        require(!isDuplicate, "Caller has already called this function.");

        multiCalls.push(msg.sender);
        if (multiCalls.length >= M) {
            operational = mode;      
            multiCalls = new address[](0);      
        }
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

  
   /**
    * @dev Add an airline to the registration queue
    *
    */   
     function registerAirline
        (
            address _airline
        ) 
        requireIsOperational        
        external 
    {
        //Check how many airlines registered
        uint256 number = flightSuretyData._getRegisteredAirlinesNum();

        bool register = true;
        //success = false;
        uint votes = 0;

        // if number of airlines registered is greater than 4 perform the consensus check
        if(number >= AIRLINE_NUM_BEFORE_CONS){
            //check if caller is a registered airlines
            bool isRegistered = flightSuretyData.isRegistered(msg.sender);
            require(isRegistered == true, "Caller is not a registered airline");

            bool isDuplicate = false;
            register = false;
            for(uint c = 0; c < consensusVotes.length; c++) {
                if (consensusVotes[c] == msg.sender) {
                    isDuplicate = true;
                    break;
                }
            }
            require(!isDuplicate, "Caller has already called this function.");

            consensusVotes.push(msg.sender);
            votes = consensusVotes.length;
            uint check = number.div(2);
            if (votes >= check) {
                register = true;      
                consensusVotes = new address[](0);      
            }
          
        }
          
        if(register == true) {
            flightSuretyData.registerAirline(_airline, msg.sender);
            emit AirlineRegistered(_airline);
        }
        
    } 

    /**
    * @dev Initial funding for the insurance. Unless there are too many delayed flights
    *      resulting in insurance payouts, the contract should be self-sustaining
    *
    */   
    function fund () external payable requireIsOperational
    {
        require(msg.value == REGISTRATION_FEE_AIRLINES, "Not enough Ether to fund airline. Requires 10 ETH" );
        require(flightSuretyData.isFunded(msg.sender) == false, "Airline is already funded");
        flightSuretyData.fund(REGISTRATION_FEE_AIRLINES, msg.sender);
        address(flightSuretyData).transfer(REGISTRATION_FEE_AIRLINES);
        emit AirlineFunded(msg.sender);
    }

    
   /**
    * @dev Register a future flight for insuring.
    *
    */  
    function registerFlight
        (
            uint256 time,  
            address _airline,
            string flightNumber
        ) 
        external 
        requireIsOperational
    {
        require(isFlightRegistered(_airline, flightNumber, time) == false, "This flight is already registered");
        bytes32 key = getFlightKey(_airline, flightNumber, time);
        flights[key] = Flight({isRegistered: true, statusCode: STATUS_CODE_UNKNOWN, updatedTimestamp: time, airline: _airline, flightNumber: flightNumber});
        emit FlightRegistered(flightNumber);
    }

    /**
    * @dev Insure passenger for a future flight.
    *
    */  
    function insurePassenger
        (
            string flight,
            uint256 time,
            address airline,
            address passenger
        )
    external
    payable
    requireIsOperational
    //requireIsFlightRegistered(airline, flight, time)
    {
        require(msg.value <= MAX_INSURANCE_PASSENGER, "Passengers can pay a max of 1 ETH");
        address(flightSuretyData).transfer(msg.value);
        flightSuretyData.buy(flight, time, passenger, msg.sender, msg.value);
        emit PassengerInsured();
    }
    
   /**
    * @dev Called after oracle has updated flight status
    *
    */  
    function processFlightStatus
        (
            string memory flight,
            uint8 statusCode
        )
        internal
    {
        if(statusCode == STATUS_CODE_LATE_AIRLINE){
            //flightSuretyData.creditInsurees(flight);
            address[] memory passengers = flightSuretyData.getPassengersInsured(flight);
            uint amount = 0;
            address passenger;
            uint index;
            //passengers = flightSuretyData.FlightPassengers[flight];

            for(uint i = 0; i < passengers.length; i++){
                passenger = passengers[i];
                amount = flightSuretyData.GetInsuredAmount(flight, passenger);
                amount = amount.mul(15).div(10);
                flightSuretyData.SetInsuredAmount(flight, passenger, amount); 
            } 
            emit InsureesCredited(flight);
        }
    }
     function claimFlightInsurance () public {
        var (status, passenger, timeStamp, airlineName, price) = flightsuretydata.getFlightInsurance(msg.sender);
        if(keccak256(status) == keccak256(ACTIVE)){
            uint8 flightStatus = STATUS_CODE_LATE_AIRLINE;
            if(flightStatus == STATUS_CODE_LATE_AIRLINE){
                flightSuretyData.addCreditToPassenger(msg.sender, SafeMath.div( SafeMath.mul(3,price),2));
                flightSuretyData.setFlightInsuranceStatus(msg.sender, INACTIVE_FLIGHT_DELAYED);
            }
            else if (now < timeStamp){
                flightSuretyData.setFlightInsuranceStatus(msg.sender, INACTIVE_EXPIRED);
            }
        }
    }

    /**
    * @dev Called when passenger wants to withdraw insurance payout
    *
    */  
    function withdrawPayout() external
    {
        flightSuretyData.withdraw(msg.sender);
    }

    /**
    * @dev Called when passenger wants to withdraw insurance payout
    *
    */  
    function getFlightsInsured
        (
            address passenger, 
            string flight
        ) 
        external 
        returns
        (
            bool status
        )
    {
        status = flightSuretyData.getFlightsInsured(passenger, flight);
    }

    function getFlightAmountInsured
        (
            string flight
        )
        external 
        view
        returns
        (
            uint amount
        )
    {
        amount = flightSuretyData.getFlightAmountInsured(flight);
    }

    function getPassengerCredits
        (
            address passenger
        )
        external
        view
        requireIsOperational
        returns
        (
            uint amount
        )
    {
        return flightSuretyData.getPassengerCredits(passenger);
    }


    // Generate a request for oracles to fetch flight information
    function fetchFlightStatus
        (
            address airline,
            string  flight,
            uint256 timestamp                            
        )
        external
    {
        uint8 index = getRandomIndex(msg.sender);

        // Generate a unique key for storing the request
        bytes32 key = keccak256(abi.encodePacked(index, airline, flight, timestamp));
        oracleResponses[key] = ResponseInfo({requester: msg.sender, isOpen: true});

        emit OracleRequest(index, airline, flight, timestamp);
    } 

    //Returns Contract Balance
    function getContractBalance() external view returns(uint balance)
    {
        return flightSuretyData.getContractBalance();
    }

    
// region ORACLE MANAGEMENT

    // Incremented to add pseudo-randomness at various points
    uint8 private nonce = 0;    

    // Fee to be paid when registering oracle
    uint256 public constant REGISTRATION_FEE = 1 ether;

    // Number of oracles that must respond for valid status
    uint256 public constant MIN_RESPONSES = 3;

    struct Oracle {
        bool isRegistered;
        uint8[3] indexes;        
    }

    // Track all registered oracles
    mapping(address => Oracle) public oracles;

    // Model for responses from oracles
    struct ResponseInfo {
        address requester;                              // Account that requested status
        bool isOpen;                                    // If open, oracle responses are accepted
        mapping(uint8 => address[]) responses;          // Mapping key is the status code reported
                                                        // This lets us group responses and identify
                                                        // the response that majority of the oracles
    }

    // Track all oracle responses
    // Key = hash(index, flight, timestamp)
    mapping(bytes32 => ResponseInfo) private oracleResponses;

    // Event fired each time an oracle submits a response
    event FlightStatusInfo(address airline, string flight, uint256 timestamp, uint8 status);

    event OracleReport(address airline, string flight, uint256 timestamp, uint8 status);

    // Event fired when flight status request is submitted
    // Oracles track this and if they have a matching index
    // they fetch data and submit a response
    event OracleRequest(uint8 index, address airline, string flight, uint256 timestamp);
    event OracleRegistered(address oracle);


    // Register an oracle with the contract
    function registerOracle() external payable
    {
        // Require registration fee
        require(msg.value >= REGISTRATION_FEE, "Registration fee is required");

        uint8[3] memory indexes = generateIndexes(msg.sender);

        oracles[msg.sender] = Oracle({isRegistered: true, indexes: indexes});

        emit OracleRegistered(msg.sender);
    }

    function getMyIndexes
        (
        )
        view
        external
        returns(uint8[3] memory)
    {
        require(oracles[msg.sender].isRegistered, "Not registered as an oracle");

        return oracles[msg.sender].indexes;
    }

    // Called by oracle when a response is available to an outstanding request
    // For the response to be accepted, there must be a pending request that is open
    // and matches one of the three Indexes randomly assigned to the oracle at the
    // time of registration (i.e. uninvited oracles are not welcome)
    function submitOracleResponse
        (
            uint8 index,
            address airline,
            string  flight,
            uint256 timestamp,
            uint8 statusCode
        )
        external
    {
        require((oracles[msg.sender].indexes[0] == index) || (oracles[msg.sender].indexes[1] == index) || (oracles[msg.sender].indexes[2] == index), "Index does not match oracle request");

        bytes32 key = keccak256(abi.encodePacked(index, airline, flight, timestamp)); 
        require(oracleResponses[key].isOpen, "Flight or timestamp do not match oracle request");

        oracleResponses[key].responses[statusCode].push(msg.sender);

        // Information isn't considered verified until at least MIN_RESPONSES
        // oracles respond with the *** same *** information
        emit OracleReport(airline, flight, timestamp, statusCode);
        if (oracleResponses[key].responses[statusCode].length >= MIN_RESPONSES) {

            emit FlightStatusInfo(airline, flight, timestamp, statusCode);

            // Handle flight status as appropriate
            processFlightStatus(flight, statusCode);
        }
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

    // Returns array of three non-duplicating integers from 0-9
    function generateIndexes
        (                       
            address account         
        )
        public
        returns
        (
            uint8[3] memory
        )
    {
        uint8[3] memory indexes;
        indexes[0] = getRandomIndex(account);
        
        indexes[1] = indexes[0];
        while(indexes[1] == indexes[0]) {
            indexes[1] = getRandomIndex(account);
        }

        indexes[2] = indexes[1];
        while((indexes[2] == indexes[0]) || (indexes[2] == indexes[1])) {
            indexes[2] = getRandomIndex(account);
        }

        return indexes;
    }

    // Returns array of three non-duplicating integers from 0-9
    function getRandomIndex
        (
            address account
        )
        public
        returns (uint8)
    {
        uint8 maxValue = 10;

        // Pseudo random number...the incrementing nonce adds variation
        uint8 random = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - nonce++), account))) % maxValue);

        if (nonce > 250) {
            nonce = 0;  // Can only fetch blockhashes for last 256 blocks so we adapt
        }

        return random;
    }

// endregion

}   

contract FlightSuretyData {
    function registerAirline (address _airline, address caller) external;
    function _getRegisteredAirlinesNum() external returns(uint number);
    function fund (uint256 fundAmt, address sender) public;
    function creditInsurees (string  flight) external;
    function flightsuretydata.getFlightInsurance(address owner_) public return (Passenger _passenger)
    function isRegistered(address _airline) public returns(bool _reg);
    function isFunded(address _airline) public returns(bool _reg);
    function buy(string  flight, uint256 time, address passenger, address sender, uint256 amount) public;
    function withdraw(address payee) external payable;
    function getFlightsInsured(address passenger, string flight) external returns(bool status);
    function getFlightAmountInsured(string flight) external view returns(uint amount) ;
    function getPassengerCredits(address passenger) external view returns(uint amount);
    function getContractBalance() external view returns(uint balance);
    function getPassengersInsured(string  flight) external returns(address[] passengers);
    function GetInsuredAmount(string  flight, address passenger) external returns(uint amount);
    function SetInsuredAmount(string  flight, address passenger, uint amount) external;
}