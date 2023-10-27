pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "solmate/tokens/ERC20.sol";
import "forge-std/console.sol"; 
import { USDCV2 } from "../src/USDCV2.sol";
import { Merkle } from "murky/src/Merkle.sol";

contract USDCTest is Test {
   
    Account public user1 = makeAccount("leaf1");
    Account public user2 = makeAccount("leaf2");
    Account public user3 = makeAccount("leaf3");
    Account public user4 = makeAccount("leaf4");
    Merkle m = new Merkle();

    bytes32[] public leaf;
    bytes32 root;

    function setUp() public {
        
        leaf = new bytes32[](4);
        leaf[0] = keccak256(abi.encodePacked(user1.addr));
        leaf[1] = keccak256(abi.encodePacked(user2.addr));
        leaf[2] = keccak256(abi.encodePacked(user3.addr));

        root = m.getRoot(leaf);
        
    }

    function test_only_contract() public {
        USDCV2 usdcV2=new USDCV2();
        usdcV2.setWhiteList(root);

        vm.startPrank(user1.addr);
        uint256 indexInLeaf = 0;
        bytes32[] memory proof = m.getProof(leaf, indexInLeaf);

        bool mint = usdcV2.mint(proof, 1);
        require(mint);
        assertEq(usdcV2.balanceOf(user1.addr),1);
        assertEq(usdcV2.totalSupply(),1);

        bool transfer = usdcV2.transfer(proof, user2.addr, 1);
        require(transfer);
        assertEq(usdcV2.balanceOf(user1.addr),0);
        assertEq(usdcV2.balanceOf(user2.addr),1);
        assertEq(usdcV2.totalSupply(),1);
        vm.stopPrank();

        vm.startPrank(user4.addr);
        vm.expectRevert("whitelist only!!");
        mint = usdcV2.mint(proof, 1);
        vm.expectRevert("whitelist only!!");
        transfer = usdcV2.transfer(proof, user2.addr, 1);
    }

     function test_proxy_upgrade() public {

        uint256 indexInLeaf = 0;
        bytes32[] memory proof = m.getProof(leaf, indexInLeaf);
        bytes memory data;
        bool success;
        uint256 balanceValue;

        uint256 forkId = vm.createFork("https://eth-mainnet.g.alchemy.com/v2/d4TZEfJF1fOUpSaiaBFMOtiwMTa54gRb");
        vm.selectFork(forkId);
        address owner = 0x807a96288A1A408dBC13DE2b1d087d10356395d2;
        address usdcProxy=0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        USDCV2 usdcV2=new USDCV2();

        vm.startPrank(owner);
        (success,) = usdcProxy.call(abi.encodeWithSignature("upgradeTo(address)",address(usdcV2)));
        require(success);
        vm.stopPrank();

        vm.startPrank(user1.addr);
        //set White List
        (success,) = usdcProxy.call(abi.encodeWithSignature("setWhiteList(bytes32)",root));
        require(success);
        //mint
        (success,) = usdcProxy.call(abi.encodeWithSignature("mint(bytes32[],uint256)",proof,1));
         require(success);
        (success,data) = usdcProxy.call(abi.encodeWithSignature("balanceOf(address)",user1.addr));
        require(success);
        balanceValue = abi.decode(data,(uint256));
        assertEq(balanceValue,1);
        //transfer
        (success,) = usdcProxy.call(abi.encodeWithSignature("transfer(bytes32[],address,uint256)"
            ,proof,user2.addr,1));
        require(success);
        (success,data) = usdcProxy.call(abi.encodeWithSignature("balanceOf(address)",user2.addr));
        require(success);
        balanceValue = abi.decode(data,(uint256));
        assertEq(balanceValue,1);
        vm.stopPrank();

        vm.startPrank(user4.addr);
        vm.expectRevert("whitelist only!!");
        (success,) = usdcProxy.call(abi.encodeWithSignature("mint(bytes32[],uint256)",proof,1));

        vm.stopPrank();
     }

}