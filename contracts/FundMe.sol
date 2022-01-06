// Exemplary crypto crowdfunding application!

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Brownie can download from github, but not npm!
// We need to add a remapping in the brownie-config.yaml file
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    // With this we can see how much an address has funded
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address owner;
    AggregatorV3Interface public priceFeed;

    // constructor specifies precisely how to initialise the contract and always runs on initialisation
    constructor(address _priceFeed) {
        // With this the owner is whoever creates the smart contract!
        owner = msg.sender;
        // Depending on whether we are running on a local chain or a test or main network the functionality changes
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    // This gives funds to the smart contract
    function fund() public payable {
        // Set minumum value of fund at $50
        uint256 minimumUSD = 50 * 10**18;
        require(
            getConversionRate(msg.value) >= minimumUSD,
            "Insufficient funding amount, minimum $50."
        );
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        // , denote unused tuple variables. They are just used so that they can be filled, but not used.
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        // To normalise between wei, gwei etc we can add in 8 more decimal places onto the gwei figure
        // The original figure is given in gwei, we multiply by 10^8
        return uint256(answer * 10000000000);
    }

    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        // BEWARE of integer overflows!! Use SafeMath
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUSD;
    }

    function getEntranceFee() public view returns (uint256) {
        // minimumUSD
        uint256 minimumUSD = 50 * 10**18;
        uint256 ethPrice = getPrice();
        uint256 precision = 1 * 10**18;
        return (minimumUSD * precision) / ethPrice;
    }

    // Modifiers change functions in a declarative way
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "You cannot withdraw you are not the owner!"
        );
        _;
    }

    function withdraw() public payable onlyOwner {
        // transfer can be used to send ETH from one address to another
        // 'this' refers to the contract that we're in
        // We want to only have the owner of the contract be able to withdraw!
        // Have to make sure that the msg.sender address is payable!
        payable(msg.sender).transfer(address(this).balance);
        // Wipe the funds from the funders
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }
}
