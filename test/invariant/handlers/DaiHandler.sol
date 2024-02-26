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

        Actor memory governance;
        (governance.addr, governance.key) = makeAddrAndKey(string(abi.encodePacked("Governance")));
        actors.push(governance);
        dsts.push(governance);
        dai.rely(governance.addr);

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

    function transferFrom(
        uint256 _actorIndex,
        uint256 _srcIndex,
        uint256 _dstIndex,
        uint256 _wad
    ) public useRandomActor(_actorIndex) resetErrors {
        Actor memory src = _selectActor(_srcIndex);
        Actor memory dst = _selectDst(_dstIndex);
        try dai.transferFrom(src.addr, dst.addr, _wad) {
            console.log("TransferFrom succeeded");
        } catch Error(string memory reason) {
            if(dai.balanceOf(src.addr) < _wad) addExpectedError("Dai/insufficient-balance");
            if(dai.allowance(src.addr, actor.addr) < _wad) addExpectedError("Dai/insufficient-allowance");
            expectedError(reason);
        } catch (bytes memory reason) {
            console.log("TransferFrom failed: ");
            console.logBytes(reason);
        }
    }

    function mint(
        uint256 _actorIndex,
        uint256 _dstIndex,
        uint256 _wad
    ) public useRandomActor(_actorIndex) resetErrors {
        Actor memory dst = _selectDst(_dstIndex);
        try dai.mint(dst.addr, _wad) {
            console.log("Mint succeeded");
        } catch Error(string memory reason) {
            if(dai.wards(actor.addr) == 0) addExpectedError("Dai/not-authorized");
            expectedError(reason);
        } catch (bytes memory reason) {
            console.log("Mint failed: ");
            console.logBytes(reason);
        }
    }

    function burn(
        uint256 _actorIndex,
        uint256 _usrIndex,
        uint256 _wad
    ) public useRandomActor(_actorIndex) resetErrors {
        Actor memory usr = _selectActor(_usrIndex);
        try dai.burn(usr.addr,  _wad) {
            console.log("burn succeeded");
        } catch Error(string memory reason) {
            if(dai.balanceOf(usr.addr) < _wad) addExpectedError("Dai/insufficient-balance");
            if(dai.allowance(usr.addr, actor.addr) < _wad) addExpectedError("Dai/insufficient-allowance");
            expectedError(reason);
        } catch (bytes memory reason) {
            console.log("burn failed: ");
            console.logBytes(reason);
        }
    }

    function approve(
        uint256 _actorIndex,
        uint256 _usrIndex,
        uint256 _wad
    ) public useRandomActor(_actorIndex) resetErrors {
        Actor memory usr = _selectActor(_usrIndex);
        try dai.approve(usr.addr,  _wad) {
            console.log("approve succeeded");
        } catch Error(string memory reason) {
            expectedError(reason);
        } catch (bytes memory reason) {
            console.log("approve failed: ");
            console.logBytes(reason);
        }
    }

    function rely(
        uint256 _actorIndex,
        uint256 _guyIndex
    ) public useRandomActor(_actorIndex) resetErrors {
        Actor memory guy = _selectActor(_guyIndex);
        try dai.rely(guy.addr) {
            console.log("rely succeeded");
        } catch Error(string memory reason) {
            if(dai.wards(actor.addr) == 0) addExpectedError("Dai/not-authorized");
            expectedError(reason);
        } catch (bytes memory reason) {
            console.log("rely failed: ");
            console.logBytes(reason);
        }
    }

    function deny(
        uint256 _actorIndex,
        uint256 _guyIndex
    ) public useRandomActor(_actorIndex) resetErrors {
        Actor memory guy = _selectActor(_guyIndex);
        try dai.deny(guy.addr) {
            console.log("deny succeeded");
        } catch Error(string memory reason) {
            if(dai.wards(actor.addr) == 0) addExpectedError("Dai/not-authorized");
            expectedError(reason);
        } catch (bytes memory reason) {
            console.log("deny failed: ");
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

    function dstsLength() external view returns (uint256) {
        return dsts.length;
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
