// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

struct TokenData {
    uint256 id;
    uint256 slot;
    uint256 balance;
    address owner;
    address approved;
    address[] valueApprovals;
}

struct AddressData {
    uint256[] ownedTokens;
    mapping(uint256 => uint256) ownedTokensIndex;
    mapping(address => bool) approvals;
}

struct SlotData {
    uint256 slot;
    uint256[] slotTokens;
}