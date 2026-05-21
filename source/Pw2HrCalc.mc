import Toybox.Lang;

module Pw2HrCalc {

    // Calculate power-to-heart-rate ratio
    function computeRatio(power as Number?, heartRate as Number?) as Float {
        if (power != null && heartRate != null && heartRate > 0) {
            return power.toFloat() / heartRate.toFloat();
        }
        return 0.0f;
    }

    // Calculate ratio from rolling buffer averages
    function computeRollingRatio(powerBuffer as Array<Number?>, hrBuffer as Array<Number?>) as Float {
        var sumPower = 0.0f;
        var sumHr = 0.0f;
        var count = 0;
        for (var i = 0; i < powerBuffer.size(); i++) {
            var p = powerBuffer[i];
            var h = hrBuffer[i];
            if (p != null && h != null && h > 0) {
                sumPower += p.toFloat();
                sumHr += h.toFloat();
                count++;
            }
        }
        if (count > 0 && sumHr > 0.0f) {
            return (sumPower / count) / (sumHr / count);
        }
        return 0.0f;
    }

    // Calculate ratio from accumulated sums
    function computeAccumulatedRatio(powerSum as Float, hrSum as Float, samples as Number) as Float {
        if (samples > 0 && hrSum > 0.0f) {
            return (powerSum / samples) / (hrSum / samples);
        }
        return 0.0f;
    }
}
