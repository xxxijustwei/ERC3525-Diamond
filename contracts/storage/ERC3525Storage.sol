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

        TokenData[] allTokens;

        uint[20] gaps;

        mapping(uint256 => mapping(address => uint256)) approvedValues;
        mapping(uint256 => uint256) allTokensIndex;
        mapping(address => AddressData) addressData;
    }

    bytes32 constant STORAGE_POSITION = keccak256("erc3525.solv.standard.storage");

    function get() internal pure returns (AppStorage storage s) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

}