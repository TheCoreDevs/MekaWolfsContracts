// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @title On Chain Tokenized NFT Metadata Standard
 * @author Roi Di Segni (A.K.A. @sheeeev66)
 * @dev This standard allows people to hold individual attributes of NFTs
 *  in order to change/modify the metadata of an NFT in a verifiable way.
 */

interface IERC is IERC165 {
    /**
     * @dev This emits when ownership of any unattached attribute changes by any mechanism.
     *  This event emits when Attributes are created (`from` == 0) and destroyed
     *  (`to` == 0). Exception: during contract creation, any number of attributes
     *  may be created and assigned without emitting Transfer. At the time of
     *  any transfer, the approved address for that attribute (if any) is reset to none.
     *  NOTE: this mimics the ERC721 `Transfer` event
     */
    event AttrTransfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    event Attach(uint indexed _attrId, uint indexed _tokenId, address indexed owner);

    event Dettach(uint indexed _attrId, uint indexed _tokenId);

    /**
     * @dev This emits when the approved address for an Attribute is changed or
     *  reaffirmed. The zero address indicates there is no approved address.
     *  When a Transfer event emits, this also indicates that the approved
     *  address for that attribute (if any) is reset to none.
     *  NOTE: this mimics the ERC721 `Approval` event
     */
    event AttrApproval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /**
     * @dev This emits when an operator is enabled or disabled for an owner.
     *  The operator can manage all NFTs of the owner.
     *  NOTE: this mimics the ERC721 `ApprovalForAll` event
     */
    event AttrApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /**
     * @notice gets the token `_attrId` is attached to (if it is attached).
     * @dev Throws if `_attrId` isn't attached to a token. 
       @return a token id.
     */
    function attachedTo(uint _attrId) external view returns (uint);

    /**
     * @return the address that owns the unattached attribute.
     * @dev Throws if `_attrId` is attached to a token.
     * NOTE: this mimics the ERC721 `ownerOf` fuction
     */
    function ownerOfAttr(uint _attrId) external view returns (address);

    /**
     * @dev gets the amount of unattached attributes `_owner` holds.
     * NOTE: this mimics the ERC721 `balanceOf` function
     */
    function attrBalanceOf(address _owner) external view returns (uint);

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
	function attach(uint _attrId, uint _tokenId) external payable;

    /**
     * @notice detaches an attribute from an NFT to the NFT owner.
     * @dev Throws unless `msg.sender` is the current owner, an authorized 
     *  operator, or the approved address of the NFT that the attribute is attached to.
     *  Throws if `_attrId` is not attached to a token.
     * @param _attrId The attribute Id to dettach 
     */
	function dettach(uint _attrId) external payable;

    /**
     * @notice Replaces the attribute which is attached to an NFT with another
     *  attribute of the same type.
     * @dev Works like {dettach} and {attach} in the same function.
     */
    function replaceAttr(uint _attrId, uint _tokenId) external payable;

	/**
     * @notice Transfers the ownership of an attribute from one address to another address
     * @dev Throws unless `msg.sender` is the current owner, an authorized
     *  operator, or the approved address for this attribute. Throws if `_from` is
     *  not the current owner. Throws if `_to` is the zero address. Throws if
     *  `_attrId` is not a valid attribute. Throws if `_attrId` is attached to an NFT.
	 *  When transfer is complete, this function checks if `_to` is a smart contract
	 *  (code size > 0). If so, it calls `onERC721Received` on `_to` and throws if the
	 *  return value is not `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
     * @param _from The current owner of the attribute
     * @param _to The new owner
     * @param _attrId The attribute to transfer
     * @param data Additional data with no specified format, sent in call to `_to`
     * NOTE: this mimics the ERC721 `safeTransferFrom` function
	 */
    function attrSafeTransferFrom(address _from, address _to, uint256 _attrId, bytes memory data) external payable;

	/**
     * @notice Transfers the ownership of an attribute from one address to another address
     * @dev This works identically to the other function with an extra data parameter,
     *  except this function just sets data to "".
     * @param _from The current owner of the attribute
     * @param _to The new owner
     * @param _attrId The attribute to transfer
     * NOTE: this mimics the ERC721 `safeTransferFrom` function
	 */
    function attrSafeTransferFrom(address _from, address _to, uint256 _attrId) external payable;

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
	function attrTransferFrom(address _from, address _to, uint256 _attrId) external payable;

    /**
     * @notice Change or reaffirm the approved address for an attribute
     * @dev The zero address indicates there is no approved address.
     *  Throws unless `msg.sender` is the current Attribute owner, or an authorized
     *  operator of the current owner.
     * @param _approved The new approved attribute controller
     * @param _attrId The attribute to approve
     * NOTE: this mimics the ERC721 `approve` function
     */
    function approveAttr(address _approved, uint256 _attrId) external payable;

    /**
     * @notice Enable or disable approval for a third party ("operator") to manage
     *  all of `msg.sender`'s assets
     * @dev Emits the AttrApprovalForAll event. The contract MUST allow
     *  multiple operators per owner.
     * @param _operator Address to add to the set of authorized operators
     * @param _approved True if the operator is approved, false to revoke approval
     * NOTE: this mimics the ERC721 `setApprovalForAll` function
     */
    function setAttrApprovalForAll(address _operator, bool _approved) external;

    /**
     * @notice Get the approved address for a single attribute
     * @dev Throws if `_attrId` is not a valid attribute.
     * @param _attrId The attribute to find the approved address for
     * @return The approved address for this attribute, or the zero address if there is none
     * NOTE: this mimics the ERC721 `setApprovalForAll` function
	 */
    function getAttrApproved(uint256 _attrId) external view returns (address);

	/**
     * @notice Query if an address is an authorized operator for another address
     * @param _owner The address that owns the attributes
     * @param _operator The address that acts on behalf of the owner
     * @return True if `_operator` is an approved operator for `_owner`, false otherwise
     * NOTE: this mimics the ERC721 `setApprovalForAll` function
	 */
    function isAttrApprovedForAll(address _owner, address _operator) external view returns (bool);

    /**
     * @dev gets all the attributes that are attached to `_tokenId`.
     * @return an array of  attribute type ids
     */
    function attrsOf(uint _tokenId) external view returns (uint[] memory);
}