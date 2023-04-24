// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IExplore {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function valueDecimals() external view returns (uint8);

    function balanceOf(uint _tokenId) external view returns (uint);

    function balanceOf(address _owner) external view returns (uint);

    function slotOf(uint256 _tokenId) external view returns (uint256);

    function ownerOf(uint256 _tokenId) external view returns (address owner);
    
}