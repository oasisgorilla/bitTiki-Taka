// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BTTPool.sol";

contract BTTSwap {
    address[] public allPairs;// 컨트랙트에서 생성된 유동성 풀 주소
    mapping(address => mapping(address => BTTPool)) public getPair; // 특정 토큰 쌍의 유동성 풀 주소를 저장
    event PairCreated(address indexed token1, address indexed token2, address pair);

    // 유동성 풀 페어 생성 함수
    function createPairs(address token1, address token2, string calldata token1Name, string calldata token2Name) external returns(address) {
        // 유효성 검사
        require(token1 != token2, "Identical address is not allowed"); // 같은 토큰끼리 페어를 생성하는 것은 불가능함
        require(address(getPair[token1][token2]) == address(0), "Pair already exists"); // 이미 존재하는 페어를 또 생성하는 것은 불가능함

        string memory liquidityTokenName = string(abi.encodePacked("Liquidity-", token1Name, "-", token2Name));
        string memory liquidityTokenSymbol = string(abi.encodePacked("LP-", token1Name, "-", token2Name));
        
        BTTPool bttPool = new BTTPool(token1, token2, liquidityTokenName, liquidityTokenSymbol); // 풀 생성

        getPair[token1][token2] = bttPool;
        getPair[token2][token1] = bttPool; // (1, 2)페어와 (2, 1)페어가 동일한 순서로 인식되도록 함
        allPairs.push(address(bttPool)); // 새로운 유동성 풀을 allPairs 배열에 추가함

        emit PairCreated(token1, token2, address(bttPool)); // 컨트랙트 스캔시 새로 생성된 페어 정보를 쉽게 확인할 수 있도록 이벤트를 발행

        return address(bttPool);
    }

    // 유동성 풀의 개수를 가져옴
    function allPairsLength() external view returns(uint) { 
        return allPairs.length;
    }

    // allPairs 전체 배열의 getter, 자동으로 생성된 getter는 특정 idx의 값만 반환함
    function getPairs() external view returns(address[] memory) { 
        return allPairs;
    }
}