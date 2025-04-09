// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {IERC20} from "../../../src/interfaces/IERC20.sol";
import {IWETH} from "../../../src/interfaces/IWETH.sol";
import {ISwapRouter} from "../../../src/interfaces/uniswap-v3/ISwapRouter.sol";
import {DAI, WETH, WBTC, UNISWAP_V3_SWAP_ROUTER_02} from "../../../src/Constants.sol";

contract UniswapV3SwapTest is Test {
    IWETH private weth = IWETH(WETH);
    IERC20 private dai = IERC20(DAI);
    IERC20 private wbtc = IERC20(WBTC);
    ISwapRouter private router = ISwapRouter(UNISWAP_V3_SWAP_ROUTER_02);
    uint24 private constant POOL_FEE = 3000;

    function setUp() public {
        deal(DAI, address(this), 1000 * 1e18);
        dai.approve(address(router), type(uint256).max);
    }

    // Exercise 1
    // - Swap 1000 DAI for WETH on DAI/WETH pool with 0.3% fee
    // - Send WETH from Uniswap V3 to this contract
    function test_exactInputSingle() public {
        uint256 wethBefore = weth.balanceOf(address(this));

        // Write your code here
        // Call router.exactInputSingle

        uint256 amountIn = 1000 * 1e18;

        // Prepare swap parameters
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: DAI,
                tokenOut: WETH,
                fee: POOL_FEE,
                recipient: address(this),
                amountIn: amountIn,
                amountOutMinimum: 1,
                sqrtPriceLimitX96: 0
            });

        // Execute the swap
        uint amountOut = router.exactInputSingle(params);

        uint256 wethAfter = weth.balanceOf(address(this));

        console2.log("WETH amount out %e", amountOut);
        assertGt(amountOut, 0);
        assertEq(wethAfter - wethBefore, amountOut);
    }

    // Exercise 2
    // Swap 1000 DAI for WETH and then WETH to WBTC
    // - Swap DAI to WETH on pool with 0.3% fee
    // - Swap WETH to WBTC on pool with 0.3% fee
    // - Send WBTC from Uniswap V3 to this contract
    // NOTE: WBTC has 8 decimals
    function test_exactInput() public {
        // Write your code here
        // Call router.exactInput

        uint256 amountIn = 1000 * 1e18;
        // Prepare swap parameters

        bytes memory path = abi.encodePacked(
            DAI,
            uint24(POOL_FEE),
            WETH,
            uint24(POOL_FEE),
            WBTC
        );

        ISwapRouter.ExactInputParams memory params = ISwapRouter
            .ExactInputParams({
                path: path,
                recipient: address(this),
                amountIn: amountIn,
                amountOutMinimum: 1
            });

        uint256 amountOut = router.exactInput(params);

        console2.log("WBTC amount out %e", amountOut);
        assertGt(amountOut, 0);
        assertEq(wbtc.balanceOf(address(this)), amountOut);
    }

    // Exercise 3
    // - Swap maximum of 1000 DAI to obtain exactly 0.1 WETH from DAI/WETH pool with 0.3% fee
    // - Send WETH from Uniswap V3 to this contract
    function test_exactOutputSingle() public {
        uint256 wethBefore = weth.balanceOf(address(this));

        // Write your code here
        // Call router.exactOutputSingle
        uint256 amountInMax = 1000 * 1e18;
        uint256 amountOut = 0.1 * 1e18;

        // Prepare swap parameters
        ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter
            .ExactOutputSingleParams({
                tokenIn: DAI,
                tokenOut: WETH,
                fee: POOL_FEE,
                recipient: address(this),
                amountOut: amountOut,
                amountInMaximum: amountInMax,
                sqrtPriceLimitX96: 0
            });

        // Execute the swap
        uint256 amountIn = router.exactOutputSingle(params);

        uint256 wethAfter = weth.balanceOf(address(this));

        console2.log("DAI amount in %e", amountIn);
        assertLe(amountIn, 1000 * 1e18);
        assertEq(wethAfter - wethBefore, 0.1 * 1e18);
    }

    // Exercise 4
    // Swap maximum of 1000 DAI to obtain exactly 0.01 WBTC
    // - Swap WBTC to WETH on pool with 0.3% fee
    // - Swap WETH to DAI on pool with 0.3% fee
    // - Send WBTC from Uniswap V3 to this contract
    // NOTE: WBTC has 8 decimals
    function test_exactOutput() public {
        // Write your code here
        // Call router.exactOutput
        uint256 amountInMax = 1000 * 1e18;
        uint256 amountOut = 0.01 * 1e8;

        // Prepare swap parameters
        
        // bytes memory path = abi.encodePacked(
        //     DAI,
        //     uint24(POOL_FEE),
        //     WETH,
        //     uint24(POOL_FEE),
        //     WBTC
        // );

        bytes memory path =
            abi.encodePacked(WBTC, uint24(3000), WETH, uint24(3000), DAI);

        ISwapRouter.ExactOutputParams memory params = ISwapRouter
            .ExactOutputParams({
                path: path,
                recipient: address(this),
                amountOut: amountOut,
                amountInMaximum: amountInMax
            });

        // Execute the swap
        uint256 amountIn = router.exactOutput(params);

        console2.log("DAI amount in %e", amountIn);
        assertLe(amountIn, 1000 * 1e18);
        assertEq(wbtc.balanceOf(address(this)), 0.01 * 1e8);
    }
}
