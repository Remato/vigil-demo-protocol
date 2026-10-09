// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface ITokenReceiver {
    function onTokenReceived(address from, uint256 amount) external;
}
