// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC3664Transferable.sol";
import "./ERC721.sol";
import "./Ownable.sol";
import "./Counters.sol";
import "./IMekaWolfsMetadata.sol";

/**
 * @author Roi Di Segni (A.K.A. @sheeeev66)
 */

contract MekaWolfsFactory is Ownable, ERC3664Transferable, ERC721 {

    using Counters for Counters.Counter;

    // tracks the token ID
    Counters.Counter private _tokenIds;

    // tracks the attribute IDs
    Counters.Counter private _attrIds;

    IMekaWolfsMetadata internal metadata;

    // call totalSupply() to get the amount of minted tokens
    uint public totalSupply;

    // owner of the attribute
    mapping(uint => address) ownerOfAttr;

    // how many attributes someone owns
    mapping(address => uint) attrBalanceOf;

    event NewMekaWolfMinted(uint id);

    constructor() ERC3664("") ERC721("Meka Wolfs", "MKW") { } // use token id 0?

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
        _mintAndAttachMetadata(id);
        _tokenIds.increment();
        totalSupply++;
    }

    function _mintAndAttachMetadata(uint tokenId) private {
        _mintAndAttachNextAttr(tokenId, "BACKGROUND");
        _mintAndAttachNextAttr(tokenId, "CHEST");
        _mintAndAttachNextAttr(tokenId, "HELMET");
        _mintAndAttachNextAttr(tokenId, "EYES");
        _mintAndAttachNextAttr(tokenId, "SNOUT");
        _mintAndAttachNextAttr(tokenId, "WEAPON");
        _mintAndAttachNextAttr(tokenId, "HANDS");
    }

    function _mintAndAttachNextAttr(uint tokenId, string memory symbol) private {
        uint attrId = _attrIds.current();
        ownerOfAttr[attrId] = msg.sender;
        attrBalanceOf[msg.sender]++;
        _mintAndAttachAttr(
            tokenId,
            attrId,
            metadata.getRandomTrait(symbol),
            symbol
        );
        _attrIds.increment();
        
    }

    function _mintAndAttachAttr(uint tokenId, uint attrId, string memory name, string memory symbol) private {
        ERC3664._mint(attrId, name, symbol, "");
        ERC3664.attach(tokenId, attrId, 1);
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