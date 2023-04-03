// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { ERC3525Storage } from "../storage/ERC3525Storage.sol";
import { Substrate } from "../Substrate.sol";

contract InformationFacet is Substrate {

    function name() external view returns (string memory) {
        return ERC3525Storage.get().name;
    }

    function symbol() external view returns (string memory) {
        return ERC3525Storage.get().symbol;
    }

    function valueDecimals() external view returns (uint) {
        return ERC3525Storage.get().decimals;
    }

    function balanceOf(address owner_) external view returns (uint256 balance) {
        balance = _balanceOf(owner_);
    }

    function balanceOf(uint256 tokenId_) external view returns (uint256) {
        return _balanceOf(tokenId_);
    }

    function slotOf(uint256 tokenId_) external view returns (uint256) {
        return _slotOf(tokenId_);
    }

    function ownerOf(uint256 tokenId_) external view returns (address owner) {
        owner = _ownerOf(tokenId_);
    }
    
    function _balanceOf(address owner_) internal view returns (uint256) {
        require(owner_ != address(0), "ERC3525: balance query for the zero address");
        return ERC3525Storage.get().addressData[owner_].ownedTokens.length;
    }
}