// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "./interfaces/IERC20.sol";
import {IVault} from "./interfaces/IVault.sol";

/// @notice Share based vault over a single token, with a withdrawal fee.
contract Vault is IVault {
    uint256 public constant MAX_FEE_BPS = 500;

    IERC20 public immutable token;
    address public owner;
    address public feeRecipient;
    uint256 public feeBps;

    uint256 public totalShares;
    mapping(address => uint256) public sharesOf;

    event Deposit(address indexed receiver, uint256 assets, uint256 shares);
    event Withdraw(address indexed receiver, uint256 assets, uint256 shares);

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    constructor(IERC20 token_, address feeRecipient_) {
        token = token_;
        owner = msg.sender;
        feeRecipient = feeRecipient_;
        feeBps = 30;
    }

    function asset() external view returns (address) {
        return address(token);
    }

    function totalAssets() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function deposit(uint256 assets, address receiver) external returns (uint256 shares) {
        require(assets > 0, "zero assets");
        shares = totalShares == 0 ? assets : (assets * totalShares) / totalAssets();
        require(shares > 0, "zero shares");
        require(token.transferFrom(msg.sender, address(this), assets), "transfer in");
        totalShares += shares;
        sharesOf[receiver] += shares;
        emit Deposit(receiver, assets, shares);
    }

    function withdraw(uint256 shares, address receiver) external returns (uint256 assets) {
        require(shares > 0 && sharesOf[msg.sender] >= shares, "shares");
        assets = (shares * totalAssets()) / totalShares;
        uint256 fee = (assets * feeBps) / 10_000;
        require(token.transfer(receiver, assets - fee), "transfer out");
        require(token.transfer(feeRecipient, fee), "fee out");
        sharesOf[msg.sender] -= shares;
        totalShares -= shares;
        emit Withdraw(receiver, assets, shares);
    }

    function setFeeBps(uint256 feeBps_) external onlyOwner {
        require(feeBps_ <= MAX_FEE_BPS, "fee too high");
        feeBps = feeBps_;
    }

    function setFeeRecipient(address feeRecipient_) external {
        feeRecipient = feeRecipient_;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
    }
}
