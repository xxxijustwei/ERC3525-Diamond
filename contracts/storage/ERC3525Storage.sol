// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Counters.sol";

import "../libraries/Structs.sol";

library ERC3525Storage {

    struct AppStorage {
        string name;
        string symbol;
        uint8 decimals;

        Counters.Counter tokenIdGenerator;

        // tokenId => TokenData
        mapping(uint => TokenData) tokens;
        // address => Account
        mapping(address => Account) accounts;
    }

    bytes32 constant STORAGE_POSITION = keccak256("erc3525.solv.standard.storage");

    function layout() internal pure returns (AppStorage storage s) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

}