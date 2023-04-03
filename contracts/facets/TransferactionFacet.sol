// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import { ERC3525Storage } from "../storage/ERC3525Storage.sol";
import { Substrate } from "../Substrate.sol";
import { IERC3525Receiver } from "../interfaces/erc3525/IERC3525Receiver.sol";
import { IERC165 } from "../interfaces/IERC165.sol";
import { Events } from "../libraries/Events.sol";
import "../libraries/Structs.sol";

contract TransferactionFacet is Substrate {
    using Address for address;
    using Counters for Counters.Counter;

    function transferFrom(
        uint256 fromTokenId_,
        uint256 toTokenId_,
        uint256 value_
    ) external payable {
        _spendAllowance(msg.sender, fromTokenId_, value_);
        _transferValue(fromTokenId_, toTokenId_, value_);
    }

    function transferFrom(
        uint256 fromTokenId_,
        address to_,
        uint256 value_
    ) external payable returns (uint256 newTokenId) {
        _spendAllowance(msg.sender, fromTokenId_, value_);

        newTokenId = _createOriginalTokenId();
        _mint(to_, newTokenId, _slotOf(fromTokenId_), 0);
        _transferValue(fromTokenId_, newTokenId, value_);
    }

    function safeTransferFrom(
        address from_,
        address to_,
        uint256 tokenId_,
        bytes calldata data_
    ) external {
        require(_isApprovedOrOwner(msg.sender, tokenId_), "ERC3525: transfer caller is not owner nor approved");
        _safeTransferTokenId(from_, to_, tokenId_, data_);
    }

    function safeTransferFrom(
        address from_,
        address to_,
        uint256 tokenId_
    ) external {
        require(_isApprovedOrOwner(msg.sender, tokenId_), "ERC3525: transfer caller is not owner nor approved");
        _safeTransferTokenId(from_, to_, tokenId_, "");
    }

    function transferFrom(
        address from_,
        address to_,
        uint256 tokenId_
    ) external {
        require(_isApprovedOrOwner(msg.sender, tokenId_), "ERC3525: transfer caller is not owner nor approved");
        _transferTokenId(from_, to_, tokenId_);
    }

    function _createOriginalTokenId() internal virtual returns (uint256) {
        ERC3525Storage.AppStorage storage s = ERC3525Storage.get();
        s.tokenIdGenerator.increment();
        return s.tokenIdGenerator.current();
    }

    function _clearApprovedValues(uint256 tokenId_) internal virtual {
        ERC3525Storage.AppStorage storage s = ERC3525Storage.get();
        TokenData storage tokenData = s.allTokens[s.allTokensIndex[tokenId_]];
        uint256 length = tokenData.valueApprovals.length;
        for (uint256 i = 0; i < length; i++) {
            address approval = tokenData.valueApprovals[i];
            delete s.approvedValues[tokenId_][approval];
        }
        delete tokenData.valueApprovals;
    }

    function _mint(address to_, uint256 slot_, uint256 value_) internal returns (uint256 tokenId) {
        tokenId = _createOriginalTokenId();
        _mint(to_, tokenId, slot_, value_);  
    }

    function _mint(address to_, uint256 tokenId_, uint256 slot_, uint256 value_) internal {
        require(to_ != address(0), "ERC3525: mint to the zero address");
        require(tokenId_ != 0, "ERC3525: cannot mint zero tokenId");
        require(!_exists(tokenId_), "ERC3525: token already minted");

        _beforeValueTransfer(address(0), to_, 0, tokenId_, slot_, value_);
        __mintToken(to_, tokenId_, slot_);
        __mintValue(tokenId_, value_);
        _afterValueTransfer(address(0), to_, 0, tokenId_, slot_, value_);
    }

    function _mintValue(uint256 tokenId_, uint256 value_) internal {
        address owner = _ownerOf(tokenId_);
        uint256 slot = _slotOf(tokenId_);
        _beforeValueTransfer(address(0), owner, 0, tokenId_, slot, value_);
        __mintValue(tokenId_, value_);
        _afterValueTransfer(address(0), owner, 0, tokenId_, slot, value_);
    }

    function __mintValue(uint256 tokenId_, uint256 value_) private {
        ERC3525Storage.AppStorage storage s = ERC3525Storage.get();
        s.allTokens[s.allTokensIndex[tokenId_]].balance += value_;
        emit Events.TransferValue(0, tokenId_, value_);
    }

    function __mintToken(address to_, uint256 tokenId_, uint256 slot_) private {
        TokenData memory tokenData = TokenData({
            id: tokenId_,
            slot: slot_,
            balance: 0,
            owner: to_,
            approved: address(0),
            valueApprovals: new address[](0)
        });

        _addTokenToAllTokensEnumeration(tokenData);
        _addTokenToOwnerEnumeration(to_, tokenId_);

        emit Events.Transfer(address(0), to_, tokenId_);
        emit Events.SlotChanged(tokenId_, 0, slot_);
    }

    function _burn(uint256 tokenId_) internal {
        _requireMinted(tokenId_);

        ERC3525Storage.AppStorage storage s = ERC3525Storage.get();
        TokenData storage tokenData = s.allTokens[s.allTokensIndex[tokenId_]];
        address owner = tokenData.owner;
        uint256 slot = tokenData.slot;
        uint256 value = tokenData.balance;

        _beforeValueTransfer(owner, address(0), tokenId_, 0, slot, value);

        _clearApprovedValues(tokenId_);
        _removeTokenFromOwnerEnumeration(owner, tokenId_);
        _removeTokenFromAllTokensEnumeration(tokenId_);

        emit Events.TransferValue(tokenId_, 0, value);
        emit Events.SlotChanged(tokenId_, slot, 0);
        emit Events.Transfer(owner, address(0), tokenId_);

        _afterValueTransfer(owner, address(0), tokenId_, 0, slot, value);
    }

    function _burnValue(uint256 tokenId_, uint256 burnValue_) internal virtual {
        _requireMinted(tokenId_);

        ERC3525Storage.AppStorage storage s = ERC3525Storage.get();
        TokenData storage tokenData = s.allTokens[s.allTokensIndex[tokenId_]];
        address owner = tokenData.owner;
        uint256 slot = tokenData.slot;
        uint256 value = tokenData.balance;

        require(value >= burnValue_, "ERC3525: burn value exceeds balance");

        _beforeValueTransfer(owner, address(0), tokenId_, 0, slot, burnValue_);
        
        tokenData.balance -= burnValue_;
        emit Events.TransferValue(tokenId_, 0, burnValue_);
        
        _afterValueTransfer(owner, address(0), tokenId_, 0, slot, burnValue_);
    }

    function _transferTokenId(
        address from_,
        address to_,
        uint256 tokenId_
    ) internal virtual {
        require(_ownerOf(tokenId_) == from_, "ERC3525: transfer from invalid owner");
        require(to_ != address(0), "ERC3525: transfer to the zero address");

        uint256 slot = _slotOf(tokenId_);
        uint256 value = _balanceOf(tokenId_);

        _beforeValueTransfer(from_, to_, tokenId_, tokenId_, slot, value);

        _approve(address(0), tokenId_);
        _clearApprovedValues(tokenId_);

        _removeTokenFromOwnerEnumeration(from_, tokenId_);
        _addTokenToOwnerEnumeration(to_, tokenId_);

        emit Events.Transfer(from_, to_, tokenId_);

        _afterValueTransfer(from_, to_, tokenId_, tokenId_, slot, value);
    }

    function _safeTransferTokenId(
        address from_,
        address to_,
        uint256 tokenId_,
        bytes memory data_
    ) internal virtual {
        _transferTokenId(from_, to_, tokenId_);
        require(
            _checkOnERC721Received(from_, to_, tokenId_, data_),
            "ERC3525: transfer to non ERC721Receiver"
        );
    }

    function _transferValue(
        uint256 fromTokenId_,
        uint256 toTokenId_,
        uint256 value_
    ) internal virtual {
        require(_exists(fromTokenId_), "ERC3525: transfer from invalid token ID");
        require(_exists(toTokenId_), "ERC3525: transfer to invalid token ID");

        ERC3525Storage.AppStorage storage s = ERC3525Storage.get();
        TokenData storage fromTokenData = s.allTokens[s.allTokensIndex[fromTokenId_]];
        TokenData storage toTokenData = s.allTokens[s.allTokensIndex[toTokenId_]];

        require(fromTokenData.balance >= value_, "ERC3525: insufficient balance for transfer");
        require(fromTokenData.slot == toTokenData.slot, "ERC3525: transfer to token with different slot");

        _beforeValueTransfer(
            fromTokenData.owner,
            toTokenData.owner,
            fromTokenId_,
            toTokenId_,
            fromTokenData.slot,
            value_
        );

        fromTokenData.balance -= value_;
        toTokenData.balance += value_;

        emit Events.TransferValue(fromTokenId_, toTokenId_, value_);

        _afterValueTransfer(
            fromTokenData.owner,
            toTokenData.owner,
            fromTokenId_,
            toTokenId_,
            fromTokenData.slot,
            value_
        );

        require(
            _checkOnERC3525Received(fromTokenId_, toTokenId_, value_, ""),
            "ERC3525: transfer rejected by ERC3525Receiver"
        );
    }

    function _addTokenToOwnerEnumeration(address to_, uint256 tokenId_) private {
        ERC3525Storage.AppStorage storage s = ERC3525Storage.get();
        s.allTokens[s.allTokensIndex[tokenId_]].owner = to_;

        s.addressData[to_].ownedTokensIndex[tokenId_] = s.addressData[to_].ownedTokens.length;
        s.addressData[to_].ownedTokens.push(tokenId_);
    }

    function _removeTokenFromOwnerEnumeration(address from_, uint256 tokenId_) private {
        ERC3525Storage.AppStorage storage s = ERC3525Storage.get();
        s.allTokens[s.allTokensIndex[tokenId_]].owner = address(0);

        AddressData storage ownerData = s.addressData[from_];
        uint256 lastTokenIndex = ownerData.ownedTokens.length - 1;
        uint256 lastTokenId = ownerData.ownedTokens[lastTokenIndex];
        uint256 tokenIndex = ownerData.ownedTokensIndex[tokenId_];

        ownerData.ownedTokens[tokenIndex] = lastTokenId;
        ownerData.ownedTokensIndex[lastTokenId] = tokenIndex;

        delete ownerData.ownedTokensIndex[tokenId_];
        ownerData.ownedTokens.pop();
    }

    function _addTokenToAllTokensEnumeration(TokenData memory tokenData_) private {
        ERC3525Storage.AppStorage storage s = ERC3525Storage.get();
        s.allTokensIndex[tokenData_.id] = s.allTokens.length;
        s.allTokens.push(tokenData_);
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId_) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).
        ERC3525Storage.AppStorage storage s = ERC3525Storage.get();

        uint256 lastTokenIndex = s.allTokens.length - 1;
        uint256 tokenIndex = s.allTokensIndex[tokenId_];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        TokenData memory lastTokenData = s.allTokens[lastTokenIndex];

        s.allTokens[tokenIndex] = lastTokenData; // Move the last token to the slot of the to-delete token
        s.allTokensIndex[lastTokenData.id] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete s.allTokensIndex[tokenId_];
        s.allTokens.pop();
    }

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

    /* solhint-disable */
    function _beforeValueTransfer(
        address from_,
        address to_,
        uint256 fromTokenId_,
        uint256 toTokenId_,
        uint256 slot_,
        uint256 value_
    ) internal virtual {}

    function _afterValueTransfer(
        address from_,
        address to_,
        uint256 fromTokenId_,
        uint256 toTokenId_,
        uint256 slot_,
        uint256 value_
    ) internal virtual {}
    /* solhint-enable */
}