
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;


contract NFT {

    struct NftInfo {
        uint256 startBlock;
    }
    
    struct StakingInfo {
       uint256 totalPoint;
       uint256 rewardTokenDebt;
       uint256 rewardTokenAmount;
       uint256 nftSize;
       uint256 lastRewardBlock;
    }

    uint256 public lastRewardBlock; // Last block number that TOKENs distribution occurs.
    uint256 public accDetTokenPerShare; // Accumulated TOKENs per share, times 1e12. See below.
    uint256 public detTokenPerBlock;
    uint256 public totalShare;

    uint256 public lastId;
    uint256 public alpha = 1;
    uint256 public initPow = 2 ** 7;

    
    mapping(uint256 => StakingInfo) public nftStakings;
    mapping(uint256 => NftInfo) public nftInfos;
    mapping(uint256 => address) public owners;



    function getPower(uint256 id, uint256 num) public view returns (uint256 pow) {
        require(num >= nftInfos[id].startBlock, "");
        uint256 x= (num - nftInfos[id].startBlock) / alpha;
        if (x > 7) x = 7;
        pow = initPow;
        pow = pow / 2**x; 
    }

    function getPowerX(uint256 id, uint256 num) public view returns (uint256 x) {
        x = (num - nftInfos[id].startBlock) / alpha;
        if (x > 7) x = 7;
    }

    function getAvgPower(uint256 id, uint256 start, uint256 end) public view returns(uint256) {
        uint256 roundStart = getPowerX(id, start);
        uint256 step = (end - roundStart) / alpha;
        uint256 pow = getPower(id, start);
        if (step == 0) return pow;
        uint256 total = pow;
        for(uint256 i = 0; i < step; i++) {
            pow = pow / 2;
            total += pow;
        }
        return total/(step + 1);
    }

    function mint() external  {
        lastId++;
        nftInfos[lastId].startBlock = block.number;
        owners[lastId] = msg.sender;
    }

    function lastBlock() public view returns(uint256) {
        return block.number;
    }
    
    
    function depositPool(uint256 id)public  {
        require(owners[id] == msg.sender, "NFT: not your nft");
        owners[id] = address(this);
        updatePool();
        uint256 power = getPower(id, block.number);
        nftStakings[id].totalPoint = power;
        nftStakings[id].lastRewardBlock = block.number;
        nftStakings[id].rewardTokenDebt = nftStakings[id].totalPoint * accDetTokenPerShare / 1e12;
        totalShare += power;
    }

    function updatePool() public {
        if (block.number <= lastRewardBlock) {
            return;
        }
        uint256 multiplier = lastRewardBlock - block.number;
        uint256 starTokenReward = multiplier * detTokenPerBlock;
        accDetTokenPerShare = accDetTokenPerShare + starTokenReward *1e12 / totalShare;
        lastRewardBlock = block.number;
    }
    
    function pendingToken(uint256 id) public view returns(uint256 pending) {
       uint256 multiplier = lastRewardBlock - block.number;
       uint256 startTokenReward = detTokenPerBlock * multiplier;
       uint256 _accDetTokenPerShare = 0;
       if(totalShare > 0) {
            _accDetTokenPerShare = accDetTokenPerShare + startTokenReward * 1e12/ totalShare;
        }
        StakingInfo memory userInfo = nftStakings[id];
        pending = userInfo.totalPoint * _accDetTokenPerShare / 1e12  - userInfo.rewardTokenDebt;
        return pending * getAvgPower(id, userInfo.lastRewardBlock, block.number) / userInfo.totalPoint;
    }
}