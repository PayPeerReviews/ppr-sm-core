// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IERC20Permit.sol";

contract ReviewPeer is AccessControl {

    /*
    * @dev Review structure
    */
    struct Review {
        address addr;
        uint256 starts; //change to the small number since here is only (1-5)
    }

    bytes32 public constant PEER_REVIEW = keccak256("PEER_REVIEW");
    
    mapping(address => bool) public allowedReviews;
    mapping(uint => Review) public reviews;
    uint256 public numReviews;
    uint256 public totalReviewScore;

    constructor(){
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function grantReview(address reviewerAddress) public returns(bool) {
        allowedReviews[reviewerAddress] = true;
        return true;
    }

    function sendReview(uint256 starts) public returns(bool) { // add here an isAllowed validation 
        require(starts > 0 && starts < 6, "not valid review");
        require(allowedReviews[msg.sender] == true, "not allowed to review");
        allowedReviews[msg.sender] = false;
        Review memory review = Review(msg.sender, starts);
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
}