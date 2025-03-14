//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BTTLiquidityToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract BTTPool {
    using Math for uint;

    // 풀 주소
    address public token1;
    address public token2;

    // 풀에 남은 토큰 수량
    uint256 public reserve1;
    uint256 public reserve2;

    // x * y = k
    uint256 public constantK;

    BTTLiquidityToken public liquidityToken;

    event Swap (
        address indexed sender,
        uint256 amountIn,
        uint256 amountOut,
        address tokenIn,
        address tokenOut
    );

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
        liquidity = (amountToken1 * amountToken2).sqrt();
       } else {
        liquidity = ((amountToken1 * totalSupplyOfToken) / reserve1).min((amountToken2 * totalSupplyOfToken) / reserve2);
       }
       liquidityToken.mint(msg.sender, liquidity); // 유동성을 추가한 사람에게 LP토큰 전송
       // amountToken1,2를 풀에 전송
       require(IERC20(token1).transferFrom(msg.sender, address(this), amountToken1), "Transfer of token1 is failed");
       require(IERC20(token2).transferFrom(msg.sender, address(this), amountToken2), "Transfer of token2 is failed");
       // reserve1,2를 업데이트 
       reserve1 += amountToken1;
       reserve2 += amountToken2;
       // constantK를 업데이트
       _updateConstantFormula();

    }

    // 유동성 제거 함수
    function removeLiquidity(uint amountOfLiquidity) external {
        uint256 totalSupply = liquidityToken.totalSupply();
        require(amountOfLiquidity <= totalSupply, "Liquidity is more than total supply");
        // 유동성 소각
        liquidityToken.burn(msg.sender, amountOfLiquidity);
        // token1, 2를 LP에게 전송
        uint256 amount1 = (reserve1 * amountOfLiquidity) / totalSupply; // 전체 풀에서 LP토큰 비율만큼 amount설정
        uint256 amount2 = (reserve2 * amountOfLiquidity) / totalSupply;

        require(IERC20(token1).transfer(msg.sender, amount1), "Transfer of token failed");
        require(IERC20(token2).transfer(msg.sender, amount2), "Transfer of token failed");
        // reserve1, 2를 업데이트
        reserve1 -= amount1;
        reserve2 -= amount2;
        // constantK를 업데이트
        _updateConstantFormula();
    }

    // 스왑
    function swapTokens(address fromToken, address toToken, uint256 amountIn, uint amountOut) external {
        // 유효성 검사
        require(amountIn > 0 && amountOut > 0, "Amount must be greater than 0"); // 스왑수량이 0 이상이어야 함
        require((fromToken == token1 && toToken == token2) || (fromToken == token1 && toToken == token2), "Tokens need to be pairs of this liquidity pool"); // 풀에 있는 페어여야 함
        // 사용자와 풀의 잔고가 amountIn, amountOut보다 많아야 함
        IERC20 fromTokenContract = IERC20(fromToken);
        IERC20 toTokenContract = IERC20(toToken);
        require(fromTokenContract.balanceOf(msg.sender) > amountIn, "Insufficient balance of tokenFrom");
        require(toTokenContract.balanceOf(address(this)) > amountOut, "Insufficient balance of tokenTo");
        // 계산 후의 amountOut이 예상 값과 일치하는지 여부 확인
        uint256 expectedAmountOut;
        if (fromToken == token1) {
            expectedAmountOut = (reserve2 - constantK) / (reserve1 + amountIn);
        } else {
            expectedAmountOut = (reserve1 - constantK) / (reserve2 + amountIn);
        }
        require(amountOut <= expectedAmountOut, "Swap does not preserve constant formula");
        // amountIn을 유동성 풀로, amountOut을 사용자에게 전송
        require(fromTokenContract.transferFrom(msg.sender, address(this), amountIn), "Transfer of token from failed"); // 사용자 지갑에서 fromToken을 amountIn만큼 유동성 풀로 전송
        require(toTokenContract.transfer(msg.sender, expectedAmountOut), "Transfer of token to failed"); // 풀에서 toToken을 expectedAmountOut만큼 사용자 지갑으로 전송
        // reserve1, 2를 업데이트
        if (fromToken == token1 && toToken == token2) {
            reserve1 = reserve1 + amountIn;
            reserve2 = reserve2 - expectedAmountOut;
        } else {
            reserve1 = reserve1 - expectedAmountOut;
            reserve2 = reserve2 + amountIn;
        }
        // constantK 확인
        require(reserve1 * reserve2 == constantK, "Swap does not preserve constant formula");
        emit Swap(msg.sender, amountIn, expectedAmountOut, fromToken, toToken);
    }

    // constantK를 업데이트
    function _updateConstantFormula() internal {
        constantK = reserve1 * reserve2;
        require(constantK > 0, "Constant formula not updated"); // 검증 필요
    }
}