// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC3664Transferable.sol";
import "./ERC721.sol";
import "./Ownable.sol";
import "./Counters.sol";
import "./IWolfPack.sol";

contract MekaWolfsFactory is Ownable, ERC3664Transferable, ERC721 {

    using Counters for Counters.Counter;

    // tracks the token ID
    Counters.Counter private _tokenIds;

    // genesis wolf pack contract
    IWolfPack genesisWolfs;

    // inforces the max supply
    uint maxSupply;
    // launch
    bool launched;

    // genesis wolf => claimed
    mapping(uint => bool) genesisWolfMekaClaimed;
    // address => is eligible for an airdrop
    mapping(address => bool) canClaimAirdrop;

    event NewMekaWolfMinted(uint id);

    constructor() ERC721("Meka Wolfs", "MKW") ERC3664Transferable(address(this)) { } // use token id 0?

    /**
     * @dev sets the genesis wolf contract address
     */
    function setGenesisWolfContractAddress(address _address) external onlyOwner {
        genesisWolfs = IWolfPack(_address);
    }

    /**
     * @dev adds to the max supply
     */
    function addToMaxSupply(uint _amountToAdd) external onlyOwner {
        maxSupply += _amountToAdd;
    }

    /**
     * @dev decreases the supply
     */
    function decreaseMaxSupply(uint _amountToDecrease) external onlyOwner {
        require(
            maxSupply - _amountToDecrease >= _tokenIds.current(),
            "The amount to decrease cannot be higher than the amount of tokens that have not been minted yet"
        );
        maxSupply -= _amountToDecrease;
    }

    /**
     * @dev gets the current supply
     */
    function getSupply() external view returns(uint) {
        return _tokenIds.current();
    }

    /**
     * @dev Claim an airdrop
     */
    function claimAirdropGenesisWolfs(uint wolfId) external onlyOwner {
        require(!launched, "Already Launched!");
        require(genesisWolfs.ownerOf(wolfId) == msg.sender, "This can only be called by the holder of the wolf!");
        require(!genesisWolfMekaClaimed[wolfId], "Meka Wolf has already been claimed for this genesis wolf!");
        
        _mintWolf(msg.sender);
        genesisWolfMekaClaimed[wolfId] = true;
    }

    function claimAirdrop() external {
        require(canClaimAirdrop[msg.sender], "You are not eligible for an airdrop!");
        _mintWolf(msg.sender);
    }

    function _mintWolf(address to) private {
        ERC721._safeMint(to, _tokenIds.current());
        _tokenIds.increment();
    }

}