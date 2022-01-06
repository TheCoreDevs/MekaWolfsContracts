// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./Ownable.sol";

/**
 * @author Roi Di Segni (A.K.A. @sheeeev66)
 */

contract MekaWolfsFactory is Ownable, ERC3664Transferable, ERC721 {

    using Counters for Counters.Counter;

    // tracks the token ID
    Counters.Counter private _tokenIds;

    // tracks the attribute IDs
    Counters.Counter internal _attrIds;

    IMekaWolfsMetadata internal metadata;

    // call totalSupply() to get the amount of minted tokens
    uint public totalSupply;

    // owner of the attribute
    mapping(uint => address) ownerOfAttr;

    // how many attributes someone owns
    mapping(address => uint) attrBalanceOf;

    event NewMekaWolfMinted(uint id);

    constructor() {
        _tokenIds.increment();
    } // token ID 0 will be used as the null ID

    function setMetadataContract(address _address) external onlyOwner {
        metadata = IMekaWolfsMetadata(_address);
    }

    /**
     * How minting will work:
     * 
     * Whenever you generate something so it creates a new attribute.
     * Each token can't have the same attribute of the same Symbol.
     * 
     * 
     */

    function _mintWolf(address to) internal {
        uint id = _tokenIds.current();
        ERC721._safeMint(to, id);
        _mintAndAtachMetadata(id);
        _tokenIds.increment();
        totalSupply++;
    }

    function _mintAndAtachMetadata(uint tokenId) private {
        _mintAndAtachNextAttr(tokenId, "BACKGROUND");
        _mintAndAtachNextAttr(tokenId, "CHEST");
        _mintAndAtachNextAttr(tokenId, "HELMET");
        _mintAndAtachNextAttr(tokenId, "EYES");
        _mintAndAtachNextAttr(tokenId, "SNOUT");
        _mintAndAtachNextAttr(tokenId, "WEAPON");
        _mintAndAtachNextAttr(tokenId, "HANDS");
    }

    function _mintAndAtachNextAttr(uint tokenId, string memory symbol) private {
        uint attrId = _attrIds.current();

        _mintAndAtachAttr(
            tokenId,
            attrId,
            metadata.getRandomTrait(symbol),
            symbol
        );
        _attrIds.increment();
        
    }

    function _mintAndAtachAttr(uint tokenId, uint attrId, string memory name, string memory symbol) private {
        _mintAttr(attrId, name, symbol);
        ERC3664.atach(tokenId, attrId, 1);
    }

    function _mintAttr(uint attrId, string memory name, string memory symbol) internal {
        ERC3664._mint(attrId, name, symbol, "");
        ownerOfAttr[attrId] = msg.sender;
        attrBalanceOf[msg.sender]++;
    }

    // function _burnAttr(uint attrId, string memory name, string memory symbol) internal {
    //     require();
    //     ERC3664._burn(tokenId, attrId, amount);
    // }

    function _burnAttrFromToken(uint tokenId, uint attrId) internal {
        address owner = ownerOfAttr[attrId];

        uint256 tokenBalance = attrBalances[attrId][tokenId];
        require(
            tokenBalance >= amount,
            "ERC3664: insufficient balance for transfer"
        );

        attrBalanceOf[owner] -= 1;
        delete ownerOfAttr[attrId];

        unchecked {
            attrBalances[attrId][tokenId] = tokenBalance - amount;
        }

        emit TransferSingle(owner, tokenId, 0, attrId, 1);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC3664, ERC721)
        returns (bool)
    {
        return
            interfaceId == type(ERC3664Transferable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

}