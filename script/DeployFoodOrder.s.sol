//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FoodOrder} from "../src/FoodOrder.sol";

contract DeployFoodOrder is Script {
    function run() external returns (FoodOrder) {
        vm.startBroadcast();
        FoodOrder deployFood = new FoodOrder();
        vm.stopBroadcast();

        return deployFood;
    }
}
