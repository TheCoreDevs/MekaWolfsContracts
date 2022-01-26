// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TokenURI.sol";
import "./Ownable.sol";
import "./ECDSA.sol";
import "./Strings.sol";
import "./IERC2981.sol";
import "./IERC20.sol";
import "./IgWolfs.sol";


contract Sales is TokenURI, Ownable {
    using Strings for uint256;

    
    uint32 public saleCounter;
    uint16 public reserve = 2000;

    bool public mintingEnabled;
    bool public preMintEnabled;
    string public baseURI;

    address royaltyReciever;

    IgWolfs constant gWolfs = IgWolfs(0x3302F0674f316584092C15B865b9e5C8f10751D2);
  
    // mapping(address => uint32) public addressMintedBalance;
    mapping(bytes => bool) public usedSigs;

    function supportsInterface(bytes4 interfaceId) public view virtual override(AttrTokens) returns (bool) {
        return
            interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(interfaceId);
    }


    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address, uint256) {
        require(_exists(_tokenId), "ERC2981: Royalty info for nonexistent token");
        return (royaltyReciever, _salePrice / 10); // 10 percent
    }

    function mint(uint32 _mintAmount) public payable {
        mint(_mintAmount, "");
    }

    // public
    function mint(uint32 _mintAmount, bytes memory _signature) public payable {
        require(msg.value == 1e17 * uint(_mintAmount), "Ethereum amount sent is not correct!");
        // require(addressMintedBalance[msg.sender] + _mintAmount <= 10 && _mintAmount != 0,"Invalid can not mint more than 10!");
        saleCounter += _mintAmount;

        if (!mintingEnabled) {            
            require(preMintEnabled, "Minting is not enabled!");
            require(saleCounter <= 1000, "Request will exceed max supply!");
            require(_validiateSig(msg.sender, "whitelist", _signature), "User is not whitelisted!");
            _batchMint(msg.sender, _mintAmount);
            return;
        }
        require(saleCounter <= 7000, "Request will exceed max supply!");
        _batchMint(msg.sender, _mintAmount);
    }

    function freeMint(bytes calldata _signature, string memory nonce) public {
        require(reserve > 0, "No more tokens left in reserve!");
        require(!usedSigs[_signature], "Can only use a claim signature once!");
        require(_validiateSig(msg.sender, nonce, _signature), "User not eligable to claim an airdrop!");
        usedSigs[_signature] = true;
        _mintWithTraits(msg.sender);
        // addressMintedBalance[msg.sender]++;
        reserve--;
    }

    function mintFromReserve(uint8 amount, address to) external onlyOwner {
        require(reserve >= amount, "Not enough tokens left in reserve!");
        _batchMint(to, amount);
        reserve -= amount;
    }

    function airdropToHolders() external onlyOwner { // might want to change this to work more efficiantly
        for (uint16 i; i < 1700; i++) _mintWithTraits(gWolfs.getTokenHolder(i));
        reserve -= 1700;
    }

    function airDropToHolders(address[] calldata holder, uint[] calldata amount) external onlyOwner { // check if this is cheeper
        require(holder.length == amount.length);

        for (uint16 i; i < holder.length; i++) _batchMint(holder[i], amount[i]);
        reserve -= 1700;
    }

    function _validiateSig(address _wallet, string memory s, bytes memory _signature) private view returns(bool) {
        return ECDSA.recover(
            ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(_wallet, s))),
            _signature
        ) == owner();
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    } 

    function toggleMinting() external onlyOwner {
        mintingEnabled = !mintingEnabled;
    }

    function togglePreMint() external onlyOwner {
        preMintEnabled = !preMintEnabled;
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

    function setRoyaltyReciever(address _address) external onlyOwner {
        royaltyReciever = _address;
    }
}