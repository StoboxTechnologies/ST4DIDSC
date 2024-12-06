// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {BaseHook} from "v4-periphery/src/base/hooks/BaseHook.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "v4-core/types/BeforeSwapDelta.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";

interface IDIDValidator {
    function validateUser(address user) external;
}

contract DIDHook is BaseHook {
    IDIDValidator validator;

    constructor(IPoolManager _manager, address _validatorContract) BaseHook(_manager) {
        validator = IDIDValidator(_validatorContract);
    }

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: false,
            beforeAddLiquidity: true,
            beforeRemoveLiquidity: true,
            afterAddLiquidity: false,
            afterRemoveLiquidity: false,
            beforeSwap: true,
            afterSwap: false,
            beforeDonate: true,
            afterDonate: false,
            beforeSwapReturnDelta: false,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    function beforeAddLiquidity(
        address sender,
        PoolKey calldata,
        IPoolManager.ModifyLiquidityParams calldata,
        bytes calldata
    ) external override onlyPoolManager returns (bytes4) {
        validator.validateUser(sender);
        return (this.beforeAddLiquidity.selector);
    }

    function beforeRemoveLiquidity(
        address sender,
        PoolKey calldata,
        IPoolManager.ModifyLiquidityParams calldata,
        bytes calldata
    ) external override onlyPoolManager returns (bytes4) {
        validator.validateUser(sender);
        return (this.beforeRemoveLiquidity.selector);
    }

    function beforeSwap(address sender, PoolKey calldata key, IPoolManager.SwapParams calldata, bytes calldata)
        external
        override
        onlyPoolManager
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        validator.validateUser(sender);
        return (this.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, key.fee);
    }

    function beforeDonate(address sender, PoolKey calldata, uint256, uint256, bytes calldata)
        external
        override
        onlyPoolManager
        returns (bytes4)
    {
        validator.validateUser(sender);
        return (this.beforeDonate.selector);
    }
}
