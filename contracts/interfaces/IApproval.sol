// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IApproval {

    function allowance(uint _tokenId, address _operator) external view returns (uint);

    function getApproved(uint _tokenId) external view returns (address);

    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

    function approve(address _to, uint _tokenId) external payable;

    function approve(uint _tokenId, address _to, uint _value) external payable;

    function setApprovalForAll(address _operator, bool _approved) external;
    
}