// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract DDNSToken is ERC20Capped, ERC20Burnable {
    function _applyDecimal(uint256 _amount) internal view returns (uint256) {
        return _amount * (10 ** decimals());
    }

    string public constant contractSymbol = "DDNS";
    string public constant contractName = "DDNS Token";

    address payable public owner;
    uint256 public blockReward = _applyDecimal(100);

    constructor(uint256 _initialSupply, uint256 _tokenCap, uint256 _blockReward) ERC20(contractName, contractSymbol) ERC20Capped (_applyDecimal(_tokenCap)){
        owner = payable(msg.sender);
        blockReward = _applyDecimal(_blockReward);

        _mint(owner, _applyDecimal(_initialSupply));
    }

    function _mint(address account, uint256 amount) internal virtual override (ERC20Capped, ERC20) {
        ERC20Capped._mint(account, amount);
    }

    function _mintMinerReward() internal {
        _mint(block.coinbase, blockReward);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        if (from != address(0) && to != block.coinbase && block.coinbase != address(0)){
            _mintMinerReward();
        }

        super._beforeTokenTransfer(from, to, amount);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    function setBlockReward(uint256 _blockReward) public onlyOwner {
        blockReward = _applyDecimal(_blockReward);
    }
}