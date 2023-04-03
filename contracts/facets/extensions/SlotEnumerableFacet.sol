// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { SlotEnumerableStorage } from "../../storage/SlotEnumerableStorage.sol";
import { TransferactionFacet } from "../TransferactionFacet.sol";
import { Events } from "../../libraries/Events.sol";
import "../../libraries/Structs.sol";

contract SlotEnumerableFacet is TransferactionFacet {

    function slotCount() external view returns (uint256) {
        return _slotCount();
    }

    function slotByIndex(uint256 index_) external view returns (uint256) {
        return _slotByIndex(index_);
    }

    function tokenSupplyInSlot(uint256 slot_) external view returns (uint256) {
        return _tokenSupplyInSlot(slot_);
    }

    function tokenInSlotByIndex(uint256 slot_, uint256 index_) external view returns (uint256) {
        return _tokenInSlotByIndex(slot_, index_);
    }

    function _slotCount() internal virtual view returns (uint256) {
        return SlotEnumerableStorage.get().allSlots.length;
    }

    function _slotByIndex(uint256 index_) internal view virtual returns (uint256) {
        require(index_ < _slotCount(), "ERC3525SlotEnumerable: slot index out of bounds");
        return SlotEnumerableStorage.get().allSlots[index_].slot;
    }

    function _tokenSupplyInSlot(uint256 slot_) internal view virtual returns (uint256) {
        if (!_slotExists(slot_)) return 0;
        SlotEnumerableStorage.AppStorage storage s = SlotEnumerableStorage.get();
        return s.allSlots[s.allSlotsIndex[slot_]].slotTokens.length;
    }

    function _tokenInSlotByIndex(uint256 slot_, uint256 index_) internal view virtual returns (uint256) {
        require(index_ < _tokenSupplyInSlot(slot_), "ERC3525SlotEnumerable: slot token index out of bounds");
        SlotEnumerableStorage.AppStorage storage s = SlotEnumerableStorage.get();
        return s.allSlots[s.allSlotsIndex[slot_]].slotTokens[index_];
    }

    function _slotExists(uint256 slot_) internal view virtual returns (bool) {
        SlotEnumerableStorage.AppStorage storage s = SlotEnumerableStorage.get();
        return s.allSlots.length != 0 && s.allSlots[s.allSlotsIndex[slot_]].slot == slot_;
    }

    function _tokenExistsInSlot(uint256 slot_, uint256 tokenId_) private view returns (bool) {
        SlotEnumerableStorage.AppStorage storage s = SlotEnumerableStorage.get();
        SlotData storage slotData = s.allSlots[s.allSlotsIndex[slot_]];
        return slotData.slotTokens.length > 0 && slotData.slotTokens[s.slotTokensIndex[slot_][tokenId_]] == tokenId_;
    }

    function _createSlot(uint256 slot_) internal {
        require(!_slotExists(slot_), "ERC3525SlotEnumerable: slot already exists");
        SlotData memory slotData = SlotData({
            slot: slot_, 
            slotTokens: new uint256[](0)
        });
        _addSlotToAllSlotsEnumeration(slotData);
        emit Events.SlotChanged(0, 0, slot_);
    }

    function _addSlotToAllSlotsEnumeration(SlotData memory slotData) private {
        SlotEnumerableStorage.AppStorage storage s = SlotEnumerableStorage.get();
        s.allSlotsIndex[slotData.slot] = s.allSlots.length;
        s.allSlots.push(slotData);
    }

    function _addTokenToSlotEnumeration(uint256 slot_, uint256 tokenId_) private {
        SlotEnumerableStorage.AppStorage storage s = SlotEnumerableStorage.get();
        SlotData storage slotData = s.allSlots[s.allSlotsIndex[slot_]];
        s.slotTokensIndex[slot_][tokenId_] = slotData.slotTokens.length;
        slotData.slotTokens.push(tokenId_);
    }

    function _removeTokenFromSlotEnumeration(uint256 slot_, uint256 tokenId_) private {
        SlotEnumerableStorage.AppStorage storage s = SlotEnumerableStorage.get();
        SlotData storage slotData = s.allSlots[s.allSlotsIndex[slot_]];
        uint256 lastTokenIndex = slotData.slotTokens.length - 1;
        uint256 lastTokenId = slotData.slotTokens[lastTokenIndex];
        uint256 tokenIndex = s.slotTokensIndex[slot_][tokenId_];

        slotData.slotTokens[tokenIndex] = lastTokenId;
        s.slotTokensIndex[slot_][lastTokenId] = tokenIndex;

        delete s.slotTokensIndex[slot_][tokenId_];
        slotData.slotTokens.pop();
    }

    function _beforeValueTransfer(
        address from_,
        address to_,
        uint256 fromTokenId_,
        uint256 toTokenId_,
        uint256 slot_,
        uint256 value_
    ) internal virtual override {
        super._beforeValueTransfer(from_, to_, fromTokenId_, toTokenId_, slot_, value_);

        if (from_ == address(0) && fromTokenId_ == 0 && !_slotExists(slot_)) {
            _createSlot(slot_);
        }

        //Shh - currently unused
        to_;
        toTokenId_;
        value_;
    }

    function _afterValueTransfer(
        address from_,
        address to_,
        uint256 fromTokenId_,
        uint256 toTokenId_,
        uint256 slot_,
        uint256 value_
    ) internal virtual override {
        if (from_ == address(0) && fromTokenId_ == 0 && !_tokenExistsInSlot(slot_, toTokenId_)) {
            _addTokenToSlotEnumeration(slot_, toTokenId_);
        } else if (to_ == address(0) && toTokenId_ == 0 && _tokenExistsInSlot(slot_, fromTokenId_)) {
            _removeTokenFromSlotEnumeration(slot_, fromTokenId_);
        }

        //Shh - currently unused
        value_;

        super._afterValueTransfer(from_, to_, fromTokenId_, toTokenId_, slot_, value_);
    }

}