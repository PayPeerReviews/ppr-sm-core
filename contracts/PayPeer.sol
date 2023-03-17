// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IERC20Permit.sol";
import "./IReviewPeer.sol";

contract PayPeer is AccessControl {

    event Paid(address indexed sender, address indexed receiver, uint256 amount, address indexed token, uint256 serviceFee);
    event Withdraw(address indexed receiver, address indexed token, uint256 amount);

    IReviewPeer reviewPeer;

    constructor(address reviewPeerAddress) {
        reviewPeer = IReviewPeer(reviewPeerAddress);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function pay(address payable to, address tokenAddress, uint256 amountToPay) public {
        require((amountToPay / 10000) * 10000 == amountToPay, 'too small amount');
         _calculateFeesAndTransfer(tokenAddress, to, amountToPay);
         _grantReviewRights();
    }

    function payWithPermit(address payable to, address tokenAddress, uint256 amountToPay, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        require((amountToPay / 10000) * 10000 == amountToPay, 'too small amount');
        IERC20Permit(tokenAddress).permit(msg.sender, address(this), amountToPay, deadline, v, r, s);
        _calculateFeesAndTransfer(tokenAddress, to, amountToPay);
        _grantReviewRights();
    }

    function _calculateFeesAndTransfer(address _ERC20tokenAddress, address _to, uint256 _amount) internal virtual  {
        IERC20 token = IERC20(_ERC20tokenAddress);
        uint256 serviceFee = _amount * 10 / 10000;
        uint256 amount = _amount - serviceFee;
        token.transferFrom(msg.sender, _to, amount);
        token.transferFrom(msg.sender, address(this), serviceFee);
        emit Paid(msg.sender, _to, amount, _ERC20tokenAddress, serviceFee);
    }

    function _grantReviewRights() internal virtual {
        require(reviewPeer.grantReview(msg.sender));
    }

}