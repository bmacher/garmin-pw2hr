import Toybox.Activity;
import Toybox.Application.Storage;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class Pw2HrView extends WatchUi.DataField {

    private const MODE_CURRENT = 0;
    private const MODE_WORKOUT_AVG = 1;
    private const MODE_LAP_AVG = 2;
    private const MODE_ROLLING_AVG = 3;

    private var _ratio as Float = 0.0f;
    private var _mode as Number = 0;
    private var _rollingDuration as Number = 30;
    private var _labelStyle as Number = 0; // 0=text, 1=icon

    // Rolling average buffer
    private var _powerBuffer as Array<Number?> = [];
    private var _hrBuffer as Array<Number?> = [];
    private var _bufferSize as Number = 30;

    // Lap accumulators
    private var _lapPowerSum as Float = 0.0f;
    private var _lapHrSum as Float = 0.0f;
    private var _lapSamples as Number = 0;

    function initialize() {
        DataField.initialize();
        loadSettings();
    }

    function loadSettings() as Void {
        _mode = (Storage.getValue("mode") as Number?) != null ? Storage.getValue("mode") as Number : 0;
        var dur = Storage.getValue("rollingDuration") as Number?;
        _rollingDuration = dur != null ? dur : 30;
        _labelStyle = (Storage.getValue("labelStyle") as Number?) != null ? Storage.getValue("labelStyle") as Number : 0;
        _bufferSize = _rollingDuration;
        _powerBuffer = new Array<Number?>[0];
        _hrBuffer = new Array<Number?>[0];
    }

    function onTimerLap() as Void {
        _lapPowerSum = 0.0f;
        _lapHrSum = 0.0f;
        _lapSamples = 0;
    }

    function compute(info as Activity.Info) as Void {
        // Reload settings in case they changed
        _mode = (Storage.getValue("mode") as Number?) != null ? Storage.getValue("mode") as Number : 0;
        _labelStyle = (Storage.getValue("labelStyle") as Number?) != null ? Storage.getValue("labelStyle") as Number : 0;
        if (_mode == MODE_ROLLING_AVG) {
            var newDuration = (Storage.getValue("rollingDuration") as Number?) != null ? Storage.getValue("rollingDuration") as Number : 30;
            if (newDuration != _rollingDuration) {
                _rollingDuration = newDuration;
                _bufferSize = _rollingDuration;
                _powerBuffer = new Array<Number?>[0];
                _hrBuffer = new Array<Number?>[0];
            }
        }

        var power = info.currentPower;
        var heartRate = info.currentHeartRate;

        switch (_mode) {
            case MODE_CURRENT:
                _ratio = Pw2HrCalc.computeRatio(power, heartRate);
                break;

            case MODE_WORKOUT_AVG:
                var avgPower = info.averagePower;
                var avgHr = info.averageHeartRate;
                _ratio = Pw2HrCalc.computeRatio(avgPower, avgHr);
                break;

            case MODE_LAP_AVG:
                if (power != null && heartRate != null && heartRate > 0) {
                    _lapPowerSum += power.toFloat();
                    _lapHrSum += heartRate.toFloat();
                    _lapSamples++;
                }
                _ratio = Pw2HrCalc.computeAccumulatedRatio(_lapPowerSum, _lapHrSum, _lapSamples);
                break;

            case MODE_ROLLING_AVG:
                _powerBuffer.add(power);
                _hrBuffer.add(heartRate);
                if (_powerBuffer.size() > _bufferSize) {
                    _powerBuffer = _powerBuffer.slice(1, null) as Array<Number?>;
                    _hrBuffer = _hrBuffer.slice(1, null) as Array<Number?>;
                }
                _ratio = Pw2HrCalc.computeRollingRatio(_powerBuffer, _hrBuffer);
                break;
        }
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var bgColor = getBackgroundColor();
        var fgColor = (bgColor == Graphics.COLOR_BLACK)
            ? Graphics.COLOR_WHITE
            : Graphics.COLOR_BLACK;

        dc.setColor(bgColor, bgColor);
        dc.clear();

        // Draw label
        var label = "";
        var useIcon = (_labelStyle == 1);

        if (useIcon) {
            // Icon mode: ♥ + mode suffix
            switch (_mode) {
                case MODE_WORKOUT_AVG:
                    label = "/ \u2665 \u00D8";
                    break;
                case MODE_LAP_AVG:
                    label = "/ \u2665 " + WatchUi.loadResource(Rez.Strings.labelLap);
                    break;
                case MODE_ROLLING_AVG:
                    label = "/ \u2665 " + _rollingDuration + "s";
                    break;
                default:
                    label = "/ \u2665";
                    break;
            }
        } else {
            // Text mode: PW/HR + mode suffix
            switch (_mode) {
                case MODE_WORKOUT_AVG:
                    label = "PW/HR \u00D8";
                    break;
                case MODE_LAP_AVG:
                    label = "PW/HR " + WatchUi.loadResource(Rez.Strings.labelLap);
                    break;
                case MODE_ROLLING_AVG:
                    label = "PW/HR " + _rollingDuration + "s";
                    break;
                default:
                    label = "PW/HR";
                    break;
            }
        }

        dc.setColor(fgColor, Graphics.COLOR_TRANSPARENT);

        if (useIcon) {
            // Measure text to position lightning bolt before it
            var labelWidth = dc.getTextWidthInPixels(label, Graphics.FONT_XTINY);
            var labelX = dc.getWidth() / 2;
            var labelStartX = labelX - labelWidth / 2;

            // Draw lightning bolt polygon
            var bx = labelStartX - 8;
            var by = 6;
            var pts = [[bx + 3, by], [bx + 1, by + 3], [bx + 3, by + 3],
                       [bx, by + 6], [bx + 4, by + 3], [bx + 2, by + 3],
                       [bx + 5, by]];
            dc.fillPolygon(pts as Lang.Array< Lang.Array >);

            dc.drawText(labelX, 5, Graphics.FONT_XTINY, label,
                Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.drawText(dc.getWidth() / 2, 5, Graphics.FONT_XTINY, label,
                Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Draw value
        var valueText = _ratio > 0.0f ? _ratio.format("%.2f") : "--";
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_LARGE, valueText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
