// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
    AIXX COIN
    =========
    Hard money for the AI era.
    A neutral, non-medical digital asset representing
    the human condition in a hyper-automated world.

    - Fixed max supply
    - Time-based emission with halving
    - Fair launch
    - ERC20 + EIP-2612 Permit
    - No owner, no upgrade, no pause, no taxes
*/

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

error ZeroAddress();
error NothingToClaim();

contract AIXX is ERC20, ERC20Permit {

    /*//////////////////////////////////////////////////////////////
                              CONSTANTS
    //////////////////////////////////////////////////////////////*/

    uint256 public constant MAX_SUPPLY =
        21_000_000 * 10 ** 18;

    uint256 public constant EPOCH =
        4 * 365 days; // Bitcoin-like pacing

    uint256 public constant INITIAL_EMISSION =
        MAX_SUPPLY / 4; // 25% first epoch

    /*//////////////////////////////////////////////////////////////
                              IMMUTABLES
    //////////////////////////////////////////////////////////////*/

    uint256 public immutable startTime;

    /*//////////////////////////////////////////////////////////////
                              STATE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalEmitted;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor()
        ERC20("AIXX COIN", "AIXX")
        ERC20Permit("AIXX COIN")
    {
        startTime = block.timestamp;
    }

    /*//////////////////////////////////////////////////////////////
                        EMISSION / HALVING
    //////////////////////////////////////////////////////////////*/

    function currentEpoch() public view returns (uint256) {
        return (block.timestamp - startTime) / EPOCH;
    }

    function emissionForEpoch(uint256 epoch)
        public
        pure
        returns (uint256)
    {
        return INITIAL_EMISSION >> epoch;
    }

    function claim() external {
        uint256 epoch = currentEpoch();
        uint256 emission = emissionForEpoch(epoch);

        if (emission == 0) revert NothingToClaim();

        if (totalEmitted + emission > MAX_SUPPLY) {
            emission = MAX_SUPPLY - totalEmitted;
        }

        if (emission == 0) revert NothingToClaim();

        totalEmitted += emission;
        _mint(msg.sender, emission);
    }

    /*//////////////////////////////////////////////////////////////
                          SAFETY OVERRIDES
    //////////////////////////////////////////////////////////////*/

    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {
        if (to == address(0)) revert ZeroAddress();
        return super.transfer(to, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    )
        public
        override
        returns (bool)
    {
        if (to == address(0)) revert ZeroAddress();
        return super.transferFrom(from, to, amount);
    }
}
