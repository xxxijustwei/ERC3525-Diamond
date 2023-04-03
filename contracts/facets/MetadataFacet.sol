// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

import { ERC3525Storage } from "../storage/ERC3525Storage.sol";
import { Substrate } from "../Substrate.sol";

contract ERC3525MetadataFacet is Substrate {

    using Strings for uint256;

    function tokenURI(uint256 tokenId_) external view returns (string memory) {
        _requireMinted(tokenId_);
        return 
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        abi.encodePacked(
                            /* solhint-disable */
                            '{"name":"',
                            _tokenName(tokenId_),
                            '","description":"',
                            _tokenDescription(tokenId_),
                            '","image":"',
                            _tokenImage(tokenId_),
                            '","balance":"',
                            _balanceOf(tokenId_).toString(),
                            '","slot":"',
                            _slotOf(tokenId_).toString(),
                            '","properties":',
                            _tokenProperties(tokenId_),
                            "}"
                            /* solhint-enable */
                        )
                    )
                )
            );
    }

    function contractURI() external view returns (string memory) {
        ERC3525Storage.AppStorage storage s = ERC3525Storage.get();
        return 
            string(
                abi.encodePacked(
                    /* solhint-disable */
                    'data:application/json;base64,',
                    Base64.encode(
                        abi.encodePacked(
                            '{"name":"', 
                            s.name,
                            '","description":"',
                            _contractDescription(),
                            '","image":"',
                            _contractImage(),
                            '","valueDecimals":"', 
                            uint(s.decimals).toString(),
                            '"}'
                        )
                    )
                    /* solhint-enable */
                )
            );
    }

    function slotURI(uint256 slot_) external view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    /* solhint-disable */
                    'data:application/json;base64,',
                    Base64.encode(
                        abi.encodePacked(
                            '{"name":"', 
                            _slotName(slot_),
                            '","description":"',
                            _slotDescription(slot_),
                            '","image":"',
                            _slotImage(slot_),
                            '","properties":',
                            _slotProperties(slot_),
                            '}'
                        )
                    )
                    /* solhint-enable */
                )
            );
    }

    function _tokenName(uint256 tokenId_) internal view virtual returns (string memory) {
        // solhint-disable-next-line
        return 
            string(
                abi.encodePacked(
                    ERC3525Storage.get().name, 
                    " #", tokenId_.toString()
                )
            );
    }

    function _tokenDescription(uint256 tokenId_) internal view virtual returns (string memory) {
        tokenId_;
        return "";
    }

    function _tokenImage(uint256 tokenId_) internal view virtual returns (bytes memory) {
        tokenId_;
        return "";
    }

    function _tokenProperties(uint256 tokenId_) internal view virtual returns (string memory) {
        tokenId_;
        return "{}";
    }

    function _contractDescription() internal view virtual returns (string memory) {
        return "";
    }

    function _contractImage() internal view virtual returns (bytes memory) {
        return "";
    }

    function _slotName(uint256 slot_) internal view virtual returns (string memory) {
        slot_;
        return "";
    }

    function _slotDescription(uint256 slot_) internal view virtual returns (string memory) {
        slot_;
        return "";
    }

    function _slotImage(uint256 slot_) internal view virtual returns (bytes memory) {
        slot_;
        return "";
    }

    function _slotProperties(uint256 slot_) internal view virtual returns (string memory) {
        slot_;
        return "[]";
    }
}