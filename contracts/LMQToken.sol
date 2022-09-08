// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract LMQToken is Ownable, ERC20 {
   
   using SafeMath for uint256;
   uint256 public _taxFee = 2;
   
   mapping (address => bool) private _isExcludedFromFee;
   
   constructor ()ERC20("LMQToken", "LMQ") {
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
   }
   
   
    function transfer(address to, uint256 amount)  public virtual override returns (bool) {
        address spender = _msgSender();
        if (_isExcludedFromFee[to] || _isExcludedFromFee[spender]) {
            return ERC20.transfer(to, amount);
        }
        uint256 fee = amount.mul(_taxFee).div(10**4);
        _burn(spender, fee);
        return ERC20.transfer(to, amount.sub(fee));
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
       if (_isExcludedFromFee[to] || _isExcludedFromFee[from] || _isExcludedFromFee[_msgSender()]) {
            return ERC20.transferFrom(from, to, amount);
        }
        uint256 fee = amount.mul(_taxFee).div(10**4);
        _burn(from, fee);
        return ERC20.transferFrom(from, to, amount.sub(fee));
    }
    
    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    function setExcludedFromFee(address account, bool t) public onlyOwner {
          require(account != address(0), "ERC20: mint to the zero address");
        _isExcludedFromFee[account] = t;
    }

    function setTaxFee(uint256 taxFee)public {
        require(taxFee <= 5000, "LMQToken: taxFee is error");
        _taxFee = taxFee;
    }
}
