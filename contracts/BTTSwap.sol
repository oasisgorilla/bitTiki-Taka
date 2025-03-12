// SPDX-License-Identifier: MIT

import "./BTTPool.sol";

contract BTTSwap {
    address[] public allPairs;// 컨트랙트에서 생성된 유동성 풀 주소
    mapping(address => mapping(address => BTTPool)) public getPair; // 특정 토큰 쌍의 유동성 풀 주소를 저장
    event PairCreated(address indexed token1, address indexed token2, address pair);

    function createPairs(address token1, address token2, string calldata token1Name, string calldata token2Name) external returns(address) { // 유동성 풀 페어 생성 함수
        require(token1 != token2, "Identical address is not allowed"); // 같은 토큰끼리 페어를 생성하는 것은 불가능함
        require(address(getPair[token1][token2]) == address(0), "Pair already exists");

        BTTPool bttPool = new BTTPool();

        getPair[token1][token2] = bttPool;
        getPair[token2][token1] = bttPool; // (1, 2)페어와 (2, 1)페어가 동일한 순서로 인식되도록 함
        allPairs.push(address(bttPool)); // 새로운 유동성 풀을 allPairs 배열에 추가함

        emit PairCreated(token1, token2, address(bttPool)); // 컨트랙트 스캔시 새로 생성된 페어 정보를 쉽게 확인할 수 있도록 이벤트를 발행

        return address(bttPool);
    }

    function allPairsLength() external view returns(uint) { // 유동성 풀의 개수를 가져옴
        return allPairs.length;
    }

    function getPairs() external view returns(address[] memory) { // allPairs 전체 배열의 getter, 자동으로 생성된 getter는 특정 idx의 값만 반환함
        return allPairs;
    }
}