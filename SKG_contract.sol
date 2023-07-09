// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SKG_contract is Ownable, ReentrancyGuard, Pausable {
    struct PackageData {
        uint256 idPackage;
        uint256 price;
        uint256 tag;
    }
    struct BuyerData {
        uint256 idPackage;
        uint256 price;
    }
    IERC20 public tokenPayment;
    bool public statusBuyPackage = false;
    address public receivingAddress;


    mapping(uint256 => PackageData) public packages;
    mapping(address => BuyerData) public buyerPackage;

    // Events
    event BuyPackage(uint256 idPackage, uint256 amountPackage, address buyer);

    constructor(address _tokenPayment , address _receivingAddress) {
        tokenPayment = IERC20(_tokenPayment);
        receivingAddress = _receivingAddress;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unPause() external onlyOwner {
        _unpause();
    }    

    function setPackage(
        uint256 _idPackage,
        uint256 _price,
        uint256 _tag
    ) external onlyOwner {
        packages[_idPackage] = PackageData(_idPackage, _price, _tag);
    }

    function buyPackage(uint256 _idPackage) external whenNotPaused {
        require(statusBuyPackage, "Buy package is not active");
        require(
            packages[_idPackage].idPackage != 0,
            "Package does not exist"
        );

        require(
            tokenPayment.balanceOf(msg.sender) >= packages[_idPackage].price,
            "You don't have enough tokens"
        );

        tokenPayment.transferFrom(
            msg.sender,
            address(this),
            packages[_idPackage].price
        );

        buyerPackage[msg.sender] = BuyerData(
            _idPackage,
            packages[_idPackage].price
        );

        emit BuyPackage(_idPackage, packages[_idPackage].price, msg.sender);
    }

    function withdrawTokens() external onlyOwner {
        tokenPayment.transfer(
            address(receivingAddress),
            tokenPayment.balanceOf(address(this))
        );
    }

    function setBuyPackageStatus(bool _status) external onlyOwner {
        statusBuyPackage = _status;
    }

    function setTokenPayment(address _tokenPayment) external onlyOwner {
        tokenPayment = IERC20(_tokenPayment);
    }

    function getPackage(uint256 _idPackage)
        external
        view
        returns (
            uint256 idPackage,
            uint256 price,
            uint256 tag
        )
    {
        return (
            packages[_idPackage].idPackage,
            packages[_idPackage].price,
            packages[_idPackage].tag
        );
    }

    function getBuyerPackage(address _buyer)
        external
        view
        returns (
            uint256 idPackage,
            uint256 price
        )
    {
        return (
            buyerPackage[_buyer].idPackage,
            buyerPackage[_buyer].price
        );
    }

}
