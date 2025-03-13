//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BTTLiquidityToken.sol";
import "@openzeppelin/contracts/token/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract BTTPool {
    using Math for uint;
    using SafeMath for uint;

    // 풀 주소
    address public token1;
    address public token2;

    // 풀에 남은 토큰 수량
    uint256 public reserve1;
    uint256 public reserve2;

    // x * y = k
    uint256 public constantK;

    BTTLiquidityToken public liquidityToken;

    constructor(address _token1, address _token2, string memory _liquidityTokenName, string memory _liquidityTokenSymbol) {
        token1 = _token1;
        token2 = _token2;
        liquidityToken = new BTTLiquidityToken(_liquidityTokenName, _liquidityTokenSymbol);
    }

    // 유동성 추가 함수
    function addLiquidity(uint amountToken1, uint amountToken2) external {
       // LP토큰 생성 후 LP에게 전송
       uint256 liquidity;
       uint256 totalSupplyOfToken = liquidityToken.totalSupply();
       if (totalSupplyOfToken == 0) {
        // 최초 유동성
        liquidity = amountToken1.mul(amountToken2).sqrt();
       } else {
        liquidity = amountToken1.mul(totalSupplyOfToken).div(reserve1).min(amountToken2.mul(totalSupplyOfToken).div(reserve2));
       }
       liquidityToken.mint(msg.sender, liquidity); // 유동성을 추가한 사람에게 LP토큰 전송
       // amountToken1,2를 풀에 전송
       require(IERC20(token1).transferFrom(msg.sender, address(this), amountToken1), "Transfer of token1 is failed");
       require(IERC20(token2).transferFrom(msg.sender, address(this), amountToken2), "Transfer of token2 is failed");
       // reserve1,2를 업데이트 
       reserve1 += amountToken1;
       reserve2 += amountToken2;
       // constantK를 업데이트
       constantK = reserve1.mul(reserve2);
       require(constantK > 0, "Constant formula not updated"); // 검증 필요

    }
}