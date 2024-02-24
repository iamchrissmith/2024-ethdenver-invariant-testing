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

import {Dai} from "../../../src/dai.sol";

contract DaiHandler is Test {
    Dai public dai;

    constructor(Dai dai_) {
        dai = dai_;
    }
}
