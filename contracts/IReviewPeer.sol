// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IReviewPeer {

    function grantReview(address reviewerAddress) external returns(bool);

}