// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";

import "./interfaces/Idle/IIdleTokenV3_1.sol";

contract IdleTokenHelper {
    using SafeMath for uint256;

    uint256 constant public FULL_ALLOC = 100000;

    function getMintingPrice(address idleYieldToken) view external returns (uint256 mintingPrice) {
        return _getMintingPrice(idleYieldToken);
    }

    function _getMintingPrice(address idleYieldToken) view internal returns (uint256 mintingPrice) {
        return IIdleTokenV3_1(idleYieldToken).tokenPrice();
    }

    function getRedeemPrice(address idleYieldToken) view external returns (uint256 redeemPrice) {
        return _getRedeemPrice(idleYieldToken, msg.sender);
    }

    function getRedeemPrice(address idleYieldToken, address user) view external returns (uint256 redeemPrice) {
        return _getRedeemPrice(idleYieldToken, user);
    }

    function _getRedeemPrice(address idleYieldToken, address user) view internal returns (uint256 redeemPrice) {
        /*
         *  As per https://github.com/Idle-Labs/idle-contracts/blob/ad0f18fef670ea6a4030fe600f64ece3d3ac2202/contracts/IdleTokenGovernance.sol#L878-L900
         *
         *  Price on minting is currentPrice
         *  Price on redeem must consider the fee
         *
         *  Below the implementation of the following redeemPrice formula
         *
         *  redeemPrice := underlyingAmount/idleTokenAmount
         *
         *  redeemPrice = currentPrice * (1 - scaledFee * ΔP%)
         *
         *  where:
         *  - scaledFee   := fee/FULL_ALLOC
         *  - ΔP% := 0 when currentPrice < userAvgPrice (no gain) and (currentPrice-userAvgPrice)/currentPrice
         *
         *  n.b: gain := idleTokenAmount * ΔP% * currentPrice
         */

        IIdleTokenV3_1 iyt = IIdleTokenV3_1(idleYieldToken);

        uint256 userAvgPrice = iyt.userAvgPrices(user);
        uint256 currentPrice = iyt.tokenPrice();

        // When no deposits userAvgPrice is 0 equiv currentPrice
        // and in the case of issues
        if (userAvgPrice == 0 || currentPrice < userAvgPrice) {
            redeemPrice = currentPrice;
        } else {
            uint256 fee = iyt.fee();

            redeemPrice = ((currentPrice.mul(FULL_ALLOC))
                .sub(
                    fee.mul(
                         currentPrice.sub(userAvgPrice)
                    )
                )).div(FULL_ALLOC);
        }

        return redeemPrice;
    }
}