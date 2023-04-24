// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { ERC3525Storage } from "../storage/ERC3525Storage.sol";
import { IApproval } from "../interfaces/IApproval.sol";
import { Approvable } from "../abstract/Approvable.sol";

contract ApprovalFacet is IApproval, Approvable {

    function allowance(uint _tokenId, address _operator) external view returns (uint) {
        return _allowance(
            _tokenId,
            _operator
        );
    }

    function getApproved(uint _tokenId) external view returns (address) {
        return _getApproved(_tokenId);
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return _isApprovedForAll(_owner, _operator);
    }

    function approve(address _to, uint _tokenId) external payable virtual {
        require(_to != _ownerOf(_tokenId), "ERC3525: approval to current owner");
        require(_isApprovedOrOwner(msg.sender, _tokenId), "ERC3525: approve caller is not owner nor approved for all");

        _approve(_to, _tokenId);
    }

    function approve(
        uint _tokenId,
        address _to,
        uint _value
    ) external payable virtual {
        require(_to != _ownerOf(_tokenId), "ERC3525: approval to current owner");
        require(_isApprovedOrOwner(msg.sender, _tokenId), "ERC3525: approve caller is not owner nor approved");

        _approveValue(_tokenId, _to, _value);
    }

    function setApprovalForAll(address _operator, bool _approved) external virtual {
        _setApprovalForAll(msg.sender, _operator, _approved);
    } 
}