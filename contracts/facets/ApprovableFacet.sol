// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { ERC3525Storage } from "../storage/ERC3525Storage.sol";
import { Substrate } from "../Substrate.sol";
import { Events } from "../libraries/Events.sol";

contract ApprovableFacet is Substrate {

    function allowance(uint256 tokenId_, address operator_) external view returns (uint256) {
        return _allowance(tokenId_, operator_);
    }

    function getApproved(uint256 tokenId_) external view returns (address) {
        return _getApproved(tokenId_);
    }

    function isApprovedForAll(address owner_, address operator_) external view returns (bool) {
        return _isApprovedForAll(owner_, operator_);
    }

    function approve(address to_, uint256 tokenId_) external payable virtual {
        address owner = _ownerOf(tokenId_);
        require(to_ != owner, "ERC3525: approval to current owner");
        require(_isApprovedOrOwner(msg.sender, tokenId_), "ERC3525: approve caller is not owner nor approved for all");

        _approve(to_, tokenId_);
    }

    function approve(
        uint256 tokenId_,
        address operator_,
        uint256 value_
    ) external payable virtual {
        address owner = _ownerOf(tokenId_);
        require(operator_ != owner, "ERC3525: approval to current owner");
        require(_isApprovedOrOwner(msg.sender, tokenId_), "ERC3525: approve caller is not owner nor approved");

        _approveValue(tokenId_, operator_, value_);
    }

    function setApprovalForAll(address operator_, bool approved_) external {
        _setApprovalForAll(msg.sender, operator_, approved_);
    }

    function _setApprovalForAll(
        address owner_,
        address operator_,
        bool approved_
    ) internal virtual {
        require(owner_ != operator_, "ERC3525: approve to caller");

        ERC3525Storage.AppStorage storage s = ERC3525Storage.get();
        s.addressData[owner_].approvals[operator_] = approved_;

        emit Events.ApprovalForAll(owner_, operator_, approved_);
    }
}