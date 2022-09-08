// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./interfaces/ILuckyAll.sol";
import "./library/Random.sol";


contract LuckyFi is IERC721Receiver, Ownable {
    using Random for uint256;
    using Address for address;

    
    uint256 constant private BONUS_PERIOD = 1 days;
    uint256 constant private UNIT = 1e8;
    uint256[9] lmtCostByLevel = [150, 350, 800, 2700, 6000, 10000, 30000, 50000, 100000];

    uint256 constant private BONUS_PER_DAY = 1826484 * 1e16; // 固定每日分红
    uint256 private extraBonus = 0; // 额外分红

    address private DEAD = 0x000000000000000000000000000000000000dEaD;
    address private feeOwner= 0xE44C1d1aAAc32941BDB820801DAcf7C27e3b7F47;
    //uint256 private feeRate = 5;

    // 等价兑换算力
    uint256 private THRESHOLD; 
    uint256 private totalHashToken;
    
    uint256 private totalRare = 0;
    uint256 private totalNorm = 0;

    uint256 private pointer = 0;
    uint256 private randomNum;

    struct LuckyNft {
        uint256 level;
        uint256 rarity;
        bool isLink;
        address realOwner;
        uint256 depositeTime;
        bool isDepos;
    }

    struct User {
        uint256[] rareNftSet;
        uint256[] depositeIds;
        uint256 bonusTime;
        mapping(uint256 => bool) bonusDone; // time => true/false
    }

    mapping(uint256 => LuckyNft) private luckyNfts;
    mapping(address => User) private users;
    

    // event GetMintIds(uint256[] indexed mintId);
    // event Test(uint256 indexed tokenId);

    ILmt private lmt;
    INft private nft;

    event Levelup(uint256 indexed personId, uint256 indexed newLevel, uint256 goldCost);

    constructor(address _LMT,address _LuckyNFT) {

        lmt = ILmt(_LMT);
        nft = INft(_LuckyNFT);

        THRESHOLD = 10000 * UNIT;
    }

    // ================ Display Methods ================

    function levelOfToken(uint256 _tokenId) public view returns (uint256) {
        return luckyNfts[_tokenId].level;
    }

    function nftInfo(uint256 _tokenId) public view returns (bool _isLink, uint256 _level, uint256 _rarity, bool _isDepos) {
        _isLink = luckyNfts[_tokenId].isLink;
        _level = luckyNfts[_tokenId].level;
        _rarity = luckyNfts[_tokenId].rarity;
        _isDepos = luckyNfts[_tokenId].isDepos;
    }

    function tokenOfOwner(address _owner) public view returns (uint256[] memory) {
        uint256[] memory _tokenArray = new uint256[](nft.balanceOf(_owner));
        for(uint256 i = 0; i < nft.balanceOf(_owner); i++){
            _tokenArray[i] = nft.tokenOfOwnerByIndex(_owner, i);
        }
        return _tokenArray;
    }

    function totalBonusToday() public view returns (uint256) {
        return BONUS_PER_DAY + extraBonus;
    } 

    function showRareNftOfOwner() public view returns (uint256[] memory) {
        return users[msg.sender].rareNftSet;
    }

    function showRandom() public view returns (uint256 _index, uint256 _random) {
        return (pointer, randomNum);
    }

    function costForLevelup(uint256 _tokenId) public view returns (uint256) {
        uint256 _level = luckyNfts[_tokenId].level;
        if (_level >= 1 && _level <= 9) {
            return lmtCostByLevel[_level - 1] * 1e18;
        } else {
            return 0;
        }
    }

    function showDepositeIds() public view returns (uint256[] memory) {
        return users[msg.sender].depositeIds;
    }

    function showExpBonus() public view returns (uint256) {
        uint256 _bonus = userHashRatio(msg.sender) * totalBonusToday() / UNIT;
        return _bonus;
    }

    function showBonusDone() public view returns (bool) {
        return users[msg.sender].bonusDone[block.timestamp / BONUS_PERIOD];
    }

    function showBonusTimeLeft() public view returns (uint256 _hour, uint256 _minute, uint256 _second) {
        uint256 _leftTime;
        if (block.timestamp < BONUS_PERIOD * (users[msg.sender].bonusTime / BONUS_PERIOD + 1)){
            _leftTime = BONUS_PERIOD * (users[msg.sender].bonusTime / BONUS_PERIOD + 1) - block.timestamp;
            (_hour, _minute, _second) = toHMS(_leftTime);
        } else {
            (_hour, _minute, _second) = (0, 0, 0);
        }
    }


    // ================ Operational Methods ================

    function _linkNft(uint256 _tokenId) internal {
        luckyNfts[_tokenId].level = 1;
        luckyNfts[_tokenId].rarity = nft.showRarity(_tokenId);
        luckyNfts[_tokenId].isLink = true;
        luckyNfts[_tokenId].realOwner = msg.sender;
    }


    function linkNft(uint256 _tokenId) public {
        require(nft.ownerOf(_tokenId) == msg.sender, "LuckyFi: call is not owner of nft.");
        require(!luckyNfts[_tokenId].isLink, "LuckyFi: nft has been linked.");
        _linkNft(_tokenId); 
    }

    function batchLinkNft() public {
        uint256[] memory _ids = tokenOfOwner(msg.sender);
        for (uint256 i = 0; i < _ids.length; i++) {
            linkNft(_ids[i]);
        }
    }


    function levelup(uint256 _tokenId) public onlyWallet {
        require(nft.ownerOf(_tokenId) == msg.sender, "LuckyFi: caller is not owner of target nft.");
        require(luckyNfts[_tokenId].isLink, "LuckyFi: nft is not linked.");
        uint256 _level = luckyNfts[_tokenId].level;
        uint256 _lmtCost = lmtCostByLevel[_level - 1] * 1e18;
        lmt.approve(address(this), _lmtCost);
        lmt.transferFrom(msg.sender, feeOwner, _lmtCost);
        luckyNfts[_tokenId].level += 1;
        emit Levelup(_tokenId, luckyNfts[_tokenId].level, _lmtCost);       
    }


    function depositeNft(uint256 _tokenId) public {
        require(nft.ownerOf(_tokenId) == msg.sender, "LuckyFi: caller is not owner of target nft.");
        require(luckyNfts[_tokenId].isLink, "LuckyFi: nft is not linked.");
        nft.safeTransferFrom(msg.sender, address(this), _tokenId);
        luckyNfts[_tokenId].depositeTime = block.timestamp;
        luckyNfts[_tokenId].realOwner = msg.sender;
        luckyNfts[_tokenId].isDepos = true;
        users[msg.sender].depositeIds.push(_tokenId);
        totalHashToken += hashFactor(_tokenId); 
    }

    function batchDeposNft(uint256[] memory _ids) public {
        for (uint256 i = 0; i < _ids.length; i++) {
            depositeNft(_ids[i]);
        }
    }


    function _getBonus(address _user, uint256 _amount) internal {
        lmt.transfer(_user, _amount);      
        users[_user].bonusDone[block.timestamp / BONUS_PERIOD] = true;
        users[_user].bonusTime = block.timestamp;
    }


    function getBonus() public {
        require(!users[msg.sender].bonusDone[block.timestamp / BONUS_PERIOD], "LuckyFi: bonus has been done today."); 
        uint256 _bonus = userHashRatio(msg.sender) * totalBonusToday() / UNIT;
        require(_bonus != 0, "LuckyFi: bonus is zero");
        _getBonus(msg.sender, _bonus);
    }


    function withdrawNft(uint256 _tokenId) public {
        require(nft.ownerOf(_tokenId) == address(this), "LuckyFi: target nft is not in deposite pool.");
        require(luckyNfts[_tokenId].realOwner == msg.sender, "LuckyFi: caller is original owner of target nft.");
        uint256 _bonus = userHashRatio(msg.sender) * totalBonusToday() / UNIT;
        if (!users[msg.sender].bonusDone[block.timestamp / BONUS_PERIOD] && _bonus != 0) {
            _getBonus(msg.sender, _bonus);
        }
        nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        totalHashToken -= hashFactor(_tokenId);
        
        uint256 _len = users[msg.sender].depositeIds.length;
        uint256 _index = 0;
        while(_index < _len) {
            if (users[msg.sender].depositeIds[_index] == _tokenId) {
                users[msg.sender].depositeIds[_index] = users[msg.sender].depositeIds[_len - 1];
                break;
            }       
            _index ++;
        }
        
        luckyNfts[_tokenId].realOwner = address(0);
        luckyNfts[_tokenId].isDepos = false;
        luckyNfts[_tokenId].depositeTime = 0;
        users[msg.sender].depositeIds.pop();
    }


    function withdrawNftAll() public {
        uint256 _len = users[msg.sender].depositeIds.length;
        require(_len != 0, "LuckyFi: caller has no deposit nft.");
        uint256 _bonus = userHashRatio(msg.sender) * totalBonusToday() / UNIT;
        if (!users[msg.sender].bonusDone[block.timestamp / BONUS_PERIOD] && _bonus != 0) {
            _getBonus(msg.sender, _bonus);
        }

        for (uint256 i = 0; i < _len; i++) {
            uint256 _tokenId = users[msg.sender].depositeIds[i];
            nft.safeTransferFrom(address(this), msg.sender, _tokenId);
            totalHashToken -= hashFactor(_tokenId);
            luckyNfts[_tokenId].realOwner = address(0);
            luckyNfts[_tokenId].isDepos = false;
            luckyNfts[_tokenId].depositeTime = 0;
        }

        delete users[msg.sender].depositeIds;
    }


    // ================ Functional Methods ================

    function hashFactor(uint256 _tokenId) internal view returns (uint256) {
        uint256 _factor;
        uint256 _level = luckyNfts[_tokenId].level;
        if (luckyNfts[_tokenId].rarity == 1) {
            _factor = _level * _level * UNIT + (_level - 1) * UNIT * 20;          
        } else if (luckyNfts[_tokenId].rarity == 2) {
            _factor = _level * _level * UNIT + (_level - 1) * UNIT;
        }
        return _factor;
    }


    function userHashToken(address _user) internal view returns (uint256) {
        uint256[] memory _ids = users[_user].depositeIds;
        uint256 _userHash;
        for (uint256 i = 0; i < _ids.length; i++) {
            uint256 _id = _ids[i];
            if (luckyNfts[_id].depositeTime + BONUS_PERIOD < block.timestamp && luckyNfts[_id].depositeTime != 0) {
                _userHash += hashFactor(_id);
            }
        }
        return _userHash;
    }


    function userHashRatio(address _user) internal view returns (uint256) {
        uint256 _ratio;
        if (totalHashToken >= THRESHOLD) {
            _ratio = userHashToken(_user) * UNIT / totalHashToken;
        } else {
            _ratio = userHashToken(_user) * UNIT / THRESHOLD;
        }
        return _ratio;
    }


    function toHMS(uint256 _time) internal pure returns (uint256 _hour, uint256 _minute, uint256 _second) {
        uint256 hour = _time / 3600;
        uint256 minute = (_time - hour * 3600) / 60;
        uint256 second = _time - hour * 3600 - minute * 60;
        return (hour, minute, second);
    }


    function random(uint256 _range) internal returns (uint256) {
        uint256 time_base = uint256(uint64(block.timestamp));
        uint256 addr_base = uint256(uint64(uint160(msg.sender)));
        uint256 _seed = uint256(uint64(time_base * addr_base));
        uint256[] memory _randomArray = _seed.genSeedsUint64(_range);
        randomNum = _randomArray[pointer % _range];
        pointer++;
        return randomNum;
    }


    // ================ Setting Methods ================

    function setExtraBonus(uint256 _newExtraBonus) external onlyOwner {
        extraBonus = _newExtraBonus;
    }


    function setLmtCostByLevel(uint256[9] memory _newLmgCost) external onlyOwner {
        require(_newLmgCost.length <= 9, "LuckyFi: array of lmt costs by level must be less than 9.");
        lmtCostByLevel = _newLmgCost;
    }


    function setLuckyNFT(address _newLuckyNFT) external onlyOwner(){
        nft = INft(_newLuckyNFT);
    }

    /*
    function newLuckyTicket(address _new) external onlyOwner(){
        ticket = ITicket(_new);
    }
    */


    function setLuckyMetaToken(address _newLuckyMetaToken) external onlyOwner(){
        lmt = ILmt(_newLuckyMetaToken);
    }

    function setFeeOwner(address _newFeeOwner) external onlyOwner(){
        feeOwner = _newFeeOwner;
    }

    /*
    function newfeeRate(uint256 _feeRate) external onlyOwner(){
        feeRate = _feeRate;
    }
    */

    modifier onlyWallet() {
        require(!msg.sender.isContract(), "LuckyFi: contracts are not allowed.");
        _;
    }

     
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

}
