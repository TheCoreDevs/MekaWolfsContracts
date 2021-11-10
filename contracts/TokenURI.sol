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

        string memory imageURI = svgToImageURI(imageSvg(tokenId));

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
                string(abi.encodePacked("ipfs://", _baseUri, "/", ERC3664.symbol(attrId), "/", removeSpaces(ERC3664.name(attrId)), "")) :
                "";
    }

    function printAttributes(uint tokenId) public view override returns(string memory) {
        bytes memory data = "";
        uint256[] memory ta = attrs[tokenId]; // token attributes
        for (uint256 i = 0; i < ta.length; i++) {
            if (data.length > 0) {
                data = abi.encodePacked(data, ",");
            }
            data = abi.encodePacked(
                data,
                '{"trait_type":"',
                ERC3664.symbol(ta[i]),
                '","value":"',
                ERC3664.name(ta[i]),
                '"}'
            );
        }
        return string(data);
    }

    function imageSvg(uint tokenId) private view returns(string memory) {
        bytes memory svg = '<svg width="200" height="200" xmlns="http://www.w3.org/2000/svg">';
        uint[] memory ta = attrs[tokenId]; // token attributes (ids)
        string[6] memory symbols = [
            "CHEST",
            "HELMET",
            "EYES",
            "SNOUT",
            "WEAPON",
            "HANDS"
        ]; // length = 6

        for (uint i = 0; i < 6; i++) { // looping through the symbols
            for (uint f = 0; f < 6; i++) { // looping through the attributes
                if (
                    keccak256(abi.encodePacked(symbols[i])) ==
                    keccak256(abi.encodePacked(ERC3664.symbol(ta[f])))
                ) {
                    svg = abi.encodePacked(
                        svg,
                        '<image href="', attrURI(ta[f]) ,'" height="2700" width="2310"/>'
                    );
                    break; 
                }
            }
        }
        svg = abi.encodePacked(svg, '</svg>;');
        return string(svg);
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