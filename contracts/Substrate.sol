// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { ERC3525Storage } from "./storage/ERC3525Storage.sol";
import { Events } from "./libraries/Events.sol";

contract Substrate {

    function _requireMinted(uint256 tokenId_) internal view virtual {
        require(_exists(tokenId_), "ERC3525: invalid token ID");
    }

    function _exists(uint256 tokenId_) internal view returns (bool) {
        ERC3525Storage.AppStorage storage s = ERC3525Storage.get();
        return s.allTokens.length != 0 && s.allTokens[s.allTokensIndex[tokenId_]].id == tokenId_;
    }

    function _balanceOf(uint256 tokenId_) internal view returns (uint256) {
        _requireMinted(tokenId_);
        ERC3525Storage.AppStorage storage s = ERC3525Storage.get();
        return s.allTokens[s.allTokensIndex[tokenId_]].balance;
    }

    function _slotOf(uint256 tokenId_) internal view returns (uint256) {
        _requireMinted(tokenId_);
        ERC3525Storage.AppStorage storage s = ERC3525Storage.get();
        return s.allTokens[s.allTokensIndex[tokenId_]].slot;
    }

    function _ownerOf(uint256 tokenId_) internal view returns (address owner_) {
        _requireMinted(tokenId_);
        ERC3525Storage.AppStorage storage s = ERC3525Storage.get();
        owner_ = s.allTokens[s.allTokensIndex[tokenId_]].owner;
        require(owner_ != address(0), "ERC3525: invalid token ID");
    }

    function _allowance(uint256 tokenId_, address operator_) internal view returns (uint256) {
        _requireMinted(tokenId_);
        return ERC3525Storage.get().approvedValues[tokenId_][operator_];
    }

    function _spendAllowance(address operator_, uint256 tokenId_, uint256 value_) internal {
        uint256 currentAllowance = _allowance(tokenId_, operator_);
        if (!_isApprovedOrOwner(operator_, tokenId_) && currentAllowance != type(uint256).max) {
            require(currentAllowance >= value_, "ERC3525: insufficient allowance");
            _approveValue(tokenId_, operator_, currentAllowance - value_);
        }
    }

    function _existApproveValue(address to_, uint256 tokenId_) internal view virtual returns (bool) {
        ERC3525Storage.AppStorage storage s = ERC3525Storage.get();
        uint256 length = s.allTokens[s.allTokensIndex[tokenId_]].valueApprovals.length;
        for (uint256 i = 0; i < length; i++) {
            if (s.allTokens[s.allTokensIndex[tokenId_]].valueApprovals[i] == to_) {
                return true;
            }
        }
        return false;
    }

    function _approve(address to_, uint256 tokenId_) internal virtual {
        ERC3525Storage.AppStorage storage s = ERC3525Storage.get();
        s.allTokens[s.allTokensIndex[tokenId_]].approved = to_;
        emit Events.Approval(_ownerOf(tokenId_), to_, tokenId_);
    }

    function _approveValue(
        uint256 tokenId_,
        address to_,
        uint256 value_
    ) internal virtual {
        require(to_ != address(0), "ERC3525: approve value to the zero address");
        ERC3525Storage.AppStorage storage s = ERC3525Storage.get();
        if (!_existApproveValue(to_, tokenId_)) {
            s.allTokens[s.allTokensIndex[tokenId_]].valueApprovals.push(to_);
        }
        s.approvedValues[tokenId_][to_] = value_;

        emit Events.ApprovalValue(tokenId_, to_, value_);
    }

    function _getApproved(uint256 tokenId_) internal view returns (address operator) {
        _requireMinted(tokenId_);
        ERC3525Storage.AppStorage storage s = ERC3525Storage.get();
        operator = s.allTokens[s.allTokensIndex[tokenId_]].approved;
    }

    function _isApprovedForAll(address owner_, address operator_) internal view returns (bool) {
        return ERC3525Storage.get().addressData[owner_].approvals[operator_];
    }

    function _isApprovedOrOwner(address operator_, uint256 tokenId_) internal view virtual returns (bool) {
        address owner = _ownerOf(tokenId_);
        return (
            operator_ == owner ||
            _isApprovedForAll(owner, operator_) ||
            _getApproved(tokenId_) == operator_
        );
    }    
}