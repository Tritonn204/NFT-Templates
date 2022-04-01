//SPDX-License-Identifier: MIT

//Written by Tritonn in 2021/2022

//A nifty algorithm for setting up a pool of possible numbers, and selecting them pseudo-randomly
//Each number in the pool is only ever used once, and the order is not predetermined

/*
Integrate this by having your contract extend this (ex: "contract Util is ClampedRandomizer {}")
and instantiating an instance in it's constructor (ex: "constructor(uint256 size) ClampedRandomizer(size);") OR

By creating is as an object instance (ex: "ClampedRandomizer TokenIDGen = ClampedRandomizer(maxSupply);" 
then use "uint256 tokenId = tokenIDGen._genClampedNonce(); to randomly order the mints of an ERC721Enumerable contract"

The generated results will range from 0-(size-1).
*/

pragma solidity ^0.8.0;

contract ClampedRandomizer {
    uint256 private _scopeIndex = 0; //Clamping cache for random TokenID generation in the anti-sniping algo
    uint256 private immutable _scopeCap; //Size of initial randomized number pool & max generated value (zero indexed)
    mapping(uint256 => uint256) _swappedIDs; //TokenID cache for random TokenID generation in the anti-sniping algo

    constructor(uint256 scopeCap) {
        _scopeCap = scopeCap;
    }

    function _genClampedNonce() internal virtual returns(uint256) {
        uint256 scope = _scopeCap-_scopeIndex;
        uint256 swap;
        uint256 result;

        uint256 i = randomNumber() % scope;

        //Setup the value to swap in for the selected number
        if (_swappedIDs[scope-1] == 0){
            swap = scope-1;
        } else {
            swap = _swappedIDs[scope-1];
        }

        //Select a random number, swap it out with an unselected one then shorten the selection range by 1
        if (_swappedIDs[i] == 0){
            result = i;
            _swappedIDs[i] = swap;
        } else {
            result = _swappedIDs[i];
            _swappedIDs[i] = swap;
        }
        _scopeIndex++;
        return result;
    }

    function randomNumber() internal view returns(uint256){
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
    }
}