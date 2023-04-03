// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

library SlotApprovableStorage {

    struct AppStorage {
        uint[20] gaps;

        mapping(address => mapping(uint256 => mapping(address => bool))) slotApprovals;
    }

    bytes32 constant STORAGE_POSITION = keccak256("erc3525.slot.approvable.storage");

    function get() internal pure returns (AppStorage storage s) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

}