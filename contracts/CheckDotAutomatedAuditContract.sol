// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount) external returns (bool);
}

/**
 * @dev Implementation of the {CheckDot Smart Contract Automated Audit Service } Contract Version 1
 * 
 * Simple schema representation:
 *
 * o-------o       o--------------------o       o-------------o       o------------------------------o
 * |  BUY  | ----> |     Emit Event     | ----> |   Process   | ----> |  Burn CDT 10% CDT Quarterly  |
 * o-------o       o--------------------o       o-------------o       o------------------------------o
 *
 */
contract CheckDotAutomatedAuditContract {
    using SafeMath for uint256;

    /**
     * @dev Manager of the contract.
     */
    address private _owner;

    /**
     * @dev Address of the CDT token hash: {CDT address}.
     */
    IERC20 private _cdtToken;

    /**
     * @dev Address of the USDT token hash: {USDT address}.
     */
    IERC20 private _usdtToken;

    /**
     * @dev Address of the BUSD token hash: {USDT address}.
     */
    IERC20 private _busdToken;

    struct ServiceSettings {
        uint256 CDT_COST;
        uint256 USDT_COST;
        uint256 BUSD_COST;
    }

    struct Statistics {
        uint256 SERVICE_COUNT;
    }

    ServiceSettings public _settings;
    Statistics public _statistics;

    event NewAudit(address initiator, address contractAddress);

    uint8 private constant _tokenDecimals = 18;

    constructor(address cdtTokenAddress, address usdtTokenAddress, address busdTokenAddress) {
        require(msg.sender != address(0), "Deploy from the zero address");
        _cdtToken = IERC20(cdtTokenAddress);
        _usdtToken = IERC20(usdtTokenAddress);
        _busdToken = IERC20(busdTokenAddress);
        _owner = msg.sender;
        _settings.CDT_COST = 10000 * (10 ** uint256(_tokenDecimals));
        _settings.USDT_COST = 500 * (10 ** uint256(_tokenDecimals));
        _settings.BUSD_COST = 500 * (10 ** uint256(_tokenDecimals));
    }

    /**
     * @dev Check that the transaction sender is the CDT owner
     */
    modifier onlyOwner() {
        require(msg.sender == _owner, "Only the owner can do this action");
        _;
    }

    // Global SECTION
    
    function getSettings() public view returns (ServiceSettings memory) {
        return _settings;
    }

    function getStatistics() public view returns (Statistics memory) {
        return _statistics;
    }

    // Service SECTION

    function buyInCDT(address contractAddress) public {
        require(_cdtToken.balanceOf(msg.sender) >= _settings.CDT_COST, "Insufficient balance");
        require(_cdtToken.transferFrom(msg.sender, address(this), _settings.CDT_COST) == true, "Error transfer");
        _statistics.SERVICE_COUNT += 1;
        emit NewAudit(msg.sender, contractAddress);
    }

    function buyInBUSD(address contractAddress) public {
        require(_busdToken.balanceOf(msg.sender) >= _settings.BUSD_COST, "Insufficient balance");
        require(_busdToken.transferFrom(msg.sender, address(this), _settings.BUSD_COST) == true, "Error transfer");
        _statistics.SERVICE_COUNT += 1;
        emit NewAudit(msg.sender, contractAddress);
    }

    function buyInUSDT(address contractAddress) public {
        require(_usdtToken.balanceOf(msg.sender) >= _settings.USDT_COST, "Insufficient balance");
        require(_usdtToken.transferFrom(msg.sender, address(this), _settings.USDT_COST) == true, "Error transfer");
        _statistics.SERVICE_COUNT += 1;
        emit NewAudit(msg.sender, contractAddress);
    }

    // SETTINGS SECTION

    function setCosts(uint256 _amountCdt, uint256 _amountUSDT, uint256 _amountBUSD) public onlyOwner {
        _settings.CDT_COST = _amountCdt;
        _settings.USDT_COST = _amountUSDT;
        _settings.BUSD_COST = _amountBUSD;
    }

    function claimCDTFees() public onlyOwner {
        require(_cdtToken.balanceOf(address(this)) >= 0, "Insufficient balance");
        require(_cdtToken.transfer(_owner, _cdtToken.balanceOf(address(this))) == true, "Error transfer");
    }

    function claimUSDTFees() public onlyOwner {
        require(_usdtToken.balanceOf(address(this)) >= 0, "Insufficient balance");
        require(_usdtToken.transfer(_owner, _usdtToken.balanceOf(address(this))) == true, "Error transfer");
    }

    function claimBUSDFees() public onlyOwner {
        require(_busdToken.balanceOf(address(this)) >= 0, "Insufficient balance");
        require(_busdToken.transfer(_owner, _busdToken.balanceOf(address(this))) == true, "Error transfer");
    }
}
