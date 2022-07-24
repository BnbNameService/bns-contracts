pragma solidity >=0.8.4;

import "../registry/BNS.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./BaseRegistrar.sol";
contract BaseRegistrarImplementation is ERC721, BaseRegistrar  {
    // A map of expiry times
    mapping(uint256=>uint) expiries;
    string baseURI;

    bytes4 constant private INTERFACE_META_ID = bytes4(keccak256("supportsInterface(bytes4)"));
    bytes4 constant private ERC721_ID = bytes4(
        keccak256("balanceOf(address)") ^
        keccak256("ownerOf(uint256)") ^
        keccak256("approve(address,uint256)") ^
        keccak256("getApproved(uint256)") ^
        keccak256("setApprovalForAll(address,bool)") ^
        keccak256("isApprovedForAll(address,address)") ^
        keccak256("transferFrom(address,address,uint256)") ^
        keccak256("safeTransferFrom(address,address,uint256)") ^
        keccak256("safeTransferFrom(address,address,uint256,bytes)")
    );
    bytes4 constant private RECLAIM_ID = bytes4(keccak256("reclaim(uint256,address)"));

    /**
     * v2.1.3 version of _isApprovedOrOwner which calls ownerOf(tokenId) and takes grace period into consideration instead of ERC721.ownerOf(tokenId);
     * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.1.3/contracts/token/ERC721/ERC721.sol#L187
     * @dev Returns whether the given spender can transfer a given token ID
     * @param spender address of the spender to query
     * @param tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     *    is an operator of the owner, or is the owner of the token
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view override returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    constructor(BNS _bns, bytes32 _baseNode, string memory name, string memory symbol, string memory _base) ERC721(name, symbol) {
        bns = _bns;
        baseNode = _baseNode;
        baseURI = _base;
    }

    modifier live {
        require(bns.owner(baseNode) == address(this));
        _;
    }

    modifier onlyController {
        require(controllers[msg.sender]);
        _;
    }

    /**
     * @dev Gets the owner of the specified token ID. Names become unowned
     *      when their registration expires.
     * @param tokenId uint256 ID of the token to query the owner of
     * @return address currently marked as the owner of the given token ID
     */
    function ownerOf(uint256 tokenId) public view override(IERC721, ERC721) returns (address) {
        require(expiries[tokenId] > block.timestamp, "Token has expired");
        return super.ownerOf(tokenId);
    }

    // Authorises a controller, who can register and renew domains.
    function addController(address controller) external override onlyOwner {
        controllers[controller] = true;
        emit ControllerAdded(controller);
    }

    // Revoke controller permission for an address.
    function removeController(address controller) external override onlyOwner {
        controllers[controller] = false;
        emit ControllerRemoved(controller);
    }

    // Set the resolver for the TLD this registrar manages.
    function setResolver(address resolver) external override onlyOwner {
        bns.setResolver(baseNode, resolver);
    }

    // Returns the expiration timestamp of the specified id.
    function nameExpires(uint256 id) external view override returns(uint) {
        return expiries[id];
    }

    // Returns true iff the specified name is available for registration.
    function available(uint256 id) public view override returns(bool) {
        // Not available if it's registered here or in its grace period.
        return expiries[id] + GRACE_PERIOD < block.timestamp;
    }
    
    function tokenURI(uint256 _tokenId) public view virtual override returns(string memory) {
        require(_exists(_tokenId), "ERC721Metadata: URI set of nonexistent token");
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, Strings.toString(_tokenId))) : "";
    }

    function setBaseURI(string memory _base) external onlyOwner{
        baseURI = _base;
    }
    
    function claimOld(uint256 id) external {
        require(!_exists(id), "This name is already mined");
        IBase oldContract = IBase(0x5eE17161A6d2848ef0D15E6b6A1FcB7c3CE4896C);
        require(msg.sender == oldContract.ownerOf(id), "You are not the owner of this name");
        
        uint duration = oldContract.nameExpires(id);
        require(duration > block.timestamp, "This name is not expired");
        expiries[id] = block.timestamp + duration;
        _mint(msg.sender, id);
    }

    /**
     * @dev Register a name.
     * @param id The token ID (keccak256 of the label).
     * @param owner The address that should own the registration.
     * @param duration Duration in seconds for the registration.
     */
    function register(uint256 id, address owner, uint duration) external override returns(uint) {
      return _register(id, owner, duration, true);
    }

    /**
     * @dev Register a name, without modifying the registry.
     * @param id The token ID (keccak256 of the label).
     * @param owner The address that should own the registration.
     * @param duration Duration in seconds for the registration.
     */
    function registerOnly(uint256 id, address owner, uint duration) external returns(uint) {
      return _register(id, owner, duration, false);
    }

    function _register(uint256 id, address owner, uint duration, bool updateRegistry) internal live onlyController returns(uint) {
        require(available(id));
        require(block.timestamp + duration + GRACE_PERIOD > block.timestamp + GRACE_PERIOD); // Prevent future overflow

        expiries[id] = block.timestamp + duration;
        if(_exists(id)) {
            // Name was previously owned, and expired
            _burn(id);
        }
        _mint(owner, id);
        if(updateRegistry) {
            bns.setSubnodeOwner(baseNode, bytes32(id), owner);
        }

        emit NameRegistered(id, owner, block.timestamp + duration);

        return block.timestamp + duration;
    }

    function renew(uint256 id, uint duration) external override live onlyController returns(uint) {
        require(expiries[id] + GRACE_PERIOD >= block.timestamp, "Name must be registered here or in grace period"); // Name must be registered here or in grace period
        require(expiries[id] + duration + GRACE_PERIOD > duration + GRACE_PERIOD); // Prevent future overflow

        expiries[id] += duration;
        emit NameRenewed(id, expiries[id]);
        return expiries[id];
    }

    /**
     * @dev Reclaim ownership of a name in BNS, if you own it in the registrar.
     */
    function reclaim(uint256 id, address owner) external override live {
        require(_isApprovedOrOwner(msg.sender, id), "You must be the owner or approved for this name");
        bns.setSubnodeOwner(baseNode, bytes32(id), owner);
    }

    function supportsInterface(bytes4 interfaceID) public override(ERC721, IERC165) view returns (bool) {
        return interfaceID == INTERFACE_META_ID ||
               interfaceID == ERC721_ID ||
               interfaceID == RECLAIM_ID;
    }
}
