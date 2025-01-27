// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;

        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface IUniswapV2Router {
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}


contract SINGHStakingV2PVT is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    struct PoolInfo {
        IERC20 lpToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accERC20PerShare;
        uint256 deposited;
    }

    IERC20 public SINGH;

    address public tresuryWallet;
    uint256 public treasuryInvested;

    address internal constant UNISWAP_ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    IUniswapV2Router public pancakeRouter;
    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public USDT = 0x55d398326f99059fF775485246999027B3197955;

    uint256 public paidOut = 0;

    uint256 public rewardPerBlock;

    PoolInfo[] public poolInfo;

    uint256[] public referPerc = [25, 20, 5];
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    mapping(address => bool) public blackListBotAddress;
    mapping(address => bool) public whiteList;
    /// refferal reward mapping
    mapping(address => uint256) public referralReward;
    /// refferal information address to address
    mapping(address => address) public refer_info;
    mapping(address => address[]) public refferalsInfo;
    mapping(address => uint256) public refAmount;


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

    constructor(
        IERC20 _erc20,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        address _tresuryWallet
    ) {
        SINGH = _erc20;
        rewardPerBlock = _rewardPerBlock;
        startBlock = _startBlock;
        endBlock = _startBlock;
        tresuryWallet = _tresuryWallet;
        whiteList[msg.sender] = true;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function fund(uint256 _amount) public {
        SINGH.safeTransferFrom(address(msg.sender), address(this), _amount);
        endBlock += _amount.div(rewardPerBlock);
    }

    function updatePerBlockReward(uint256 _reward) external onlyOwner {
        rewardPerBlock = _reward;
    }

    function updateEndBlock(uint256 _endBlock) external onlyOwner {
        endBlock = _endBlock;
    }

    function setWhitelistAddress(address _address) public onlyOwner {
        whiteList[_address] = true;
    } 

    function removeWhiteListAdddress(address _address) public onlyOwner {
        whiteList[_address] = false;
    }

    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        for (uint256 index = 0; index < poolInfo.length; index++) {
            require(
                poolInfo[index].lpToken != _lpToken,
                "BTNT-Add: you can not add the same LP token twice"
            );
        }
        uint256 lastRewardBlock = block.number > startBlock
            ? block.number
            : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accERC20PerShare: 0,
                deposited: 0
            })
        );
    }

    function set(
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
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 lastBlock = block.number < endBlock
                ? block.number
                : endBlock;
            uint256 nrOfBlocks = lastBlock.sub(pool.lastRewardBlock);

            uint256 erc20Reward = nrOfBlocks
                .mul(rewardPerBlock)
                .mul(pool.allocPoint)
                .div(totalAllocPoint);
            accERC20PerShare = accERC20PerShare.add(
                erc20Reward.mul(1e36).div(lpSupply)
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
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = lastBlock;
            return;
        }

        uint256 nrOfBlocks = lastBlock.sub(pool.lastRewardBlock);
        uint256 erc20Reward = nrOfBlocks
            .mul(rewardPerBlock)
            .mul(pool.allocPoint)
            .div(totalAllocPoint);

        pool.accERC20PerShare = pool.accERC20PerShare.add(
            erc20Reward.mul(1e36).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }

    function addRefer(address referralAdd, uint256 investAmount) internal {
        // uint256 referralAmount = investAmount.div(100);
        if (referralAdd == address(0)) {
            refer_info[msg.sender] = owner();
            //uint referralAmount = investAmount.div(100);
            referralReward[owner()] = referralReward[owner()].add(investAmount);
        } else {
            refferalsInfo[referralAdd].push(msg.sender);
            refer_info[msg.sender] = referralAdd;
            for (uint256 i = 0; i < 3; i++) {
                if (
                    referralAdd != address(0) && referralAdd != owner()
                ) {
                    referralReward[referralAdd] = referralReward[referralAdd]
                        .add(investAmount.mul(referPerc[i]).div(1000));
                    referralAdd = refer_info[referralAdd];
                } else {
                    referralReward[referralAdd] = referralReward[referralAdd]
                        .add(investAmount.mul(referPerc[i]).div(1000));
                }
            }
        }
    }

    function claimReferalReward() external {
        require(referralReward[msg.sender] != 0, "You dont have any reward");
        uint256 rewardVal = referralReward[msg.sender];
        refAmount[msg.sender] += referralReward[msg.sender];
        require(rewardVal > 0, "INVALID_AMOUNT");
        referralReward[msg.sender] = 0;
        SINGH.safeTransfer(msg.sender, rewardVal);
    }

    function getRefferalCount(address user) public view returns (uint256) {
        uint256 refferalUseCount = refferalsInfo[user].length;
        return refferalUseCount;
    }
    function getReferral(address _userAddress) public view returns (uint256) {
        return referralReward[_userAddress];
    }

    function getAmounts(
        address _tokenA,
        address _tokenB,
        uint256 amount
    ) public view returns (uint256) {
        address[] memory path;
        path = new address[](2);
        path[0] = _tokenA;
        path[1] = _tokenB;
        uint256[] memory amountOut = pancakeRouter.getAmountsOut(amount, path);
        return amountOut[1];
    }

    function depositSinghWithBNB(uint256 _pid, address referralAddress) public payable {
        require(msg.value > 0, "INVALID_AMOUNT");
        require(!blackListBotAddress[msg.sender], "BLACKLISTED_BOT_ADDRESS");
        require(whiteList[referralAddress] == true, "ReferralAddress Is INVALID");
        (bool sent, bytes memory data) = payable(tresuryWallet).call{value: msg.value}("");
        require(sent, "Failed to send Ether");
        uint256 _amount = getAmounts(address(WBNB), address(SINGH), msg.value);
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pendingAmount = user
                .amount
                .mul(pool.accERC20PerShare)
                .div(1e36)
                .sub(user.rewardDebt);
            erc20Transfer(msg.sender, pendingAmount);
        }
        pool.lpToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        pool.deposited += _amount;
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accERC20PerShare).div(1e36);
        whiteList[msg.sender] = true;
        treasuryInvested += msg.value;
        addRefer(referralAddress, _amount);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function depositSingh(uint256 _pid, uint256 _amount, address referralAddress) public {
        require(!blackListBotAddress[msg.sender], "BLACKLISTED_BOT_ADDRESS");
        require(whiteList[referralAddress] == true, "ReferralAddress Is INVALID");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pendingAmount = user
                .amount
                .mul(pool.accERC20PerShare)
                .div(1e36)
                .sub(user.rewardDebt);
            erc20Transfer(msg.sender, pendingAmount);
        }
        pool.lpToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        pool.deposited += _amount;
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accERC20PerShare).div(1e36);
        whiteList[msg.sender] = true;
        addRefer(referralAddress, _amount);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdrawSingh(uint256 _pid, uint256 _amount) public {
        require(!blackListBotAddress[msg.sender], "BLACKLISTED_BOT_ADDRESS");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(
            user.amount >= _amount,
            "BTNT-withdraw: Cannot withdraw more than deposit"
        );
        updatePool(_pid);
        uint256 pendingAmount = user
            .amount
            .mul(pool.accERC20PerShare)
            .div(1e36)
            .sub(user.rewardDebt);
        erc20Transfer(msg.sender, pendingAmount);
        user.amount = user.amount.sub(_amount);
        pool.deposited -= _amount;
        user.rewardDebt = user.amount.mul(pool.accERC20PerShare).div(1e36);
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencySinghWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    function erc20Transfer(address _to, uint256 _amount) internal {
        SINGH.transfer(_to, _amount);
        paidOut += _amount;
    }


  function emergancyNativeWithdraw() public onlyOwner {
    uint256 bal = address(this).balance;
    payable(msg.sender).transfer(bal);
  }

  function emergancyErcWithdraw(address token, uint256 _amount) public onlyOwner {
    require(_amount > 0, "INVALID_AMOUNT");
    IERC20(token).transfer(msg.sender, _amount);
  }

      /// @notice Add bot address to blacklist
    function setBlackListAddress(address _blackListAddress) external onlyOwner {
        require(_blackListAddress != address(0), "INVALID_ADDRESS");
        blackListBotAddress[_blackListAddress] = true;
    }

    /// @notice Remove the address from blacklist
    function removeBlackListAddress(address _blackListAddress)
        external
        onlyOwner
    {
        require(_blackListAddress != address(0), "INVALID_ADDRESS");
        blackListBotAddress[_blackListAddress] = false;
    }



}