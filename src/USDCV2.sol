// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;
import "oz/utils/cryptography/MerkleProof.sol";


contract USDCV2 {
    // the slot same with usdc's FiatTokenV2
    address private _owner;
    address public pauser;
    bool public paused = false;
    address public blacklister;
    mapping(address => bool) internal blacklisted;
    string public name;
    string public symbol;
    uint8 public decimals;
    string public currency;
    address public masterMinter;
    bool internal initialized;
    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowed;
    uint256 internal totalSupply_ = 0;
    mapping(address => bool) internal minters;
    mapping(address => uint256) internal minterAllowed;
    address _rescuer;
    bytes32 DOMAIN_SEPARATOR;
    mapping(address => mapping(bytes32 => bool)) _authorizationStates;
    mapping(address => uint256) _permitNonces;
    uint8 _initializedVersion;

    bytes32 private merkleRoot;

    modifier whiteListOnly(bytes32[] memory _merkleProof, address _who) {
        require(inWhitelist(_merkleProof, _who), "whitelist only!!");
        _;
    }

    function setWhiteList(bytes32 _merkleRoot) public{
        merkleRoot=_merkleRoot;
    }

    function inWhitelist(bytes32[] memory _merkleProof, address _who) internal view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(_who));
        return MerkleProof.verify(_merkleProof, merkleRoot, leaf);
    }

    function transfer(bytes32[] memory _merkleProof, address to, uint256 amount) public 
    whiteListOnly(_merkleProof,msg.sender) returns (bool) {
        balances[msg.sender]-=amount;
        balances[to]+=amount;
        return true;
    }

    function mint(bytes32[] memory _merkleProof, uint256 amount) public 
    whiteListOnly(_merkleProof,msg.sender) returns (bool) {
        balances[msg.sender]+=amount;
        totalSupply_ += amount;
        return true;
    }

    function balanceOf(address _who) public view returns (uint256) {
        return balances[_who];
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }
}