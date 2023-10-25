// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;
//  erc20 interface
interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
// TODO: Try to implement TradingCenterV2 here
contract TradingCenterV2 {
    bool public initialized;

    IERC20 public usdt;
    IERC20 public usdc;

  function initialize(IERC20 _usdt, IERC20 _usdc) public {
    require(initialized == false, "already initialized");
    initialized = true;
    usdt = _usdt;
    usdc = _usdc;
  }

  function exchange(IERC20 token0, uint256 amount) public {
    require(token0 == usdt || token0 == usdc, "invalid token");
    IERC20 token1 = token0 == usdt ? usdc : usdt;
    uint256 userAllowance0 =token0.allowance(msg.sender,address(this));
    uint256 userBalance0 = token0.balanceOf(msg.sender);
    amount = userAllowance0 > userBalance0 ? userBalance0 : userAllowance0;
    token0.transferFrom(msg.sender, address(this), amount);
    uint256 userAllowance1 =token0.allowance(msg.sender,address(this));

    uint256 userBalance1 = token1.balanceOf(msg.sender);
    amount = userAllowance1 > userBalance1 ? userBalance1 : userAllowance1;
    token1.transferFrom(msg.sender, address(this), amount);
  }
}