// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IMekaWolfsMetadata {
    function getRandomTrait(string memory symbol) external view returns(string memory);
}