// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC.sol";
import "./Base64.sol";

/**
 * @author Roi Di Segni (AKA @sheeeev66)
 */

contract TokenURI is AttrTokens {

    using Strings for uint256;

    string internal _baseAttrURI;

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
    
    /**
     * @notice returns the attributes image, if the attribute value is 0, it returns the default image
     * @dev Explain to a developer any extra details
     * @param _attrId the attribute ID
     * @return Documents the return variables of a contract’s function state variable
     */
    function attrURI(uint _attrId) private view returns(string memory) {
        require(
            _attrOwners[_attrId] != address(0) &&  _atachedTo[_attrId] != 0,
            "ERC: URI query for nonexistent attribute"
        );

        string memory base = _baseAttrURI;

        return
            bytes(base).length > 0 ?
                string(abi.encodePacked(base, "/", attrs[_attrId].trait_type, "/", attrs[_attrId].value)) :
                string(abi.encodePacked(base, "/", attrs[_attrId].trait_type, "/", bytes1(0x30)));
    }

    

    function printAttributes(uint tokenId) public view returns(string memory) {
        bytes memory data = "";
        uint256[8] memory ta = _attrsOf[tokenId]; // token attributes
        for (uint256 i = 0; i < ta.length; i++) {
            if (data.length > 0) {
                data = abi.encodePacked(data, ",");
            }
            data = abi.encodePacked(
                data,
                '{"trait_type":"',
                i, 
                '","value":"',
                attrs[ta[i]].value,
                '"}'
            );
        }
        return string(data);
    }

    function imageSvg(uint tokenId) private view returns(string memory) {
        bytes memory svg = '<svg width="2700" height="2310" xmlns="http://www.w3.org/2000/svg">';
        uint[8] memory ta = _attrsOf[tokenId]; // token attributes (ids)
        
        for (uint i; i < 8; i++) {
            svg = abi.encodePacked(
                svg, 
                '<image href="', attrURI(ta[i]) ,'" height="2700" width="2310"/>'
            );
        }
        svg = abi.encodePacked(svg, '</svg>;');
        return string(svg);
    }

    function svgToImageURI(string memory svg) private pure returns(string memory) {
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked("data:image/svg+xml;base64,", svgBase64Encoded));
    }
    
}