// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract ConsumerTreasuryV1 is UUPSUpgradeable {
    error NotTreasuryAdmin(address caller);

    address public treasuryAdmin;
    address public settlementOperator;
    uint256 public dailySettlementLimit;

    constructor() {
        _disableInitializers();
    }

    function initialize(address admin, address operator, uint256 limit) external initializer {
        require(admin != address(0), "Invalid admin");
        require(operator != address(0), "Invalid operator");
        require(admin != operator, "Roles must differ");

        __UUPSUpgradeable_init();

        treasuryAdmin = admin;
        settlementOperator = operator;
        dailySettlementLimit = limit;
    }

    function version() external pure virtual returns (uint256) {
        return 1;
    }

    function _authorizeUpgrade(address) internal view virtual override {
        if (msg.sender != treasuryAdmin) {
            revert NotTreasuryAdmin(msg.sender);
        }
    }
}

contract ConsumerTreasuryV2Safe is ConsumerTreasuryV1 {
    function version() external pure override returns (uint256) {
        return 2;
    }

    // NEGATIVE CONTROL ONLY: unauthorized upgrade permission.
    function _authorizeUpgrade(address) internal view override {
        if (msg.sender != treasuryAdmin && msg.sender != settlementOperator) {
            revert NotTreasuryAdmin(msg.sender);
        }
    }
}

contract ConsumerTreasuryV2Unsafe is ConsumerTreasuryV1 {
    function version() external pure override returns (uint256) {
        return 2;
    }

    // Deliberate regression: settlement operators
    // can now authorize implementation upgrades.
    function _authorizeUpgrade(address) internal view override {
        if (msg.sender != treasuryAdmin && msg.sender != settlementOperator) {
            revert NotTreasuryAdmin(msg.sender);
        }
    }
}

contract ConsumerTreasuryCandidate is ConsumerTreasuryV1 {
    function version() external pure override returns (uint256) {
        return 3;
    }
}
