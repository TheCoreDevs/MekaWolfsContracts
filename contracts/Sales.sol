// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TokenURI.sol";
import "./Ownable.sol";
import "./IERC2981.sol";
import "./IERC20.sol";


contract Sales is TokenURI, Ownable {

    uint _tokenIdTracker;

    string public baseURI;
    uint8 public reserve = 200;
    bool public mintingEnabled;
    bool public onlyWhitelisted;
  
    mapping(address => uint32) public addressMintedBalance;
    mapping(bytes => bool) public usedSigs;

    function supportsInterface(bytes4 _interfaceId) public view virtual override(IERC165) returns (bool) {
        return _interfaceId == type(IERC2981).interfaceId || super.supportsInterface(_interfaceId);
    }

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view override returns (address receiver, uint256 royaltyAmount) {
        require(_exists(_tokenId), "ERC2981RoyaltyStandard: Royalty info for nonexistent token");
        return (owner(), _salePrice / 10); // 10 percent
    }

    function mint(uint32 _mintAmount) public payable {
        mint(_mintAmount, "");
    }

    // public
    function mint(uint32 _mintAmount, bytes memory _signature) public payable {
        require(msg.value == 1e17 * uint(_mintAmount), "Ethereum amount sent is not correct!");
        require(addressMintedBalance[msg.sender] + _mintAmount <= 10 && _mintAmount != 0,"Invalid can not mint more than 10!");
        
        if (!mintingEnabled) {            
            require(onlyWhitelisted, "Minting is not enabled!");
            require(isWhitelisted(msg.sender, _signature), "User is not whitelisted!");            
            _mintLoop(msg.sender, _mintAmount);
            return;
        }
        require(totalSupply() + _mintAmount < 9_800, "Request will exceed max supply!");
        _mintLoop(msg.sender, _mintAmount);
    }

    function _mintLoop(address to, uint32 amount) private {
        addressMintedBalance[to] += amount;
        for (uint i; i < amount; i++ ) {
            _safeMint(to, _tokenIdTracker.current());
            _tokenIdTracker.increment();
        }
    }

    function freeMint(bytes calldata _signature, uint _addressAirDropNumber) public {
        require(reserve > 0, "No more tokens left in reserve!");
        require(!usedSigs[_signature], "Can only use a claim signature once!");
        require(canClaimAirdrop(msg.sender, _signature, _addressAirDropNumber), "User not eligable to claim an airdrop!");
        usedSigs[_signature] = true;
        _safeMint(msg.sender, _tokenIdTracker.current());
        _tokenIdTracker.increment();
        addressMintedBalance[msg.sender]++;
        reserve--;
    }

    function isWhitelisted(address _wallet, bytes memory _signature) private view returns(bool) {
        return ECDSA.recover(
            ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(_wallet, "whitelist"))),
            _signature
        ) == owner();
    }

    function canClaimAirdrop(address _wallet,bytes calldata _signature,uint256 _addressAirDropNumber) private view returns(bool) {
        return ECDSA.recover(
            // if it's the address's 3rd airdrop so _addressAirDropNumber = 3
            ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(_wallet, "airdrop", _addressAirDropNumber.toString()))),
            _signature
        ) == owner();
    }

    function walletOfOwner(address _owner) public view returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory)
    {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return string(abi.encodePacked(baseURI, tokenId.toString(), ".json"));
    }

    //only owner
    function ownerMintFromReserve(uint8 amount) public onlyOwner {
        require(reserve >= amount, "Not enough tokens left in reserve!");
        _mintLoop(msg.sender, amount);
        reserve -= amount;
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    } 

    function toggleMinting() external onlyOwner {
        mintingEnabled = !mintingEnabled;
    }

    function toggleOnlyWhitelisted() external onlyOwner {
        onlyWhitelisted = !onlyWhitelisted;
    }

    function withdraw() external onlyOwner {
        bool success = payable(msg.sender).send(address(this).balance);
        require(success, "Payment did not go through!");
    }

    /** 
     * @notice withdraws erc20 tokens to owner address
     * @param token token contract address
     */
    function withdrawERC20(IERC20 token) external onlyOwner {
        require(token.transfer(msg.sender, token.balanceOf(address(this))));
    }

    function withdrawETH() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}