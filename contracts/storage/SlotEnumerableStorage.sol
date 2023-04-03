// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../libraries/Structs.sol";

library SlotEnumerableStorage {

    struct AppStorage {
        SlotData[] allSlots;

        uint[20] gaps;
        
        mapping(uint256 => mapping(uint256 => uint256)) slotTokensIndex;
        mapping(uint256 => uint256) allSlotsIndex;
    }

    bytes32 constant STORAGE_POSITION = keccak256("erc3525.slot.enumerable.storage");

    function get() internal pure returns (AppStorage storage s) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

}