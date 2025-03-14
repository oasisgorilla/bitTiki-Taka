// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract BTTLiquidityToken is ERC20, AccessControl {
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender); // BTTPool만 이 컨트랙트의 기능에 접근할 수 있음
    }

    function mint(address to, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(to, amount);
    }

    function burn(address to, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _burn(to, amount);
    }
}