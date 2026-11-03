// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ComparativeAuthorityProbe} from "protocol-sentinel/ComparativeAuthorityProbe.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {
    ConsumerTreasuryV1,
    ConsumerTreasuryV2Safe,
    ConsumerTreasuryV2Unsafe,
    ConsumerTreasuryCandidate
} from "../src/ConsumerTreasury.sol";

contract TreasuryAuthorityTest is ComparativeAuthorityProbe {
    address internal administrator;
    address internal settlementOperator;

    ERC1967Proxy internal treasuryProxy;

    function setUp() public {
        administrator = makeAddr("treasury-administrator");
        settlementOperator = makeAddr("settlement-operator");

        ConsumerTreasuryV1 initial = new ConsumerTreasuryV1();

        bytes memory initialization =
            abi.encodeCall(ConsumerTreasuryV1.initialize, (administrator, settlementOperator, 100 ether));

        treasuryProxy = new ERC1967Proxy(address(initial), initialization);
    }

    function _activeImplementation() internal view returns (address) {
        return address(uint160(uint256(vm.load(address(treasuryProxy), ERC1967_IMPL_SLOT))));
    }

    function _observe(UpgradeCheck memory spec) internal returns (DirectStage memory stage) {
        address active = _activeImplementation();

        bytes memory callData = abi.encodeWithSignature("upgradeToAndCall(address,bytes)", spec.candidate, bytes(""));

        Observation memory observation = _observeIsolatedCall(spec.actor, spec.target, callData, ERC1967_IMPL_SLOT);

        stage = DirectStage({expectedActiveImplementation: active, observation: observation});

        assertEq(_activeImplementation(), active, "Sentinel must restore implementation");
    }

    function _compareAgainst(address nextImplementation) internal returns (DirectComparisonResult memory result) {
        ConsumerTreasuryCandidate candidate = new ConsumerTreasuryCandidate();

        UpgradeCheck memory spec = UpgradeCheck({
            actor: settlementOperator,
            target: address(treasuryProxy),
            candidate: address(candidate),
            expectedRevert: abi.encodeWithSelector(ConsumerTreasuryV1.NotTreasuryAdmin.selector, settlementOperator),
            policy: UpgradePolicy.NO_IMPLEMENTATION_REPLACEMENT
        });

        DirectStage memory beforeStage = _observe(spec);

        vm.prank(administrator, administrator);

        ConsumerTreasuryV1(address(treasuryProxy)).upgradeToAndCall(nextImplementation, bytes(""));

        DirectStage memory afterStage = _observe(spec);

        result = _compareDirectUpgrade(keccak256("external-treasury-upgrade-authority"), spec, beforeStage, afterStage);
    }

    function test_SafeUpgradePreservesRestriction() public {
        ConsumerTreasuryV2Safe next = new ConsumerTreasuryV2Safe();

        DirectComparisonResult memory result = _compareAgainst(address(next));

        assertEq(uint256(result.beforeEvaluation.status), uint256(PolicyStatus.PASS));

        assertEq(uint256(result.afterEvaluation.status), uint256(PolicyStatus.PASS));

        assertEq(uint256(result.verdict), uint256(ComparisonVerdict.STILL_SATISFIED));
    }

    function test_UnsafeUpgradeIntroducesViolation() public {
        ConsumerTreasuryV2Unsafe next = new ConsumerTreasuryV2Unsafe();

        DirectComparisonResult memory result = _compareAgainst(address(next));

        assertEq(uint256(result.beforeEvaluation.status), uint256(PolicyStatus.PASS));

        assertEq(uint256(result.afterEvaluation.status), uint256(PolicyStatus.FAIL));

        assertEq(uint256(result.verdict), uint256(ComparisonVerdict.CHANGED_TO_VIOLATION));
    }
}
