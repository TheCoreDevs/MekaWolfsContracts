// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./TokenURI.sol";

/**
 * @author Roi Di Segni (A.K.A. @sheeeev66)
 */

contract MekaMachine is TokenURI {

    modifier onlyMekaHolder {
        require(ERC721.balanceOf(msg.sender) > 0, "Caller does not hold any meka wolfs!");
        _;
    }
    
    function useMekaMachine() public onlyMekaHolder {
        metadata.getRandomTrait("SYMBOL");
    }
}