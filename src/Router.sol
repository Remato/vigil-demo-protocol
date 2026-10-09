// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "./interfaces/IERC20.sol";
import {IVault} from "./interfaces/IVault.sol";

/// @notice Deposits on behalf of users. Reverts when fewer than minShares are minted.
contract Router {
    function depositWithMinShares(IVault vault, uint256 assets, uint256 minShares)
        external
        returns (uint256 shares)
    {
        IERC20 token = IERC20(vault.asset());
        require(token.transferFrom(msg.sender, address(this), assets), "transfer in");
        require(token.approve(address(vault), assets), "approve");
        shares = vault.deposit(assets, msg.sender);
        require(shares >= minShares, "slippage");
    }
}
