// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@opengsn/contracts/src/ERC2771Recipient.sol";
import "./IERC20Permit.sol";

contract ReviewPeer is AccessControl, ERC2771Recipient {

    /*
    * @dev Review structure
    */
    struct Review {
        address addr;
        uint256 starts; //change to the small number since here is only (1-5)
    }

    bytes32 public constant GRANT_REVIEW_ROLE = keccak256("GRANT_REVIEW_ROLE");

    mapping(address => bool) public allowedReviews;
    mapping(uint => Review) public reviews;
    uint256 public numReviews;
    uint256 public totalReviewScore;

    constructor(address trustedForwarder){
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setTrustedForwarder(trustedForwarder);
    }

    function grantReview(address reviewerAddress) public returns(bool) { // add here an isAllowed validation 
        allowedReviews[reviewerAddress] = true;
        return true;
    }

    function sendReview(uint256 starts) public returns(bool) { 
        require(starts > 0 && starts < 6, "not valid review");
        require(allowedReviews[_msgSender()] == true, "not allowed to review");
        allowedReviews[_msgSender()] = false;
        Review memory review = Review(_msgSender(), starts);
        reviews[numReviews] = review;
        numReviews++;
        totalReviewScore = totalReviewScore + starts;
        return true;
    }

    function averageScore() public view returns(uint256) {
        if (numReviews == 0) {
            return 0;
        }
        return totalReviewScore / numReviews;
    }

    function getReview(uint key) public view returns (address, uint256) {
        Review memory review = reviews[key];
        return (
            review.addr,
            review.starts
        );
    }

    function getAllReviews() public view returns (Review[] memory) {
        Review[] memory rvs = new Review[](numReviews);
        for (uint256 i = 0; i < numReviews; i++) {
            rvs[i] = reviews[i];
        }
        return rvs;
    }
    
    function _msgData() internal view override(ERC2771Recipient, Context) returns (bytes calldata) {
        if (msg.sender == getTrustedForwarder()) {
            return ERC2771Recipient._msgData();
        } else {
            return super._msgData();
        }
    }

    function _msgSender() internal view override(ERC2771Recipient, Context) returns (address) {
        if (msg.sender == getTrustedForwarder()) {
            return ERC2771Recipient._msgSender();
        } else {
            return super._msgSender();
        }
    }
}