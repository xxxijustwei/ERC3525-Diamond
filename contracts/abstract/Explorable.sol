// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { ERC3525Storage } from "../storage/ERC3525Storage.sol";

abstract contract Explorable {

    function _name() internal view returns (string memory) {
        return ERC3525Storage
            .layout()
            .name;
    }

    function _symbol() internal view returns (string memory) {
        return ERC3525Storage
            .layout()
            .symbol;
    }

    function _valueDecimals() internal view returns (uint8) {
        return ERC3525Storage
            .layout()
            .decimals;
    }

    function _balanceOf(uint256 _tokenId) internal view returns (uint256) {
        return ERC3525Storage
            .layout()
            .tokens[_tokenId]
            .balance;
    }

    function _balanceOf(address _owner) internal view returns (uint256) {
        return ERC3525Storage
            .layout()
            .accounts[_owner]
            .ownedTokens.length;
    }

    function _slotOf(uint256 _tokenId) internal view returns (uint256) {
        return ERC3525Storage
            .layout()
            .tokens[_tokenId]
            .slot;
    }

    function _ownerOf(uint256 _tokenId) internal view returns (address) {
        return ERC3525Storage
            .layout()
            .tokens[_tokenId]
            .owner;
    }

    function _requireMinted(uint256 _tokenId) internal view virtual {
        require(_exists(_tokenId), "ERC3525: invalid token ID");
    }

    function _exists(uint256 _tokenId) internal view returns (bool) {
        return ERC3525Storage
            .layout()
            .tokens[_tokenId]
            .id == _tokenId;
    }
}