// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * Source: drepublic-contracts
 * Edited by Roi Di Segni (A.K.A. @sheeeev66)
 */

import "./ERC721.sol";
import "./IERC.sol";
import "./IERCReceiver.sol";

enum TraitType {background, weapon, legs, chest, helmet, arms, eyes, snout}

contract AttrTokens is ERC721, IERC {

    using Address for address;

    struct Attr {
        TraitType trait_type;
        uint8 value;
    }

    Attr[] public attrs;

    // Mapping from attribute token ID to owner address
    mapping(uint256 => address) internal _attrOwners;

    // Mapping owner address to attribute token count
    mapping(address => uint256) internal _attrBalances;

    // Mapping from attribute token ID to approved address
    mapping(uint256 => address) private _attrTokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _attrOperatorApprovals;

    // Mapping from attribute token ID to the NFT it is attached to
    mapping(uint => uint) _attachedTo;

    // Mapping from NFT ID to attached attribute token IDs
    mapping(uint => uint[8]) internal _attrsOf;

    // modifier sameOwner(uint _attrId, uint _tokenId) {
    //     require(
    //         ownerOf(_tokenId) == msg.sender &&
    //         ownerOfAttr(_attrId) == msg.sender
    //     );
    //     _;
    // }

    constructor() {
        attrs.push();
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, IERC165) returns (bool) {
        return
            interfaceId == type(IERC).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev see {ERC-attachedTo}
     */
    function attachedTo(uint _attrId) public view returns (uint) {
        uint tokenId = _attachedTo[_attrId];
        // can't be owned by an adress // can't be 0
        require(_attrOwners[_attrId] == address(0) && tokenId != 0);
        return tokenId;
    }

    /**
     * @dev see {ERC-ownerOfAttr}
     */
    function ownerOfAttr(uint _attrId) public view returns (address) {
        address owner = _attrOwners[_attrId];
        // attached to 0 = not attached. owner is 0 = attached. both =  does not exist
        require(_attachedTo[_attrId] == 0 && owner != address(0), "ERC: Attribute is attached to a token or deos not exist!");
        return owner;
    }

    /**
     * @dev gets the amount of unattached attributes `_owner` holds.
     * NOTE: this mimics the ERC721 `balanceOf` function
     */
    function attrBalanceOf(address _owner) public view returns (uint) {
        return _attrBalances[_owner];
    }

    /**
     * @notice attaches an attribute to an NFT
     * @dev Throws unless `msg.sender` is the current owner, an authorized 
     *  operator, or the approved address for both the attribute and the NFT.
     *  Throws if `_attrId` is not a valid attribute. Throws if `_tokenId` is
     *  not a valid NFT. Throws an attribute of the same type as `_attrId` is
     *  already attached to `_tokenId`.
     *  Clears the ownership of `_attrId` but does not burn it.
     *  Clears approvals for `_attrId`.
     * @param _attrId The attribute Id to attach
     * @param _tokenId The NFT Id to attach to 
     */
	function attach(uint _attrId, uint _tokenId) external payable {
        address owner = ownerOfAttr(_attrId);
        require(owner == ownerOf(_tokenId));
        _isApprovedOrAttrOwner(owner, msg.sender, _attrId);
        _isApprovedOrOwner(owner, msg.sender, _tokenId);

        // clears ownership and approvals
        delete _attrOwners[_attrId];
        delete _attrTokenApprovals[_attrId];

        _attrBalances[msg.sender]--;

        // attach attribute
        _attachedTo[_attrId] = _tokenId;
        _attrsOf[_tokenId][uint(attrs[_attrId].trait_type)] = _attrId;
    }

    /**
     * @notice detaches an attribute from an NFT to the NFT owner.
     * @dev Throws unless `msg.sender` is the current owner, an authorized 
     *  operator, or the approved address of the NFT that the attribute is attached to.
     *  Throws if `_attrId` is not attached to a token.
     * @param _attrId The attribute Id to dettach 
     */
	function dettach(uint _attrId) external payable {
        uint token = attachedTo(_attrId);
        address owner = ownerOf(token);

        _isApprovedOrOwner(owner, msg.sender, token);

        // before detach
        
        delete _attachedTo[_attrId];

        _attrOwners[_attrId] = owner;
        _attrBalances[owner]++;
    }

    /**
     * @notice Replaces the attribute which is attached to an NFT with another
     *  attribute of the same type.
     * @dev Works like {dettach} and {attach} in the same function.
     */
    function replaceAttr(uint _attrId, uint _tokenId) external payable {
        address owner = ownerOfAttr(_attrId);
        require(owner == ownerOf(_tokenId));
        _isApprovedOrAttrOwner(owner, msg.sender, _attrId);
        _isApprovedOrOwner(owner, msg.sender, _tokenId);

        TraitType attrType = attrs[_attrId].trait_type;

        // before replace attr
        require(uint(attrType) > 0);

        uint attachedAttr = _attrsOf[_tokenId][uint(attrType)];
        
        // dettach
        delete _attachedTo[attachedAttr];
        
        _attrOwners[attachedAttr] = owner;

        // attach
        delete _attrOwners[_attrId];
        delete _attrTokenApprovals[_attrId];

        _attrsOf[_tokenId][uint(attrType)] = _attrId;
        _attachedTo[_attrId] = _tokenId;
        
    }

	/**
     * @notice Transfers the ownership of an attribute from one address to another address
     * @dev Throws unless `msg.sender` is the current owner, an authorized
     *  operator, or the approved address for this attribute. Throws if `_from` is
     *  not the current owner. Throws if `_to` is the zero address. Throws if
     *  `_attrId` is not a valid attribute. Throws if `_attrId` is attached to an NFT.
	 *  When transfer is complete, this function checks if `_to` is a smart contract
	 *  (code size > 0). If so, it calls `onERCReceived` on `_to` and throws if the
	 *  return value is not `bytes4(keccak256("onERCReceived(address,address,uint256,bytes)"))`.
     * @param _from The current owner of the attribute
     * @param _to The new owner
     * @param _attrId The attribute to transfer
     * @param data Additional data with no specified format, sent in call to `_to`
     * NOTE: this mimics the ERC721 `safeTransferFrom` function
	 */
    function attrSafeTransferFrom(address _from, address _to, uint256 _attrId, bytes memory data) public payable {
        _attrTransferFrom(_from, _to, _attrId);
        require(_checkOnERCReceived(_from, _to, _attrId, data));
    }

	/**
     * @notice Transfers the ownership of an attribute from one address to another address
     * @dev This works identically to the other function with an extra data parameter,
     *  except this function just sets data to "".
     * @param _from The current owner of the attribute
     * @param _to The new owner
     * @param _attrId The attribute to transfer
     * NOTE: this mimics the ERC721 `safeTransferFrom` function
	 */
    function attrSafeTransferFrom(address _from, address _to, uint256 _attrId) public payable {
        attrSafeTransferFrom(_from, _to, _attrId, "");
    }



	/**
     * @notice Transfer ownership of an attribute -- THE CALLER IS RESPONSIBLE
     *  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING ATTRIBUTES OR ELSE
     *  THEY MAY BE PERMANENTLY LOST
     * @dev Throws unless `msg.sender` is the current owner, an authorized
     *  operator, or the approved address for this attribute. Throws if `_from` is
     *  not the current owner. Throws if `_to` is the zero address. Throws if
     *  `_attrId` is not a valid attribute. Throws if `_attrId` is attached to an NFT.
     * @param _from The current owner of the attribute
     * @param _to The new owner
     * @param _attrId The attribute to transfer
     * NOTE: this mimics the ERC721 `TransferFrom` function
	 */
	function attrTransferFrom(address _from, address _to, uint256 _attrId) public payable {
        _attrTransferFrom(_from, _to, _attrId);
    }

    function _attrTransferFrom(address _from, address _to, uint256 _attrId) private {
        require(_to != address(0));
        require(ownerOfAttr(_attrId) == _from);
        _isApprovedOrAttrOwner(_from, msg.sender, _attrId);
        
        _approveAttr(ownerOfAttr(_attrId), address(0), _attrId);

        _attrOwners[_attrId] = _to;
        _attrBalances[_from]--;
        _attrBalances[_to]++;
    }

    function _isApprovedOrAttrOwner(address attrOwner, address spender, uint _attrId) private view {
        require(
            attrOwner == spender ||
            getAttrApproved(_attrId) == spender ||
            isAttrApprovedForAll(attrOwner, spender),
            "ERC: Caller is not a valid operator!"
        );
    }

    /**
     * @notice Change or reaffirm the approved address for an attribute
     * @dev The zero address indicates there is no approved address.
     *  Throws unless `msg.sender` is the current Attribute owner, or an authorized
     *  operator of the current owner.
     * @param _approved The new approved attribute controller
     * @param _attrId The attribute to approve
     * NOTE: this mimics the ERC721 `approve` function
     */
    function approveAttr(address _approved, uint256 _attrId) external payable {
        address attrOwner = ownerOfAttr(_attrId);
        require(msg.sender == attrOwner);
        _approveAttr(attrOwner, _approved, _attrId);
    }

    function _approveAttr(address _owner, address _approved, uint256 _attrId) private {
        _attrTokenApprovals[_attrId] = _approved;
        emit AttrApproval(_owner, _approved, _attrId);
    }

    /**
     * @notice Enable or disable approval for a third party ("operator") to manage
     *  all of `msg.sender`'s assets
     * @dev Emits the AttrApprovalForAll event. The contract MUST allow
     *  multiple operators per owner.
     * @param _operator Address to add to the set of authorized operators
     * @param _approved True if the operator is approved, false to revoke approval
     * NOTE: this mimics the ERC721 `setApprovalForAll` function
     */
    function setAttrApprovalForAll(address _operator, bool _approved) external {
        _attrOperatorApprovals[msg.sender][_operator] = _approved;
    }

    /**
     * @notice Get the approved address for a single attribute
     * @dev Throws if `_attrId` is not a valid attribute.
     * @param _attrId The attribute to find the approved address for
     * @return The approved address for this attribute, or the zero address if there is none
     * NOTE: this mimics the ERC721 `setApprovalForAll` function
	 */
    function getAttrApproved(uint256 _attrId) public view returns (address) {
        return _attrTokenApprovals[_attrId];
    }

	/**
     * @notice Query if an address is an authorized operator for another address
     * @param _owner The address that owns the attributes
     * @param _operator The address that acts on behalf of the owner
     * @return True if `_operator` is an approved operator for `_owner`, false otherwise
     * NOTE: this mimics the ERC721 `setApprovalForAll` function
	 */
    function isAttrApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return _attrOperatorApprovals[_owner][_operator];
    }

    /**
     * @dev gets all the attributes that are attached to `_tokenId`.
     * @return an array of attribute type ids
     */
    function attrsOf(uint _tokenId) external view returns (uint[] memory) {
        uint[] memory result = new uint[](6);
        result[0] = _attrsOf[_tokenId][0];
        result[1] = _attrsOf[_tokenId][1];
        result[2] = _attrsOf[_tokenId][2];
        result[3] = _attrsOf[_tokenId][3];
        result[4] = _attrsOf[_tokenId][4];
        result[5] = _attrsOf[_tokenId][5];
        return result;
    }

    /**
     * @dev Internal function to invoke {IERCReceiver-onERCReceived} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param _from address representing the previous owner of the given token ID
     * @param _to target address that will receive the tokens
     * @param _attrId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERCReceived(
        address _from,
        address _to,
        uint256 _attrId,
        bytes memory data
    ) private returns (bool) {
        if (_to.isContract()) {
            try IERCReceiver(_to).onERCReceived(_msgSender(), _from, _attrId, data) returns (bytes4 retval) {
                return retval == IERCReceiver.onERCReceived.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC: transfer to non ERCReceiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _mintToAddress(address _to, TraitType _traitType, uint8 _traitVal) internal {
        require(_to != address(0));
        uint attrId = attrs.length;
        attrs.push(Attr(_traitType, _traitVal));

        _attrOwners[attrId] = _to;
        _attrBalances[_to]++;

        emit AttrTransfer(address(0), _to, attrId);
    }

    function _mintAndattach(uint _tokenId, TraitType _traitType, uint8 _traitVal) private {
        uint attrId = attrs.length;
        attrs.push(Attr(_traitType, _traitVal));

        _attachedTo[attrId] = _tokenId;
        _attrsOf[_tokenId][uint(_traitType)] = attrId;

        emit Attach(attrId, _tokenId);
    }

    function __partAttrMintFunc(address _to, TraitType _traitType, uint8 _traitVal) private {
        
    }

    function _mintWithTraits(address to) internal {
        uint id = _tokenIdTracker;

        _balances[to]++;
        __partMintFunc(to, id);
        
        // make a check for 1/1s

        _mintAndattach(id, TraitType.background, 0 /* randomize with priority */);
        _mintAndattach(id, TraitType.chest, 0 /* randomize with priority */);
        _mintAndattach(id, TraitType.helmet, 0 /* randomize with priority */);
        _mintAndattach(id, TraitType.arms, 0 /* randomize with priority */);
        _mintAndattach(id, TraitType.eyes, 0 /* randomize with priority */);
        _mintAndattach(id, TraitType.snout, 0 /* randomize with priority */);
    }

    function _getRandomNumber() private view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, msg.sender)));
    }

    function totalAttrSupply() external view returns(uint) {
        return attrs.length;
    }

}