// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @author Roi Di Segni (A.K.A. @sheeeev66)
 */

library StringExternalView {
     
    function removeSpaces(string memory str) private pure returns(string memory) {
        bytes memory sb = bytes(str); // sb = string bytes
        bytes memory result;
        for (uint i; sb.length > i; i++) {
            if (sb[i] != 0x20) result = abi.encodePacked(result, sb[i]); // 0x20 - UTF-8 space
        }
        return string(result);
    }

    
}