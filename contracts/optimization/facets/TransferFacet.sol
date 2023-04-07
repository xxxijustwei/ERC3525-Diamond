// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import { IERC3525Receiver } from "../../interfaces/erc3525/IERC3525Receiver.sol";
import { IERC165 } from "../../interfaces/IERC165.sol";

import { ERC3525Storage } from "../storage/ERC3525Storage.sol";
import { Approvable } from "../abstract/Approvable.sol";
import "../libraries/Structs.sol";

contract TransferFacet is Approvable {

    using Address for address;
    using Counters for Counters.Counter;

    function transferFrom(
        address _from,
        address _to,
        uint _tokenId
    ) external virtual {
        require(_isApprovedOrOwner(msg.sender, _tokenId), "ERC3525: transfer caller is not owner nor approved");
        _transferTokenId(_from, _to, _tokenId);
    }

    function transferFrom(
        uint _fromTokenId,
        uint _toTokenId,
        uint _value
    ) external virtual payable {
        _spendAllowance(msg.sender, _fromTokenId, _value);
        _transferValue(_fromTokenId, _toTokenId, _value);
    }

    function transferFrom(
        uint _fromTokenId,
        address _to,
        uint _value
    ) external virtual payable returns (uint newTokenId) {
        _spendAllowance(msg.sender, _fromTokenId, _value);

        newTokenId = _createOriginalTokenId();
        _mint(_to, newTokenId, _slotOf(_fromTokenId), 0);
        _transferValue(_fromTokenId, newTokenId, _value);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata _data
    ) external virtual {
        require(_isApprovedOrOwner(msg.sender, _tokenId), "ERC3525: transfer caller is not owner nor approved");
        _safeTransferTokenId(_from, _to, _tokenId, _data);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external virtual {
        require(_isApprovedOrOwner(msg.sender, _tokenId), "ERC3525: transfer caller is not owner nor approved");
        _safeTransferTokenId(_from, _to, _tokenId, "");
    }

    ///----------------------- Mint / Burn (Internal) -----------------------///

    function _mint(address _to, uint256 _slot, uint256 _value) internal virtual returns (uint256 tokenId) {
        tokenId = _createOriginalTokenId();
        _mint(_to, tokenId, _slot, _value);  
    }

    function _mint(address _to, uint256 _tokenId, uint256 _slot, uint256 _value) internal virtual {
        require(_to != address(0), "ERC3525: mint to the zero address");
        require(_tokenId != 0, "ERC3525: cannot mint zero tokenId");
        require(!_exists(_tokenId), "ERC3525: token already minted");

        _beforeValueTransfer(address(0), _to, 0, _tokenId, _slot, _value);
        __mintToken(_to, _tokenId, _slot);
        __mintValue(_tokenId, _value);
        _afterValueTransfer(address(0), _to, 0, _tokenId, _slot, _value);
    }

    function _mintValue(uint256 _tokenId, uint256 _value) internal virtual {
        address owner = _ownerOf(_tokenId);
        uint256 slot = _slotOf(_tokenId);
        _beforeValueTransfer(address(0), owner, 0, _tokenId, slot, _value);
        __mintValue(_tokenId, _value);
        _afterValueTransfer(address(0), owner, 0, _tokenId, slot, _value);
    }

    function __mintValue(uint256 _tokenId, uint256 _value) private {
        ERC3525Storage.AppStorage storage layout = ERC3525Storage.layout();
        layout.tokens[_tokenId].balance += _value;
        // emit Events.TransferValue(0, _tokenId, _value);
    }

    function __mintToken(address _to, uint256 _tokenId, uint256 _slot) private {
        TokenData storage tokenData = ERC3525Storage.layout().tokens[_tokenId];
        tokenData.id = _tokenId;
        tokenData.slot = _slot;
        tokenData.owner = _to;

        _addTokenToOwnerEnumeration(_to, _tokenId);

        // emit Events.Transfer(address(0), _to, _tokenId);
        // emit Events.SlotChanged(_tokenId, 0, _slot);
    }

    function _burn(uint256 _tokenId) internal virtual {
        _requireMinted(_tokenId);

        ERC3525Storage.AppStorage storage layout = ERC3525Storage.layout();
        TokenData storage tokenData = layout.tokens[_tokenId];
        address owner = tokenData.owner;
        uint256 slot = tokenData.slot;
        uint256 value = tokenData.balance;

        _beforeValueTransfer(owner, address(0), _tokenId, 0, slot, value);

        _removeTokenFromOwnerEnumeration(owner, _tokenId);

        // emit Events.TransferValue(_tokenId, 0, value);
        // emit Events.SlotChanged(_tokenId, slot, 0);
        // emit Events.Transfer(owner, address(0), _tokenId);

        _afterValueTransfer(owner, address(0), _tokenId, 0, slot, value);
    }

    function _burnValue(uint256 _tokenId, uint256 _value) internal virtual {
        _requireMinted(_tokenId);

        ERC3525Storage.AppStorage storage layout = ERC3525Storage.layout();
        TokenData storage tokenData = layout.tokens[_tokenId];
        address owner = tokenData.owner;
        uint256 slot = tokenData.slot;
        uint256 value = tokenData.balance;

        require(value >= _value, "ERC3525: burn value exceeds balance");

        _beforeValueTransfer(owner, address(0), _tokenId, 0, slot, _value);
        
        tokenData.balance -= _value;
        // emit Events.TransferValue(_tokenId, 0, _value);
        
        _afterValueTransfer(owner, address(0), _tokenId, 0, slot, _value);
    }

    ///----------------------- Generate new token id -----------------------///

    function _createOriginalTokenId() internal virtual returns (uint256) {
        ERC3525Storage.AppStorage storage layout = ERC3525Storage.layout();
        layout.tokenIdGenerator.increment();
        return layout.tokenIdGenerator.current();
    }

    ///----------------------- Token transfer (Internal) -----------------------///

    function _transferTokenId(
        address _from,
        address _to,
        uint _tokenId
    ) internal virtual {
        require(_ownerOf(_tokenId) == _from, "ERC3525: transfer from invalid owner");
        require(_to != address(0), "ERC3525: transfer to the zero address");

        uint slot = _slotOf(_tokenId);
        uint value = _balanceOf(_tokenId);

        _beforeValueTransfer(_from, _to, _tokenId, _tokenId, slot, value);

        _approve(address(0), _tokenId);

        _removeTokenFromOwnerEnumeration(_from, _tokenId);
        _addTokenToOwnerEnumeration(_to, _tokenId);

        // emit Events.Transfer(_from, _to, _tokenId);

        _afterValueTransfer(_from, _to, _tokenId, _tokenId, slot, value);
    }

    function _safeTransferTokenId(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) internal virtual {
        _transferTokenId(_from, _to, _tokenId);
        require(
            _checkOnERC721Received(_from, _to, _tokenId, _data),
            "ERC3525: transfer to non ERC721Receiver"
        );
    }

    function _transferValue(
        uint256 _fromTokenId,
        uint256 _toTokenId,
        uint256 _value
    ) internal virtual {
        require(_exists(_fromTokenId), "ERC3525: transfer from invalid token ID");
        require(_exists(_toTokenId), "ERC3525: transfer to invalid token ID");

        ERC3525Storage.AppStorage storage layout = ERC3525Storage.layout();
        TokenData storage fromTokenData = layout.tokens[_fromTokenId];
        TokenData storage toTokenData = layout.tokens[_toTokenId];

        require(fromTokenData.balance >= _value, "ERC3525: insufficient balance for transfer");
        require(fromTokenData.slot == toTokenData.slot, "ERC3525: transfer to token with different slot");

        _beforeValueTransfer(
            fromTokenData.owner,
            toTokenData.owner,
            _fromTokenId,
            _toTokenId,
            fromTokenData.slot,
            _value
        );

        fromTokenData.balance -= _value;
        toTokenData.balance += _value;

        // emit Events.TransferValue(_fromTokenId, _toTokenId, _value);

        _afterValueTransfer(
            fromTokenData.owner,
            toTokenData.owner,
            _fromTokenId,
            _toTokenId,
            fromTokenData.slot,
            _value
        );

        require(
            _checkOnERC3525Received(_fromTokenId, _toTokenId, _value, ""),
            "ERC3525: transfer rejected by ERC3525Receiver"
        );
    }

    ///----------------------- Owner enumeration -----------------------///

    function _removeTokenFromOwnerEnumeration(address _from, uint _tokenId) private {
        ERC3525Storage.AppStorage storage layout = ERC3525Storage.layout();
        layout.tokens[_tokenId].owner = address(0);

        Account storage account = layout.accounts[_from];
        uint lastTokenIndex = account.ownedTokens.length - 1;
        uint lastTokenId = account.ownedTokens[lastTokenIndex];
        uint tokenIndex = account.ownedTokensIndex[_tokenId];

        account.ownedTokens[tokenIndex] = lastTokenId;
        account.ownedTokensIndex[lastTokenId] = tokenIndex;

        delete account.ownedTokensIndex[_tokenId];
        account.ownedTokens.pop();
    }

    function _addTokenToOwnerEnumeration(address _to, uint _tokenId) private {
        ERC3525Storage.AppStorage storage layout = ERC3525Storage.layout();
        layout.tokens[_tokenId].owner = _to;

        Account storage account = layout.accounts[_to];
        account.ownedTokensIndex[_tokenId] = account.ownedTokens.length;
        account.ownedTokens.push(_tokenId);
    }

    ///----------------------- Check received -----------------------///
    function _checkOnERC721Received(
        address from_,
        address to_,
        uint256 tokenId_,
        bytes memory data_
    ) private returns (bool) {
        if (to_.isContract()) {
            try 
                IERC721Receiver(to_).onERC721Received(msg.sender, from_, tokenId_, data_) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _checkOnERC3525Received( 
        uint256 fromTokenId_, 
        uint256 toTokenId_, 
        uint256 value_, 
        bytes memory data_
    ) private returns (bool) {
        address to = _ownerOf(toTokenId_);
        if (to.isContract() && IERC165(to).supportsInterface(type(IERC3525Receiver).interfaceId)) {
            bytes4 retval = IERC3525Receiver(to).onERC3525Received(msg.sender, fromTokenId_, toTokenId_, value_, data_);
            return retval == IERC3525Receiver.onERC3525Received.selector;
        } else {
            return true;
        }
    }

    ///----------------------- Value change -----------------------///

    /* solhint-disable */
    function _beforeValueTransfer(
        address _from,
        address _to,
        uint _fromTokenId,
        uint _toTokenId,
        uint _slot,
        uint _value
    ) internal virtual {}

    function _afterValueTransfer(
        address _from,
        address _to,
        uint _fromTokenId,
        uint _toTokenId,
        uint _slot,
        uint _value
    ) internal virtual {}
    /* solhint-enable */
}