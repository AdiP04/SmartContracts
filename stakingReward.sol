// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingRewardContract is Ownable {
  using SafeMath for uint256;

  function depositContract() external payable {}

  struct UserInfo {
    uint256 amount;
    uint256 rewardDebt;
  }

  struct PoolInfo {
    uint256 poolId;
    uint256 allocPoint;
    uint256 lastRewardBlock;
    uint256 accERC20PerShare;
    uint256 investAmount;
  }

  uint256 public paidOut = 0;

  uint256 public rewardPerBlock;

  PoolInfo[] public poolInfo;

  mapping(uint256 => mapping(address => UserInfo)) public userInfo;

  uint256 public totalAllocPoint = 0;

  uint256 public startBlock;
  uint256 public endBlock;

  event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
  event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);

  event EmergencyWithdraw(
    address indexed user,
    uint256 indexed pid,
    uint256 amount
  );

  constructor(uint256 _rewardPerBlock, uint256 _startBlock) {
    rewardPerBlock = _rewardPerBlock;
    startBlock = _startBlock;
    endBlock = _startBlock;
  }

  function poolLength() external view returns (uint256) {
    return poolInfo.length;
  }

  function fund(uint256 _amount) public payable {
    require(msg.value >= _amount, "INVAID_AMOUNT");
    endBlock += _amount.div(rewardPerBlock);
  }

  function addPool(
    uint256 _allocPoint,
    uint256 _poolId,
    bool _withUpdate
  ) public onlyOwner {
    if (_withUpdate) {
      massUpdatePools();
    }
    for (uint256 index = 0; index < poolInfo.length; index++) {
      require(
        poolInfo[index].poolId != _poolId,
        "ETH-Add: you can not add the same LP token twice"
      );
    }
    uint256 lastRewardBlock = block.number > startBlock
      ? block.number
      : startBlock;
    totalAllocPoint = totalAllocPoint.add(_allocPoint);
    poolInfo.push(
      PoolInfo({
        poolId: _poolId,
        allocPoint: _allocPoint,
        lastRewardBlock: lastRewardBlock,
        accERC20PerShare: 0,
        investAmount: 0
      })
    );
  }

  function setPool(
    uint256 _pid,
    uint256 _allocPoint,
    bool _withUpdate
  ) public onlyOwner {
    if (_withUpdate) {
      massUpdatePools();
    }
    totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
      _allocPoint
    );
    poolInfo[_pid].allocPoint = _allocPoint;
  }

  function deposited(uint256 _pid, address _user)
    external
    view
    returns (uint256)
  {
    UserInfo storage user = userInfo[_pid][_user];
    return user.amount;
  }

  function pending(uint256 _pid, address _user)
    external
    view
    returns (uint256)
  {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][_user];
    uint256 accERC20PerShare = pool.accERC20PerShare;
    uint256 poolSupply = pool.investAmount;
    if (block.number > pool.lastRewardBlock && poolSupply != 0) {
      uint256 lastBlock = block.number < endBlock ? block.number : endBlock;
      uint256 nrOfBlocks = lastBlock.sub(pool.lastRewardBlock);

      uint256 erc20Reward = nrOfBlocks
        .mul(rewardPerBlock)
        .mul(pool.allocPoint)
        .div(totalAllocPoint);
      accERC20PerShare = accERC20PerShare.add(
        erc20Reward.mul(1e36).div(poolSupply)
      );
    }

    return user.amount.mul(accERC20PerShare).div(1e36).sub(user.rewardDebt);
  }

  function totalPending() external view returns (uint256) {
    if (block.number <= startBlock) {
      return 0;
    }

    uint256 lastBlock = block.number < endBlock ? block.number : endBlock;
    return rewardPerBlock.mul(lastBlock - startBlock).sub(paidOut);
  }

  function massUpdatePools() public {
    uint256 length = poolInfo.length;
    for (uint256 pid = 0; pid < length; ++pid) {
      updatePool(pid);
    }
  }

  function updatePool(uint256 _pid) public {
    PoolInfo storage pool = poolInfo[_pid];
    uint256 lastBlock = block.number < endBlock ? block.number : endBlock;

    if (lastBlock <= pool.lastRewardBlock) {
      return;
    }
    uint256 poolSupply = pool.investAmount;
    if (poolSupply == 0) {
      pool.lastRewardBlock = lastBlock;
      return;
    }

    uint256 nrOfBlocks = lastBlock.sub(pool.lastRewardBlock);
    uint256 nativeReward = nrOfBlocks
      .mul(rewardPerBlock)
      .mul(pool.allocPoint)
      .div(totalAllocPoint);

    pool.accERC20PerShare = pool.accERC20PerShare.add(
      nativeReward.mul(1e36).div(poolSupply)
    );
    pool.lastRewardBlock = block.number;
  }

  function deposit(uint256 _pid, uint256 _amount) public payable {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][msg.sender];
    updatePool(_pid);
    if (user.amount > 0) {
      uint256 pendingAmount = user
        .amount
        .mul(pool.accERC20PerShare)
        .div(1e36)
        .sub(user.rewardDebt);
      payable(msg.sender).transfer(pendingAmount);
    }
    // pool.poolId.safeTransferFrom(address(msg.sender), address(this), _amount);
    payable(address(this)).transfer(_amount);
    pool.investAmount = pool.investAmount.add(_amount);
    user.amount = user.amount.add(_amount);
    user.rewardDebt = user.amount.mul(pool.accERC20PerShare).div(1e36);
    emit Deposit(msg.sender, _pid, _amount);
  }

  function withdraw(uint256 _pid, uint256 _amount) public {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][msg.sender];
    require(
      user.amount >= _amount,
      "ETH-withdraw: Cannot withdraw more than deposit"
    );
    updatePool(_pid);
    uint256 pendingAmount = user
      .amount
      .mul(pool.accERC20PerShare)
      .div(1e36)
      .sub(user.rewardDebt);
    payable(msg.sender).transfer(pendingAmount);
    user.amount = user.amount.sub(_amount);
    user.rewardDebt = user.amount.mul(pool.accERC20PerShare).div(1e36);
    payable(msg.sender).transfer(_amount);
    emit Withdraw(msg.sender, _pid, _amount);
  }

  function emergencyWithdraw(uint256 _pid) public {
    UserInfo storage user = userInfo[_pid][msg.sender];
    payable(msg.sender).transfer(user.amount);
    emit EmergencyWithdraw(msg.sender, _pid, user.amount);
    user.amount = 0;
    user.rewardDebt = 0;
  }

  function withdraw(uint256 _amount) public onlyOwner {
    payable(owner()).transfer(_amount);
    paidOut += _amount;
  }

  function getCurrentBlock() public view returns (uint256) {
    return block.number;
  }
}
