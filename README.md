
# BNS

The goal of BNS is to create a secure and trusted domain name service where users do not have to worry about fraud caused by zero-width characters and homoglyph attacks.

BNS uses a whitelist model where only lowercase letters/numbers and '-' can be used.


## BNS Enabling your DApp

BNS is a BNB smart chain name service based on the ens fork, and you can use most of the libraries of ens.
An example using ethers.js :

```javascript
  import { ethers } from "ethers";

  const network = {
      name: "BSC",
      chainId: 56,
      ensAddress: "0x0000000092F9d53192ED545D9dF4fDE3C624cBf0"
  };

  const provider = new ethers.providers.Web3Provider(window.ethereum, network)

  await provider.getBalance("lisa.bnb");
  // { BigNumber: "26959293642897667667" }

  await provider.resolveName("lisa.bnb");
  // '0x20d884b4ea39b7A921009Cac517eaF057C797C74'

  await provider.lookupAddress("0x20d884b4ea39b7A921009Cac517eaF057C797C74");
  // 'lisa.bnb'
```

## Resolving Names On-chain

First, we define some pared-down interfaces containing only the methods we need:
```solidity
  abstract contract BNS {
      function resolver(bytes32 node) public virtual view returns (Resolver);
  }

  abstract contract Resolver {
      function addr(bytes32 node) public virtual view returns (address);
  }
```

For resolution, only the resolver function in the BNS contract is required; other methods permit looking up owners and updating BNS from within a contract that owns a name.
 
With these definitions, looking up a name given its node hash is straightforward:
```solidity
  contract MyContract {
      BNS bns = BNS(0x0000000092F9d53192ED545D9dF4fDE3C624cBf0);

      function resolve(bytes32 node) public view returns(address) {
          Resolver resolver = bns.resolver(node);
          return resolver.addr(node);
      }
  }
```

While it is possible for a contract to process a human-readable name into a node hash, we highly recommend working with node hashes instead, as they are easier and more efficient to work with, and allow contracts to leave the complex work of normalizing the name to their callers outside the blockchain. Where a contract always resolves the same names, those names may be converted to a node hash and stored in the contract as a constant.
```javascript
  import { ethers } from "ethers";

  ethers.utils.namehash('lisa.bnb')
  //'0x7c598597a34a855304de2f260df015e92e1c119f8453b5bbdf09df62613e75bc'
```

    
## Published Contracts

Contract Address
```json
{
    "BNSRegistry": "0x0000000092F9d53192ED545D9dF4fDE3C624cBf0",
    "PublicResolver": "0x7845714c84E0FEf80771f43299ce49117225eA64",
    "BNBRegistrarController": "0xe9A69Ddf53637E474274Dc15D818B14893Dd8394",
    "ReverseRegistrar": "0x8E8f7FA693CB7753f9F6Ee8E3B317EcFDc1852E1",
    "BaseRegistrarImplementation": "0x5eE17161A6d2848ef0D15E6b6A1FcB7c3CE4896C",
    "NameWrapper": "0xaA433Cf707906aA72C7ec6b5c3e5375666E0c5AE"
}
```

