// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./MekaWolfsFactory.sol";
import "./Base64.sol";

/**
 * @author Roi Di Segni (AKA @sheeeev66)
 */

contract TokenURI is MekaWolfsFactory {

    using Strings for uint256;

    function tokenURI(uint tokenId) public view override returns(string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory imageURI = svgToImageURI(
            string(
                abi.encodePacked(
                    '<svg width="200" height="200" xmlns="http://www.w3.org/2000/svg">',
                        '<image href="', 'IPFS URI' ,'" height="200" width="200"/>',
                        '<image href="', 'IPFS URI' ,'" height="200" width="200"/>',
                    '</svg>;'
                )
            )
        );

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{',
                                '"name": "Meka Wolfs #', tokenId.toString(),'",',
                                '"description": "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",',
                                '"attributes": [',
                                    printAttributes(tokenId),
                                '],',
                                '"image: "', imageURI,
                            '}'
                        )
                    )
                )
            )
        );
    }

    function attrURI(uint attrId) public view override returns(string memory) {
        require(
            _attrExists(attrId),
            "ERC3664: URI query for nonexistent attribute"
        );

        return
            bytes(_baseUri).length > 0 ?
                string(abi.encodePacked("ipfs://", _baseUri, "/", ERC3664.symbol(attrId), "/", removeSpaces(ERC3664.name(attrId)))) :
                "";
    }

    function printAttributes(uint tokenId) public view override returns(string memory) {
        bytes memory data = "";
        uint256[] memory ma = attrs[tokenId];
        for (uint256 i = 0; i < ma.length; i++) {
            if (data.length > 0) {
                data = abi.encodePacked(data, ",");
            }
            data = abi.encodePacked(
                data,
                '{"trait_type":"',
                ERC3664.symbol(ma[i]),
                '","value":"',
                ERC3664.name(ma[i]),
                '"}'
            );
        }
        return string(data);
    }

    function svgToImageURI(string memory svg) private pure returns(string memory) {
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked("data:image/svg+xml;base64,", svgBase64Encoded));
    }

    function removeSpaces(string memory str) private pure returns(string memory) {
        bytes memory sb = bytes(str); // sb = string bytes
        bytes memory result;
        for (uint i; sb.length > i; i++) {
            if (sb[i] != 0x20) result = abi.encodePacked(result, sb[i]); // 0x20 - UTF-8 space
        }
        return string(result);
    }
    
}