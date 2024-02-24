// SPDX-License-Identifier: AGPL-3.0-or-later

/// dai.t.sol -- tests for dai.sol

// Copyright (C) 2015-2019  DappHub, LLC

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity 0.8.24;

import {Test, console2} from "forge-std/Test.sol";

import {Dai} from "../src/dai.sol";

contract TokenUser {
    Dai  token;

    constructor(Dai token_) {
        token = token_;
    }

    function doTransferFrom(address from, address to, uint256 amount)
        public
        returns (bool)
    {
        return token.transferFrom(from, to, amount);
    }

    function doTransfer(address to, uint256 amount)
        public
        returns (bool)
    {
        return token.transfer(to, amount);
    }

    function doApprove(address recipient, uint256 amount)
        public
        returns (bool)
    {
        return token.approve(recipient, amount);
    }

    function doAllowance(address owner, address spender)
        public
        view
        returns (uint)
    {
        return token.allowance(owner, spender);
    }

    function doBalanceOf(address who) public view returns (uint) {
        return token.balanceOf(who);
    }

    function doApprove(address guy)
        public
        returns (bool)
    {
        return token.approve(guy, type(uint256).max);
    }
    function doMint(uint256 wad) public {
        token.mint(address(this), wad);
    }
    function doBurn(uint256 wad) public {
        token.burn(address(this), wad);
    }
    function doMint(address guy, uint256 wad) public {
        token.mint(guy, wad);
    }
    function doBurn(address guy, uint256 wad) public {
        token.burn(guy, wad);
    }

}

contract DaiTest is Test {
    uint256 constant initialBalanceThis = 1000;
    uint256 constant initialBalanceCal = 100;

    Dai token;
    address user1;
    address user2;
    address self;

    uint256 amount = 2;
    uint256 fee = 1;
    uint256 nonce = 0;
    uint256 deadline = 0;
    address cal = 0x29C76e6aD8f28BB1004902578Fb108c507Be341b;
    address del = 0xdd2d5D3f7f1b35b7A0601D6A00DbB7D44Af58479;
    bytes32 r = 0x8e30095d9e5439a4f4b8e4b5c94e7639756474d72aded20611464c8f002efb06;
    bytes32 s = 0x49a0ed09658bc768d6548689bcbaa430cefa57846ef83cb685673a9b9a575ff4;
    uint8 v = 27;
    bytes32 _r = 0x85da10f8af2cf512620c07d800f8e17a2a4cd2e91bf0835a34bf470abc6b66e5;
    bytes32 _s = 0x7e8e641e5e8bef932c3a55e7365e0201196fc6385d942c47d749bf76e73ee46f;
    uint8 _v = 27;


    function setUp() public {
        vm.warp(604411200);
        token = createToken();
        token.mint(address(this), initialBalanceThis);
        token.mint(cal, initialBalanceCal);
        user1 = address(new TokenUser(token));
        user2 = address(new TokenUser(token));
        self = address(this);
    }

    function createToken() internal returns (Dai) {
        return new Dai(99);
    }

    function testValidTransfers() public logs_gas {
        uint256 sentAmount = 250;
        uint256 initialTotalSupply = token.totalSupply();
        token.transfer(user2, sentAmount);
        assertEq(token.balanceOf(user2), sentAmount);
        assertEq(token.balanceOf(self) , initialBalanceThis - sentAmount);
        assertEq(token.totalSupply()   , initialTotalSupply);
    }

    function testMintGuy() public {
        uint256 mintAmount = 10;
        uint256 initialTotalSupply = token.totalSupply();
        token.mint(user1, mintAmount);
        assertEq(token.balanceOf(user1), mintAmount);
        assertEq(token.totalSupply(), initialTotalSupply + mintAmount);
    }

    function testBurnGuyWithTrust() public {
        uint256 burnAmount = 10;
        uint256 initialTotalSupply = token.totalSupply();
        token.transfer(user1, burnAmount);
        assertEq(token.balanceOf(user1), burnAmount);

        TokenUser(user1).doApprove(self);
        token.burn(user1, burnAmount);
        assertEq(token.balanceOf(user1), 0);
        assertEq(token.totalSupply(), initialTotalSupply - burnAmount);
    }

    function testTrustedTransferFrom() public {
        uint256 initialTotalSupply = token.totalSupply();
        token.approve(user1, type(uint256).max);
        TokenUser(user1).doTransferFrom(self, user2, 200);
        assertEq(token.balanceOf(user2), 200);
        assertEq(token.totalSupply(), initialTotalSupply);
    }
}
