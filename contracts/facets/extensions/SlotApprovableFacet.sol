// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { SlotApprovableStorage } from "../../storage/SlotApprovableStorage.sol";
import { ApprovableFacet } from "../ApprovableFacet.sol";
import { Events } from "../../libraries/Events.sol";
import "../../libraries/Structs.sol";

contract SlotApprovableFacet is ApprovableFacet {

    function isApprovedForSlot(
        address owner_,
        uint256 slot_,
        address operator_
    ) external view returns (bool) {
        return SlotApprovableStorage.get().slotApprovals[owner_][slot_][operator_];
    }

    function setApprovalForSlot(
        address owner_,
        uint256 slot_,
        address operator_,
        bool approved_
    ) external payable virtual {
        require(msg.sender == owner_ || _isApprovedForAll(owner_, msg.sender), "ERC3525SlotApprovable: caller is not owner nor approved for all");
        _setApprovalForSlot(owner_, slot_, operator_, approved_);
    }

    function _isApprovedForSlot(
        address owner_,
        uint256 slot_,
        address operator_
    ) internal view returns (bool) {
        return SlotApprovableStorage.get().slotApprovals[owner_][slot_][operator_];
    }

    function _setApprovalForSlot(
        address owner_,
        uint256 slot_,
        address operator_,
        bool approved_
    ) internal virtual {
        require(owner_ != operator_, "ERC3525SlotApprovable: approve to owner");
        SlotApprovableStorage.AppStorage storage s = SlotApprovableStorage.get();
        s.slotApprovals[owner_][slot_][operator_] = approved_;
        emit Events.ApprovalForSlot(owner_, slot_, operator_, approved_);
    }

    function _isApprovedOrOwner(address operator_, uint256 tokenId_) internal view virtual override returns (bool) {
        _requireMinted(tokenId_);
        address owner = _ownerOf(tokenId_);
        uint256 slot = _slotOf(tokenId_);
        return (
            operator_ == owner ||
            _getApproved(tokenId_) == operator_ ||
            _isApprovedForAll(owner, operator_) ||
            _isApprovedForSlot(owner, slot, operator_)
        );
    }
}