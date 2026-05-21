import Toybox.Lang;
import Toybox.Test;

module Pw2HrCalcTest {

    // --- computeRatio ---

    (:test)
    function testComputeRatio_basic(logger as Test.Logger) as Boolean {
        // 200W / 100bpm = 2.0
        var result = Pw2HrCalc.computeRatio(200, 100);
        logger.debug("200/100 = " + result);
        Test.assertEqualMessage(result, 2.0f, "200W / 100bpm should be 2.0");
        return true;
    }

    (:test)
    function testComputeRatio_decimal(logger as Test.Logger) as Boolean {
        // 150W / 140bpm ≈ 1.07
        var result = Pw2HrCalc.computeRatio(150, 140);
        logger.debug("150/140 = " + result);
        Test.assert(result > 1.07f && result < 1.08f);
        return true;
    }

    (:test)
    function testComputeRatio_nullPower(logger as Test.Logger) as Boolean {
        var result = Pw2HrCalc.computeRatio(null, 100);
        Test.assertEqualMessage(result, 0.0f, "Null power should return 0");
        return true;
    }

    (:test)
    function testComputeRatio_nullHr(logger as Test.Logger) as Boolean {
        var result = Pw2HrCalc.computeRatio(200, null);
        Test.assertEqualMessage(result, 0.0f, "Null HR should return 0");
        return true;
    }

    (:test)
    function testComputeRatio_zeroHr(logger as Test.Logger) as Boolean {
        var result = Pw2HrCalc.computeRatio(200, 0);
        Test.assertEqualMessage(result, 0.0f, "Zero HR should return 0");
        return true;
    }

    (:test)
    function testComputeRatio_bothNull(logger as Test.Logger) as Boolean {
        var result = Pw2HrCalc.computeRatio(null, null);
        Test.assertEqualMessage(result, 0.0f, "Both null should return 0");
        return true;
    }

    // --- computeAccumulatedRatio ---

    (:test)
    function testAccumulatedRatio_basic(logger as Test.Logger) as Boolean {
        // avg power = 600/3 = 200, avg hr = 450/3 = 150 → 200/150 ≈ 1.33
        var result = Pw2HrCalc.computeAccumulatedRatio(600.0f, 450.0f, 3);
        logger.debug("accumulated = " + result);
        Test.assert(result > 1.33f && result < 1.34f);
        return true;
    }

    (:test)
    function testAccumulatedRatio_zeroSamples(logger as Test.Logger) as Boolean {
        var result = Pw2HrCalc.computeAccumulatedRatio(0.0f, 0.0f, 0);
        Test.assertEqualMessage(result, 0.0f, "Zero samples should return 0");
        return true;
    }

    (:test)
    function testAccumulatedRatio_zeroHrSum(logger as Test.Logger) as Boolean {
        var result = Pw2HrCalc.computeAccumulatedRatio(600.0f, 0.0f, 3);
        Test.assertEqualMessage(result, 0.0f, "Zero HR sum should return 0");
        return true;
    }

    // --- computeRollingRatio ---

    (:test)
    function testRollingRatio_basic(logger as Test.Logger) as Boolean {
        // [200, 250, 300] / [100, 125, 150] → avg 250/125 = 2.0
        var power = [200, 250, 300] as Array<Number?>;
        var hr = [100, 125, 150] as Array<Number?>;
        var result = Pw2HrCalc.computeRollingRatio(power, hr);
        logger.debug("rolling = " + result);
        Test.assertEqualMessage(result, 2.0f, "Rolling avg should be 2.0");
        return true;
    }

    (:test)
    function testRollingRatio_withNulls(logger as Test.Logger) as Boolean {
        // Null entries should be skipped
        var power = [200, null, 300] as Array<Number?>;
        var hr = [100, null, 150] as Array<Number?>;
        var result = Pw2HrCalc.computeRollingRatio(power, hr);
        logger.debug("rolling with nulls = " + result);
        // avg power = (200+300)/2 = 250, avg hr = (100+150)/2 = 125 → 2.0
        Test.assertEqualMessage(result, 2.0f, "Should skip nulls and return 2.0");
        return true;
    }

    (:test)
    function testRollingRatio_allNull(logger as Test.Logger) as Boolean {
        var power = [null, null] as Array<Number?>;
        var hr = [null, null] as Array<Number?>;
        var result = Pw2HrCalc.computeRollingRatio(power, hr);
        Test.assertEqualMessage(result, 0.0f, "All null should return 0");
        return true;
    }

    (:test)
    function testRollingRatio_empty(logger as Test.Logger) as Boolean {
        var power = [] as Array<Number?>;
        var hr = [] as Array<Number?>;
        var result = Pw2HrCalc.computeRollingRatio(power, hr);
        Test.assertEqualMessage(result, 0.0f, "Empty buffer should return 0");
        return true;
    }

    (:test)
    function testRollingRatio_zeroHr(logger as Test.Logger) as Boolean {
        var power = [200, 300] as Array<Number?>;
        var hr = [0, 0] as Array<Number?>;
        var result = Pw2HrCalc.computeRollingRatio(power, hr);
        Test.assertEqualMessage(result, 0.0f, "Zero HR should return 0");
        return true;
    }
}
