// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
*
* Implementation of a diamond.
/******************************************************************************/

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

import { LibDiamond } from "../libraries/LibDiamond.sol";
import { ERC3525Storage } from "../storage/ERC3525Storage.sol";
import { IDiamondLoupe } from "../interfaces/IDiamondLoupe.sol";
import { IDiamondCut } from "../interfaces/IDiamondCut.sol";
import { IERC173 } from "../interfaces/IERC173.sol";
import { IERC3525 } from "../interfaces/erc3525/IERC3525.sol";
import { IERC3525Metadata } from "../interfaces/erc3525/IERC3525Metadata.sol";
import { IERC3525SlotApprovable } from "../interfaces/erc3525/IERC3525SlotApprovable.sol";
import { IERC3525SlotEnumerable } from "../interfaces/erc3525/IERC3525SlotEnumerable.sol";

// It is expected that this contract is customized if you want to deploy your diamond
// with data from a deployment script. Use the init function to initialize state variables
// of your diamond. Add parameters to the init function if you need to.

contract DiamondInit {

    struct SFTConfig {
        string name;
        string symbol;
        uint8 decimals;
    }

    // You can add parameters to this function in order to pass in 
    // data to set your own state variables
    function init(SFTConfig memory config) external {
        ERC3525Storage.AppStorage storage layout = ERC3525Storage.layout();
        layout.name = config.name;
        layout.symbol = config.symbol;
        layout.decimals = config.decimals;

        // adding ERC165 data
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;

        ds.supportedInterfaces[type(IERC721).interfaceId] = true;
        ds.supportedInterfaces[type(IERC721Metadata).interfaceId] = true;
        ds.supportedInterfaces[type(IERC721Enumerable).interfaceId] = true;
        ds.supportedInterfaces[type(IERC3525).interfaceId] = true;
        ds.supportedInterfaces[type(IERC3525Metadata).interfaceId] = true;

        ds.supportedInterfaces[type(IERC3525SlotApprovable).interfaceId] = true;
        ds.supportedInterfaces[type(IERC3525SlotEnumerable).interfaceId] = true;

        // add your own state variables 
        // EIP-2535 specifies that the `diamondCut` function takes two optional 
        // arguments: address _init and bytes calldata _calldata
        // These arguments are used to execute an arbitrary function using delegatecall
        // in order to set state variables in the diamond during deployment or an upgrade
        // More info here: https://eips.ethereum.org/EIPS/eip-2535#diamond-interface 
    }


}