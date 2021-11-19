// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./TokenURI.sol";

/**
 * @author Roi Di Segni (A.K.A. @sheeeev66)
 */

contract MekaMachine is TokenURI {

    using Counters for Counters.Counter;

    uint private nonce;

    modifier onlyMekaHolder {
        require(ERC721.balanceOf(msg.sender) > 0, "Caller does not hold any meka wolfs!");
        _;
    }
    
    function useMekaMachine() public onlyMekaHolder {
        string memory attrSymbol = _getRandomTraitSymbol();
        string memory attrName = metadata.getRandomTrait(attrSymbol);
        ERC3664._mint(_attrIds.current(), attrName, attrSymbol, "");
        
    }

    function _getRandomTraitSymbol() private view returns(string memory) {
        uint rand = uint(
            keccak256(
                abi.encodePacked(msg.sender, block.difficulty, nonce)
            )
        ) % 7; // returns a number between 0 - 6 (7 different variables)
        return metadata.attrSymbols()[rand];
    }
}