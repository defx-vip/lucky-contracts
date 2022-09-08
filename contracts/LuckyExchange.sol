// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20Detail is IERC20 {
    function decimals() external view returns (uint8);
}

contract LuckyExchange is Ownable {

    uint256 private rateA2B = 100; // 
    uint256 private feeRate = 0; // 
    uint256 public decimalGap;
    bool private isAOverB;

    uint256 constant FACTOR = 1e18;    

    IERC20Detail public tokenA;
    IERC20Detail public tokenB;

    address public feeOwner = 0xE44C1d1aAAc32941BDB820801DAcf7C27e3b7F47;

    event ExchangeLog(uint256 payToken, uint256 targetToken, uint256 feeRate);
    event ChangeFeeRate(uint256 oldFeeRate, uint256 newFeeRate);

    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20Detail(_tokenA);
        tokenB = IERC20Detail(_tokenB);
        (decimalGap, isAOverB) = getDecimalGap(tokenA.decimals(), tokenB.decimals());
    }
    

    function getFeeRate() public view returns (uint256) {
        return feeRate;
    }

    
    function exchangeA2B(uint256 _amountOfTokenA) public returns (bool) {
        uint256 _amountOfTokenB;
        if (isAOverB) {
            _amountOfTokenB = _amountOfTokenA * rateA2B / decimalGap;
        } else {
            _amountOfTokenB = _amountOfTokenA * rateA2B * decimalGap ;
        }
        require(tokenA.balanceOf(msg.sender) >= _amountOfTokenA, "Exchange: pay token is not enough for exchanging");
        require(tokenB.balanceOf(address(this)) >= _amountOfTokenB, "Exchange: target token is not enough for exchanging");
        uint256 fee = _amountOfTokenB * feeRate / 100;
        tokenA.transferFrom(msg.sender, address(this), _amountOfTokenA);
        tokenB.transfer(msg.sender, _amountOfTokenB - fee);
        if (fee != 0) {
            tokenB.transfer(feeOwner, fee);
        }  
        emit ExchangeLog(_amountOfTokenA, _amountOfTokenB - fee, fee);
        return true;
    }

     
    function exchangeB2A(uint256 _amountOfTokenB) public returns (bool) {
        uint256 _amountOfTokenA;
        if (isAOverB) {
            _amountOfTokenA = _amountOfTokenB /rateA2B * decimalGap;
        } else {
            _amountOfTokenA = _amountOfTokenB /rateA2B / decimalGap;
        }
        require(tokenB.balanceOf(msg.sender) >= _amountOfTokenB, "Exchange: pay token is not enough for exchanging");
        require(tokenA.balanceOf(address(this)) >= _amountOfTokenA, "Exchange: target token is not enough for exchanging");
        uint256 fee = _amountOfTokenA * feeRate / 100;
        tokenB.transferFrom(msg.sender, address(this), _amountOfTokenB);
        tokenA.transfer(msg.sender, _amountOfTokenA - fee);
        if (fee != 0) {
            tokenA.transfer(feeOwner, fee);
        }
        emit ExchangeLog(_amountOfTokenB, _amountOfTokenA - fee, fee);
        return true;
    }

    
    function setRateA2B(uint256 _rate) public onlyOwner {
        rateA2B = _rate;
    }

    
    function getRateA2B() public view returns (uint256) {
        return rateA2B;
    }
  

    function setFeeRate(uint256 _newFeeRate) public onlyOwner {
        uint256 _oldFeeRate = feeRate;
        require(_newFeeRate <= 100, "Exchange: new feeRate is out of range of 0-100");
        feeRate = _newFeeRate;
        emit ChangeFeeRate(_oldFeeRate, _newFeeRate);
    }

     
    function setfeeOwner(address _feeOwner) public onlyOwner {
        require(_feeOwner != address(0), "Exchange: fee terminal address is not zero address");
        feeOwner = _feeOwner;
    }

 
    function balanceOfTokenA() public view onlyOwner returns  (uint256) {
        return tokenA.balanceOf(address(this));
    }
   
    function balanceOfTokenB() public view onlyOwner returns (uint256) {
        return tokenB.balanceOf(address(this));
    }

     
    function withDrawalTokenA(uint256 _amount) public onlyOwner{
        require(tokenA.balanceOf(address(this)) >= _amount, "WithDrawal: this token is not enough for withDrawal");
        tokenA.transfer(msg.sender,_amount);
    }

    function withDrawalTokenB(uint256 _amount) public onlyOwner{
        require(tokenB.balanceOf(address(this)) >= _amount, "WithDrawal: this token is not enough for withDrawal");
        tokenB.transfer(msg.sender,_amount);
    }

    function getDecimalGap(uint8 decimalTokenA, uint8 decimalTokenB) internal pure returns (uint256, bool) {
        if (decimalTokenA >= decimalTokenB) {
            return (10 ** (decimalTokenA - decimalTokenB), true);
        } else {
            return (10 ** (decimalTokenB - decimalTokenA), false);
        }
    }
}