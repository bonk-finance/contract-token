// SPDX-License-Identifier: UNKNOWN
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ArcFaucet is UUPSUpgradeable, Ownable {
    using SafeERC20 for ERC20;
    ERC20 private immutable arcToken;
    mapping(address => uint256) userNextBuyTime;
    uint256 private immutable buyTimeLimit;

    event GrantFaucet(address _user, uint timestamp);

    constructor(address _o, address _arc, uint _buyTimeLimit) Ownable(_o) {
        arcToken = ERC20(_arc);
        buyTimeLimit = _buyTimeLimit;
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
    
    function requestTokens() public {
        require(msg.sender != address(0), "Cannot send token zero address");
        require(
            block.timestamp > userNextBuyTime[msg.sender],
            "Your next request time is not reached yet"
        );
        require(
            arcToken.transfer(msg.sender, 10 ether),
            "requestTokens(): Failed to Transfer"
        );
        userNextBuyTime[msg.sender] = block.timestamp + buyTimeLimit;
        emit GrantFaucet(msg.sender, block.timestamp);
    }

    function getNextBuyTime() public view returns (uint256) {
        return userNextBuyTime[msg.sender];
    }


}