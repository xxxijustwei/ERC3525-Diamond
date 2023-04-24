// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { ERC3525Storage } from "../storage/ERC3525Storage.sol";
import { Explorable } from "../abstract/Explorable.sol";

abstract contract Approvable is Explorable {

    function _allowance(uint _tokenId, address _operator) internal view returns (uint) {
        return ERC3525Storage
            .layout()
            .accounts[_ownerOf(_tokenId)]
            .tokenApprovals[_tokenId][_operator];
    }

    function _getApproved(uint _tokenId) internal view returns (address operator) {
        operator = ERC3525Storage
            .layout()
            .tokens[_tokenId]
            .approved;
    }

    function _isApprovedForAll(address _owner, address _operator) internal view virtual returns (bool) {
        return ERC3525Storage
            .layout()
            .accounts[_owner]
            .operatorApprovals[_operator];
    }

    function _isApprovedOrOwner(address _operator, uint _tokenId) internal view virtual returns (bool) {
        address owner = _ownerOf(_tokenId);
        return (
            _operator == owner ||
            _isApprovedForAll(owner, _operator) ||
            _getApproved(_tokenId) == _operator
        );
    }

    function _approve(address _to, uint _tokenId) internal virtual {
        ERC3525Storage
            .layout()
            .tokens[_tokenId]
            .approved = _to;
        // emit Events.Approval(_ownerOf(tokenId_), to_, tokenId_);
    }

    function _approveValue(
        uint256 _tokenId,
        address _operator,
        uint256 _value
    ) internal virtual {
        require(_operator != address(0), "ERC3525: approve value to the zero address");
        ERC3525Storage
            .layout()
            .accounts[msg.sender]
            .tokenApprovals[_tokenId][_operator] = _value;

        // emit Events.ApprovalValue(tokenId_, to_, value_);
    }

    function _setApprovalForAll(
        address _owner,
        address _operator,
        bool _approved
    ) internal virtual {
        require(_owner != _operator, "ERC3525: approve to caller");

        ERC3525Storage
            .layout()
            .accounts[_owner]
            .operatorApprovals[_operator] = _approved;

        // emit Events.ApprovalForAll(owner_, operator_, approved_);
    }

    function _spendAllowance(address _operator, uint256 _tokenId, uint256 _value) internal {
        uint256 currentAllowance = _allowance(_tokenId, _operator);
        if (!_isApprovedOrOwner(_operator, _tokenId) && currentAllowance != type(uint256).max) {
            require(currentAllowance >= _value, "ERC3525: insufficient allowance");
            _approveValue(_tokenId, _operator, currentAllowance - _value);
        }
    }

}