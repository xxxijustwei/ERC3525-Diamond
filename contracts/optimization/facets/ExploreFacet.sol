// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { ERC3525Storage } from "../storage/ERC3525Storage.sol";
import { IExplore } from "../interfaces/IExplore.sol";
import { Explorable } from "../abstract/Explorable.sol";

contract ExploreFacet is IExplore, Explorable {

    function name() external view returns (string memory) {
        return _name();
    }

    function symbol() external view returns (string memory) {
        return _symbol();
    }

    function valueDecimals() external view returns (uint8) {
        return _valueDecimals();
    }

    function balanceOf(uint _tokenId) external view returns (uint) {
        return _balanceOf(_tokenId);
    }

    function balanceOf(address _owner) external view returns (uint) {
        return _balanceOf(_owner);
    }

    function slotOf(uint256 _tokenId) external view returns (uint256) {
        return _slotOf(_tokenId);
    }

    function ownerOf(uint256 _tokenId) external view returns (address owner) {
        owner = _ownerOf(_tokenId);
    }
    
}