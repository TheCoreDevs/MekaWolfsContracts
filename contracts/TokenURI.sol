// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./MekaWolfFactory.sol";

/**
 * @author Roi Di Segni (AKA @sheeeev66)
 */

contract TokenURI is MekaWolfsFactory {

    function tokenURI(uint tokenId) external view override returns(string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory imageURI = svgToImageURI(
            ""
        );

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{',
                                '"name": "Meka Wolfs",',
                                '"description": "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",',
                                '"attributes": [',
                                    '{',
                                        '"trait_type": ', '"PLACE HOLDER"', 
                                        '"value": ', '"PLACE HOLDER"',
                                    '},',
                                    '{',
                                        '"trait_type": ', '"PLACE HOLDER"', 
                                        '"value": ', '"PLACE HOLDER"',
                                    '}',
                                '],',
                                '"image: "', imageURI,
                            '}'
                        )
                    )
                )
            )
        );
    }

    function svgToImageURI(string memory svg) public pure returns (string memory) {
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked("data:image/svg+xml;base64,", svgBase64Encoded));
    }
    
}