Contract ABI
```json
{
    "BNSRegistry": [
        "constructor()",
        "event ApprovalForAll(address indexed,address indexed,bool)",
        "event NewOwner(bytes32 indexed,bytes32 indexed,address)",
        "event NewResolver(bytes32 indexed,address)",
        "event NewTTL(bytes32 indexed,uint64)",
        "event Transfer(bytes32 indexed,address)",
        "function isApprovedForAll(address,address) view returns (bool)",
        "function owner(bytes32) view returns (address)",
        "function recordExists(bytes32) view returns (bool)",
        "function resolver(bytes32) view returns (address)",
        "function setApprovalForAll(address,bool)",
        "function setOwner(bytes32,address)",
        "function setRecord(bytes32,address,address,uint64)",
        "function setResolver(bytes32,address)",
        "function setSubnodeOwner(bytes32,bytes32,address) returns (bytes32)",
        "function setSubnodeRecord(bytes32,bytes32,address,address,uint64)",
        "function setTTL(bytes32,uint64)",
        "function ttl(bytes32) view returns (uint64)"
    ],
    "PublicResolver": [
        "constructor(address,address)",
        "event ABIChanged(bytes32 indexed,uint256 indexed)",
        "event AddrChanged(bytes32 indexed,address)",
        "event AddressChanged(bytes32 indexed,uint256,bytes)",
        "event ApprovalForAll(address indexed,address indexed,bool)",
        "event ContenthashChanged(bytes32 indexed,bytes)",
        "event DNSRecordChanged(bytes32 indexed,bytes,uint16,bytes)",
        "event DNSRecordDeleted(bytes32 indexed,bytes,uint16)",
        "event DNSZoneCleared(bytes32 indexed)",
        "event DNSZonehashChanged(bytes32 indexed,bytes,bytes)",
        "event InterfaceChanged(bytes32 indexed,bytes4 indexed,address)",
        "event NameChanged(bytes32 indexed,string)",
        "event PubkeyChanged(bytes32 indexed,bytes32,bytes32)",
        "event TextChanged(bytes32 indexed,string indexed,string)",
        "function ABI(bytes32,uint256) view returns (uint256, bytes)",
        "function addr(bytes32) view returns (address)",
        "function addr(bytes32,uint256) view returns (bytes)",
        "function clearDNSZone(bytes32)",
        "function contenthash(bytes32) view returns (bytes)",
        "function dnsRecord(bytes32,bytes32,uint16) view returns (bytes)",
        "function hasDNSRecords(bytes32,bytes32) view returns (bool)",
        "function interfaceImplementer(bytes32,bytes4) view returns (address)",
        "function isApprovedForAll(address,address) view returns (bool)",
        "function multicall(bytes[]) returns (bytes[])",
        "function name(bytes32) view returns (string)",
        "function pubkey(bytes32) view returns (bytes32, bytes32)",
        "function setABI(bytes32,uint256,bytes)",
        "function setAddr(bytes32,uint256,bytes)",
        "function setAddr(bytes32,address)",
        "function setApprovalForAll(address,bool)",
        "function setContenthash(bytes32,bytes)",
        "function setDNSRecords(bytes32,bytes)",
        "function setInterface(bytes32,bytes4,address)",
        "function setName(bytes32,string)",
        "function setPubkey(bytes32,bytes32,bytes32)",
        "function setText(bytes32,string,string)",
        "function setZonehash(bytes32,bytes)",
        "function supportsInterface(bytes4) pure returns (bool)",
        "function text(bytes32,string) view returns (string)",
        "function zonehash(bytes32) view returns (bytes)"
    ],
    "BNBRegistrarController": [
        "constructor(address,address,uint256,uint256)",
        "event NameRegistered(string,bytes32 indexed,address indexed,uint256,uint256)",
        "event NameRenewed(string,bytes32 indexed,uint256,uint256)",
        "event NewPriceOracle(address indexed)",
        "event OwnershipTransferred(address indexed,address indexed)",
        "function MIN_REGISTRATION_DURATION() view returns (uint256)",
        "function available(string) view returns (bool)",
        "function check(string) pure returns (bool)",
        "function commit(bytes32)",
        "function commitments(bytes32) view returns (uint256)",
        "function exists(bytes1) pure returns (bool)",
        "function makeCommitment(string,address,bytes32) pure returns (bytes32)",
        "function makeCommitmentWithConfig(string,address,bytes32,address,address) pure returns (bytes32)",
        "function maxCommitmentAge() view returns (uint256)",
        "function minCommitmentAge() view returns (uint256)",
        "function owner() view returns (address)",
        "function register(string,address,uint256,bytes32) payable",
        "function registerWithConfig(string,address,uint256,bytes32,address,address) payable",
        "function renew(string,uint256) payable",
        "function renounceOwnership()",
        "function rentPrice(string,uint256) view returns (uint256)",
        "function setCommitmentAges(uint256,uint256)",
        "function setPriceOracle(address)",
        "function supportsInterface(bytes4) pure returns (bool)",
        "function transferOwnership(address)",
        "function valid(string) pure returns (bool)",
        "function withdraw()"
    ],
    "ReverseRegistrar": [
        "constructor(address,address)",
        "event ControllerChanged(address indexed,bool)",
        "event OwnershipTransferred(address indexed,address indexed)",
        "event ReverseClaimed(address indexed,bytes32 indexed)",
        "function bns() view returns (address)",
        "function claim(address) returns (bytes32)",
        "function claimForAddr(address,address) returns (bytes32)",
        "function claimWithResolver(address,address) returns (bytes32)",
        "function claimWithResolverForAddr(address,address,address) returns (bytes32)",
        "function controllers(address) view returns (bool)",
        "function defaultResolver() view returns (address)",
        "function node(address) pure returns (bytes32)",
        "function owner() view returns (address)",
        "function renounceOwnership()",
        "function setController(address,bool)",
        "function setName(string) returns (bytes32)",
        "function setNameForAddr(address,address,string) returns (bytes32)",
        "function transferOwnership(address)"
    ],
    "BaseRegistrarImplementation": [
        "constructor(address,bytes32)",
        "event Approval(address indexed,address indexed,uint256 indexed)",
        "event ApprovalForAll(address indexed,address indexed,bool)",
        "event ControllerAdded(address indexed)",
        "event ControllerRemoved(address indexed)",
        "event NameMigrated(uint256 indexed,address indexed,uint256)",
        "event NameRegistered(uint256 indexed,address indexed,uint256)",
        "event NameRenewed(uint256 indexed,uint256)",
        "event OwnershipTransferred(address indexed,address indexed)",
        "event Transfer(address indexed,address indexed,uint256 indexed)",
        "function GRACE_PERIOD() view returns (uint256)",
        "function addController(address)",
        "function approve(address,uint256)",
        "function available(uint256) view returns (bool)",
        "function balanceOf(address) view returns (uint256)",
        "function baseNode() view returns (bytes32)",
        "function bns() view returns (address)",
        "function controllers(address) view returns (bool)",
        "function getApproved(uint256) view returns (address)",
        "function isApprovedForAll(address,address) view returns (bool)",
        "function name() view returns (string)",
        "function nameExpires(uint256) view returns (uint256)",
        "function owner() view returns (address)",
        "function ownerOf(uint256) view returns (address)",
        "function reclaim(uint256,address)",
        "function register(uint256,address,uint256) returns (uint256)",
        "function registerOnly(uint256,address,uint256) returns (uint256)",
        "function removeController(address)",
        "function renew(uint256,uint256) returns (uint256)",
        "function renounceOwnership()",
        "function safeTransferFrom(address,address,uint256)",
        "function safeTransferFrom(address,address,uint256,bytes)",
        "function setApprovalForAll(address,bool)",
        "function setResolver(address)",
        "function supportsInterface(bytes4) view returns (bool)",
        "function symbol() view returns (string)",
        "function tokenURI(uint256) view returns (string)",
        "function transferFrom(address,address,uint256)",
        "function transferOwnership(address)"
    ],
    "NameWrapper": [
        "constructor(address,address,address)",
        "event ApprovalForAll(address indexed,address indexed,bool)",
        "event ControllerChanged(address indexed,bool)",
        "event FusesBurned(bytes32 indexed,uint96)",
        "event NameUnwrapped(bytes32 indexed,address)",
        "event NameWrapped(bytes32 indexed,bytes,address,uint96)",
        "event OwnershipTransferred(address indexed,address indexed)",
        "event TransferBatch(address indexed,address indexed,address indexed,uint256[],uint256[])",
        "event TransferSingle(address indexed,address indexed,address indexed,uint256,uint256)",
        "event URI(string,uint256 indexed)",
        "function _tokens(uint256) view returns (uint256)",
        "function allFusesBurned(bytes32,uint96) view returns (bool)",
        "function balanceOf(address,uint256) view returns (uint256)",
        "function balanceOfBatch(address[],uint256[]) view returns (uint256[])",
        "function bns() view returns (address)",
        "function burnFuses(bytes32,uint96)",
        "function controllers(address) view returns (bool)",
        "function getData(uint256) view returns (address, uint96)",
        "function getFuses(bytes32) view returns (uint96, uint8, bytes32)",
        "function isApprovedForAll(address,address) view returns (bool)",
        "function isTokenOwnerOrApproved(bytes32,address) view returns (bool)",
        "function metadataService() view returns (address)",
        "function names(bytes32) view returns (bytes)",
        "function onERC721Received(address,address,uint256,bytes) returns (bytes4)",
        "function owner() view returns (address)",
        "function ownerOf(uint256) view returns (address)",
        "function registerAndWrapBNB2LD(string,address,uint256,address,uint96) returns (uint256)",
        "function registrar() view returns (address)",
        "function renew(uint256,uint256) returns (uint256)",
        "function renounceOwnership()",
        "function safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)",
        "function safeTransferFrom(address,address,uint256,uint256,bytes)",
        "function setApprovalForAll(address,bool)",
        "function setController(address,bool)",
        "function setMetadataService(address)",
        "function setRecord(bytes32,address,address,uint64)",
        "function setResolver(bytes32,address)",
        "function setSubnodeOwner(bytes32,bytes32,address) returns (bytes32)",
        "function setSubnodeOwnerAndWrap(bytes32,string,address,uint96) returns (bytes32)",
        "function setSubnodeRecord(bytes32,bytes32,address,address,uint64)",
        "function setSubnodeRecordAndWrap(bytes32,string,address,address,uint64,uint96)",
        "function setTTL(bytes32,uint64)",
        "function supportsInterface(bytes4) view returns (bool)",
        "function transferOwnership(address)",
        "function unwrap(bytes32,bytes32,address)",
        "function unwrapBNB2LD(bytes32,address,address)",
        "function uri(uint256) view returns (string)",
        "function wrap(bytes,address,uint96,address)",
        "function wrapBNB2LD(string,address,uint96,address)"
    ]
}

```
