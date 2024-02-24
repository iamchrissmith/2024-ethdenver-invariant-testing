# Invariant Fuzz Testing Presentation and Code

## What is this and whoami

This repo is built for a talk I am giving at EthDenver 2024 to explain what invariant fuzz testing is and show how to use it with [Foundry](https://book.getfoundry.sh/forge/invariant-testing).

I am an independent security research who works with clients through invariant test engineering, security reviews and protocol/technical advising.

Formerly, I was a (pre-endgame) Senior Protocol Engineer with MakerDAO, a Maker Foundation Smart Contract Engineer (securing and launching MCD), and a Backend and Smart Contract Engineer with ConsenSys.

I can be found on the internet occassionally on [Twitter](https://twitter.com/iamchrissmith), [LinkedIn](https://www.linkedin.com/in/iamchrisryansmith/), at my [business website](https://lefthandcypher.com/) and, of course, here on [GitHub](https://github.com/iamchrissmith).

**Note:** All code in this repo is for demonstration purposes only

DAI code has been updated slighlty to be compatible with Solidity 0.8 and Foundry.

## Branches / Walkthrough

`main`: Initial Repo setup

### 1 - Invariant Setup

branch: `1-invariant-setup`

Important Concepts:

`runs` and `depth` parameters for the forge command/`foundry.toml`. As explained from Foundry Book:
> runs: Number of times that a sequence of function calls is generated and run.
> depth: Number of function calls made in a given run. All defined invariants are asserted after each function call is made. If a function call reverts, the depth counter still increments.

`fail_on_revert`
Set in `foundry.toml`. When set to `true` (my preference) it will fail the tests when it hits an unexpected `revert`.

#### Invariants

These are the files/tests that will define the rules that should always be true.

#### Handlers

These contracts are essentially wrappers around the contracts/functionality we want to test.  They allow us to define test specific conditions and rules to make our tests more robust.

#### Regressions

If we find a failing sequence, these are the unit tests that we can use to reproduce the failure and check our fix.

### 2 - Handler Setup

branch: `2-handler-setup`

Important Concepts:

#### Handler's purpose

Your handler is the wrapper around the contract that you are testing. You should add all functions you want to be included in your testing to this contract (most likely all external functions that modify state).  The test suite will call these functions in random order with random input.

Calls to the contract you're testing should be wrapped in `try/catch` blocks so you can handle errors.

#### Actors

To make the test suite better simulate what will happen post deployment, you need a set of actors and destination addresses that will be the `msg.sender` and targets for your function calls.

#### Error handling

You will need to decide whether you are going to `bound` your inputs so that calls are successful or if you are going to add error exclusions.

#### Requires/Reverts

You can add handler function level assertions to these functions if you want to assert certain things are true during a specific call.  This makes the handler functions act like fuzz tests within your invariant test suite.

### 3 - Our First Invariant

branch: `3-add-balance-invariant`

Here we add our first "real" invariant.  After setup and then after every handler function call this invariant will be tested to ensure it holds true.  If it fails, we will get a sequence that can be used to analyze the calls that were made to cause the violation.

In this case, we are summing the balance of each destination (`dst`) actor and ensure that sum **always** equals the `dai.totalSupply()`.
