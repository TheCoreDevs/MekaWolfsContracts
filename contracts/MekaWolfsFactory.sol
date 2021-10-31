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

    constructor() ERC721("Meka Wolfs", "MKW") ERC3664Transferable(address(this)) { } // use token id 0?


    function _mintWolf(address to) internal {
        ERC721._safeMint(to, _tokenIds.current());
        _tokenIds.increment();
        maxSupply++;
    }

    function _generateMetadata() private {
        
    }



}