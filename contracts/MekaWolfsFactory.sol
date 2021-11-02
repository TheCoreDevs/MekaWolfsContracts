// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC3664Transferable.sol";
import "./ERC721.sol";
import "./Ownable.sol";
import "./Counters.sol";

contract MekaWolfsFactory is Ownable, ERC3664Transferable, ERC721 {

    using Counters for Counters.Counter;

    // tracks the token ID
    Counters.Counter private _tokenIds;

    // call maxSupply() to get the amount of minted tokens
    uint public maxSupply;

    event NewMekaWolfMinted(uint id);

    constructor() ERC3664("") ERC721("Meka Wolfs", "MKW") {
        // ERC3664._mint(attrId, _name, _symbol, _uri);
    } // use token id 0?

    /**
     * How minting will work:
     * 
     * Whenever you generate something so it creates a new attribute.
     * Each token can't have the same attribute of the same Symbol.
     * 
     * 
     */

    function _mintWolf(address to) internal {
        ERC721._safeMint(to, _tokenIds.current());
        _tokenIds.increment();
        maxSupply++;
    }

    function _generateMetadata() private {
        
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