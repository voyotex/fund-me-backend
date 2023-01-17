/**@title A sample Funding Contract
 * @author @voyotex
 * @notice This contract is for creating a sample funding contract
 * @dev This implements price feeds as our library
 */
pragma solidity ^0.8.17;

error FundMe__NotOwner();
error FundMe__NotEnoughFunds();
error FundMe__TransferFailed();

contract FundMeFactory is CloneFactory {
    uint256 private fundsIndexCounter;
    uint256 public immutable i_minFundUSD;
    address private immutable i_owner;
    address[] public funds;
    address masterContract;

    constructor(address _masterContract) {
        masterContract = _masterContract;
        fundsIndexCounter = 0;
        i_minFundUSD = 10;
        i_owner = msg.sender;
    }

    fallback() external payable {}

    function createFund(
        string memory _fundName,
        uint256 _fundDuration,
        uint256 _targetFunding
    ) external returns (address fund) {
        Fund newFund = Fund(createClone(masterContract));
        newFund.initialize(
            fundsIndexCounter,
            _fundName,
            msg.sender,
            _targetFunding,
            _fundDuration,
            address(this)
        );
        // Fund newFund = new Fund(fundsIndexCounter, _fundName, msg.sender, _targetFunding, _fundDuration, address(this));
        fund = address(newFund);
        funds.push(address(newFund));
        fundsIndexCounter++;
    }

    function withdraw() public payable {
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        (bool callResult, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        if (!callResult) revert FundMe__TransferFailed();
    }
}
