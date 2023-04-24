// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

import { ERC3525Storage } from "../storage/ERC3525Storage.sol";
import { Explorable } from "../abstract/Explorable.sol";

contract MetadataFacet is Explorable {

    using Strings for uint;

    function tokenURI(uint _tokenId) external view virtual returns (string memory) {
        _requireMinted(_tokenId);
        return 
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        abi.encodePacked(
                            /* solhint-disable */
                            '{"name":"',
                            _tokenName(_tokenId),
                            '","description":"',
                            _tokenDescription(_tokenId),
                            '","image":"',
                            _tokenImage(_tokenId),
                            '","balance":"',
                            _balanceOf(_tokenId).toString(),
                            '","slot":"',
                            _slotOf(_tokenId).toString(),
                            '","properties":',
                            _tokenProperties(_tokenId),
                            "}"
                            /* solhint-enable */
                        )
                    )
                )
            );
    }

    function contractURI() external view virtual returns (string memory) {
        ERC3525Storage.AppStorage storage layout = ERC3525Storage.layout();
        return 
            string(
                abi.encodePacked(
                    /* solhint-disable */
                    'data:application/json;base64,',
                    Base64.encode(
                        abi.encodePacked(
                            '{"name":"', 
                            layout.name,
                            '","description":"',
                            _contractDescription(),
                            '","image":"',
                            _contractImage(),
                            '","valueDecimals":"', 
                            uint(layout.decimals).toString(),
                            '"}'
                        )
                    )
                    /* solhint-enable */
                )
            );
    }

    function slotURI(uint slot_) external view virtual returns (string memory) {
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

    function _tokenName(uint _tokenId) internal view virtual returns (string memory) {
        // solhint-disable-next-line
        return 
            string(
                abi.encodePacked(
                    ERC3525Storage.layout().name, 
                    " #", _tokenId.toString()
                )
            );
    }

    function _tokenDescription(uint _tokenId) internal view virtual returns (string memory) {
        _tokenId;
        return "";
    }

    function _tokenImage(uint _tokenId) internal view virtual returns (bytes memory) {
        _tokenId;
        return "";
    }

    function _tokenProperties(uint _tokenId) internal view virtual returns (string memory) {
        _tokenId;
        return "{}";
    }

    function _contractDescription() internal view virtual returns (string memory) {
        return "";
    }

    function _contractImage() internal view virtual returns (bytes memory) {
        return "";
    }

    function _slotName(uint slot_) internal view virtual returns (string memory) {
        slot_;
        return "";
    }

    function _slotDescription(uint slot_) internal view virtual returns (string memory) {
        slot_;
        return "";
    }

    function _slotImage(uint slot_) internal view virtual returns (bytes memory) {
        slot_;
        return "";
    }

    function _slotProperties(uint slot_) internal view virtual returns (string memory) {
        slot_;
        return "[]";
    }
}