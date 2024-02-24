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

    Actor[] public   actors;
    Actor[] public   dsts;
    Actor   internal actor;

    bytes32[] internal expectedErrors;

    struct Actor {
        address addr;
        uint256 key;
    }

    modifier useRandomActor(uint256 _actorIndex) {
        actor = _selectActor(_actorIndex);
        changePrank(actor.addr);
        _;
        delete actor;
        vm.stopPrank();
    }

    modifier resetErrors() {
        _;
        delete expectedErrors;
    }

    constructor(Dai dai_) {
        dai = dai_;
    }

    function init() external {
        for (uint256 i = 0; i < 10; i++) {
            Actor memory _actor;
            (_actor.addr, _actor.key) = makeAddrAndKey(string(abi.encodePacked("Actor", vm.toString(i))));
            actors.push(_actor);
            dsts.push(_actor);
            dai.mint(_actor.addr, 1000 ether);
        }

        Actor memory zero;
        (zero.addr, zero.key) = makeAddrAndKey(string(abi.encodePacked("Zero")));
        zero.addr = address(0);
        dsts.push(zero);
    }

    // External Handler Functions
    function transfer(
        uint256 _actorIndex,
        uint256 _dstIndex,
        uint256 _wad
    ) public useRandomActor(_actorIndex) resetErrors {
        Actor memory dst = _selectDst(_dstIndex);
        try dai.transfer(dst.addr, _wad) {
            console.log("Transfer succeeded");
        } catch Error(string memory reason) {
            if(dai.balanceOf(actor.addr) < _wad) addExpectedError("Dai/insufficient-balance");
            expectedError(reason);
        } catch (bytes memory reason) {
            console.log("Transfer failed: ");
            console.logBytes(reason);
        }
    }

    // Internal Helper Functions
    function _selectActor(uint256 _actorIndex) internal view returns (Actor memory actor_) {
        uint256 index = bound(_actorIndex, 0, actors.length - 1);
        actor_ = actors[index];
    }

    function _selectDst(uint256 _dstIndex) internal view returns (Actor memory dst) {
        uint256 index = bound(_dstIndex, 0, dsts.length - 1);
        dst = dsts[index];
    }

    function addExpectedError(string memory _err) internal {
        expectedErrors.push(keccak256(abi.encodePacked(_err)));
    }

    function expectedError(string memory _err) internal view {
        bytes32 err = keccak256(abi.encodePacked(_err));
        bool _valid;

        uint256 errLen = expectedErrors.length;
        for (uint256 i = 0; i < errLen; i++) {
            if (err == expectedErrors[i]) {
                _valid = true;
            }
        }

        if (!_valid) {
            console.log("Unhandled Error:");
            console.log(_err);
        }
        require(_valid, "Unexpected revert error");
    }
}
