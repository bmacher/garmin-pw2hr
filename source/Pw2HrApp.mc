import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;

class Pw2HrApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Lang.Dictionary?) as Void {
        if (Storage.getValue("mode") == null) {
            Storage.setValue("mode", 0);
        }
        if (Storage.getValue("rollingDuration") == null) {
            Storage.setValue("rollingDuration", 30);
        }
        if (Storage.getValue("labelStyle") == null) {
            Storage.setValue("labelStyle", 0);
        }
    }

    // Called when settings are changed via Garmin Connect Mobile
    function onSettingsChanged() as Void {
        var mode = Application.Properties.getValue("mode");
        if (mode != null) {
            Storage.setValue("mode", mode);
        }
        var rollingDuration = Application.Properties.getValue("rollingDuration");
        if (rollingDuration != null) {
            Storage.setValue("rollingDuration", rollingDuration);
        }
        var labelStyle = Application.Properties.getValue("labelStyle");
        if (labelStyle != null) {
            Storage.setValue("labelStyle", labelStyle);
        }
    }

    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        return [new Pw2HrView()];
    }

    function getSettingsView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] or Null {
        return [new SettingsView(), new SettingsDelegate()];
    }
}
