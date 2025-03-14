pragma solidity >=0.4.16 <0.7.0;

contract Paylock {
    
    enum State { Working , Completed , Done_1 , Delay , Done_2 , Forfeit }
    
    int disc;
    State st;
    int clock; // Added clock variable to track time units
    int collect_1_N_time; // Track when collect_1_N was called
    address timeAdd;
    
    constructor(address _timeAdd) public {
        st = State.Working;
        disc = 0;
        clock = 0; // Initialize clock in the constructor
        collect_1_N_time = -1;
        timeAdd = _timeAdd;
    }

    function signal() public {
        require( st == State.Working, "Signal can only be called when in Working state." );
        st = State.Completed;
        disc = 10;
    }

    function collect_1_Y() public {
        require( st == State.Completed && clock < 4, "Collect_1_Y can only be called if in Completed state and before 4 time units." );
        st = State.Done_1;
        disc = 10;
    }

    function collect_1_N() external {
        require( st == State.Completed && clock >= 4, "Collect_1_N can only be called if in Completed state and at least 4 time units have passed." );
        st = State.Delay;
        disc = 5;
        collect_1_N_time = clock; // Set the time when collect_1_N is called
    }

    function collect_2_Y() external {
        require( st == State.Delay && (clock - collect_1_N_time) < 4, "Collect_2_Y can only be called if in Delay state and less than 4 time units have passed since Collect_1_N." );
        st = State.Done_2;
        disc = 5;
    }

    function collect_2_N() external {
        require( st == State.Delay && (clock - collect_1_N_time) >= 4, "Collect_2_N can only be called if in Delay state and 4 or more time units have passed since Collect_1_N." );
        st = State.Forfeit;
        disc = 0;
    }

    function tick() public {
        require(msg.sender == timeAdd, "Only the designated address can increment the clock.");
        clock += 1; // Increment the clock by 1 unit
    }
}

contract Supplier {

    Paylock p;
    Rental r; // Added a variable for the Rental contract instance
    bool acquire_called;
    uint public deposit = 1 wei;
    enum State { Working , Completed }
    event Received(address, uint);
    State st;
    
    constructor(address pp, address payable rr) public payable {
        p = Paylock(pp);
        st = State.Working;
        acquire_called = false;
        r = Rental(rr);
    }

    receive() external payable {
        uint leftover = address(r).balance;
        if (leftover >= 1) {
               r.retrieve_resource();
        }
        emit Received(msg.sender, msg.value);
    }

    function acquire_resource() external payable {
        require(acquire_called == false, "Resource has already been acquired.");
        r.rent_out_resource.value(msg.value)();
        acquire_called = true;
    }

    function return_resource() external {
        require(acquire_called == true, "Resource must be acquired before it can be returned.");
        r.retrieve_resource();
        acquire_called = false;
    }
    
    function finish() external {
        require (st == State.Working);
        p.signal();
        st = State.Completed;
    }

    function get_balance() public view returns (uint256) {
        return address(this).balance;
    }
    
}

contract Rental {
    
    address payable resource_owner;
    bool resource_available;

    uint public deposit = 1 wei;
    
    constructor() public payable {
        resource_available = true;
    }

    // To allow the contract to receive Ether
    receive() external payable {}
    
    function rent_out_resource() external payable {
        require(resource_available == true);
        //CHECK FOR PAYMENT HERE
        require(msg.value == deposit, "Insufficient payment for the resource.");
        resource_owner = msg.sender;
        resource_available = false;
    }

    function retrieve_resource() external {
        require(resource_available == false && msg.sender == resource_owner);
        //RETURN DEPOSIT HERE
        (bool success, ) = resource_owner.call.value(deposit)("");
        require(success, "Failed to return deposit");
        resource_available = true;
    }

    function get_balance() public view returns (uint256) {
        return address(this).balance;
    }

}