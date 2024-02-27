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

        bytes4[] memory selectors = new bytes4[](0);

        targetSelector(
            FuzzSelector({
                addr: address(_daiHandler),
                selectors: selectors
            })
        );

        targetContract(address(_daiHandler));
    }

    function invariant_dai_decimals() public {
        require(
            dai.decimals() == 18,
            "Invariant Dai Decimals"
        );
    }
}
