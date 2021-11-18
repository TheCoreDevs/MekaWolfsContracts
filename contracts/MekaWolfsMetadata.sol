// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract MekaWolfsMetadata {

    struct Trait {
        string name;
        uint8 rarity;
    }

    Trait[] background;
    Trait[] chest; // symbol: CHEST
    Trait[] helmet; // symobl: HELMET
    Trait[] eyes; // smybol: EYES
    Trait[] snout; // smybol: SNOUT
    Trait[] weapon; // smybol: WEAPON
    Trait[] hands; // smybol: HANDS

    function getRandomTrait(string memory symbol) external view returns(string memory) {
        
    }

}