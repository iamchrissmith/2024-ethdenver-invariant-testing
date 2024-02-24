// SPDX-FileCopyrightText: © 2024 Chris Smith <https://github.com/iamchrissmith>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Copyright © 2024 Chris Smith
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity 0.8.24;

import {Test, console, console2} from "forge-std/Test.sol";
import {Dai} from "../../src/dai.sol";
import {DaiHandler} from "./handlers/DaiHandler.sol";

contract DaiInvariants is Test {
    Dai        public dai;
    DaiHandler public _daiHandler;

    function setUp() public virtual {
        dai = new Dai(99);
        _daiHandler = new DaiHandler(dai);

        // give the dai handler permission to mint dai
        dai.rely(address(_daiHandler));

        // setup Actors in Handler
        _daiHandler.init();

        bytes4[] memory selectors = new bytes4[](7);
        selectors[0] = _daiHandler.transfer.selector;
        selectors[1] = _daiHandler.transferFrom.selector;
        selectors[2] = _daiHandler.mint.selector;
        selectors[3] = _daiHandler.burn.selector;
        selectors[4] = _daiHandler.approve.selector;
        selectors[5] = _daiHandler.rely.selector;
        selectors[6] = _daiHandler.deny.selector;

        targetSelector(
            FuzzSelector({
                addr: address(_daiHandler),
                selectors: selectors
            })
        );

        targetContract(address(_daiHandler));
    }

    // Sum of all DST balances should equal total supply
    function invariant_dai_balances_equal_totalSupply() public {
        uint256 sumBalances;
        uint256 dstCount = _daiHandler.dstsLength();

        for (uint256 i = 0; i < dstCount; i++) {
            (address addr, ) = _daiHandler.dsts(i);
            sumBalances += dai.balanceOf(addr);
        }

        require(sumBalances == dai.totalSupply(), "DaiInvariants/sumBalances-not-equal-totalSupply");
    }
}
