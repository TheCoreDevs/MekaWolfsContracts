// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @author Roi Di Segni (A.K.A. @sheeeev66)
 */

interface IMekaWolfsMetadata {
    function getRandomTrait(string memory symbol) external view returns(string memory);
    
    function attrSymbols() external pure returns(string[7] memory);
}