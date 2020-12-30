<h1 align=center><code>Idle Token Helper</code></h1>

**Idle Token Helper** is a collection of smart contracts to simplify interaction with Idle Protocol.

## How it works

Idle Protocol has fees on yield you get which are collected during redeem.
You can abstract this concept considering two prices during minting and redeeming, respectively `mintingPrice` and `redeemPrice`.

IdleTokenHelper facilitates your day implementing the formula for `redeemPrice`.

## Usage

You just need to call `getMintingPrice(address idleYieldToken)` to get minting price and `getRedeemPrice(address idleYieldToken, address user)` for redeemPrice.

For both, you need to pass the address of the IdleToken you are considering. For redeem, you have to provide the address which holds the tokens because the formula leverages the `avgUserPrice`. 
Technically, it keeps track of the weighted average of the token minted by the specific address, to calculate the yield needed for applying the fees on top.

You can version I deployed for you at [0x925cE5484c49f1E1f14B6ac61B42397dE8264Eb0](https://etherscan.io/address/0x925cE5484c49f1E1f14B6ac61B42397dE8264Eb0) or embed in your contracts. 

The latter could be more expensive at deploy time but cheaper at runtime, remember to use the internal methods (i.e. `_getMintingPrice(address idleYieldToken)` and `_getRedeemPrice(address idleYieldToken, address user)`).

Below an example

```
import "@emilianobonassi/idle-token-helper/IdleTokenHelper.sol";

contract MyContract is IdleTokenHelper {

...

function myMintMethod()
    external
    returns (bool) {
        ...
        uint256 mintingPrice = _getMintingPrice(idleYieldToken);
        ...
    }
...

function myRedeemMethod()
    external
    returns (bool) {
        ...
        uint256 redeemPrice = _getRedeemPrice(idleYieldToken, address(this));
        ...
    }
...

}
```
