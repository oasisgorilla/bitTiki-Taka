//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BTTLiquidityToken.sol";

contract BTTPool {
    // 풀 주소
    address public token1;
    address public token2;

    // 풀에 남은 토큰 수량
    uint256 public reserve1;
    uint256 public reserve2;

    // x * y = k
    uint256 public constantK;

    BTTLiquidityToken public liquidityToken;

    constructor(address _token1, address _token2) {
        token1 = _token1;
        token2 = _token2;
        liquidityToken = new BTTLiquidityToken();
    }
}