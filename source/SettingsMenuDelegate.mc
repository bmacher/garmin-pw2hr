import Toybox.Application.Storage;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class SettingsView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 - 30,
            Graphics.FONT_SMALL, "Press Menu\nfor settings",
            Graphics.TEXT_JUSTIFY_CENTER);
    }
}

class SettingsDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        var menu = new WatchUi.Menu2({:title => "Settings"});
        menu.addItem(new WatchUi.MenuItem("Calculation Mode", null, "mode", null));
        menu.addItem(new WatchUi.MenuItem("Rolling Duration", null, "rollingDuration", null));
        menu.addItem(new WatchUi.MenuItem("Label Style", null, "labelStyle", null));

        WatchUi.pushView(menu, new SettingsMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}

class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(menuItem as WatchUi.MenuItem) as Void {
        var id = menuItem.getId();
        if (!(id instanceof Lang.String)) { return; }
        var idStr = id as String;

        if (idStr.equals("mode")) {
            var menu = new WatchUi.Menu2({:title => "Mode"});
            menu.addItem(new WatchUi.MenuItem("Current", null, "mode_0", null));
            menu.addItem(new WatchUi.MenuItem("Workout Average", null, "mode_1", null));
            menu.addItem(new WatchUi.MenuItem("Lap Average", null, "mode_2", null));
            menu.addItem(new WatchUi.MenuItem("Rolling Average", null, "mode_3", null));
            WatchUi.pushView(menu, new ModeMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
        } else if (idStr.equals("rollingDuration")) {
            var menu = new WatchUi.Menu2({:title => "Rolling Duration"});
            menu.addItem(new WatchUi.MenuItem("10s", null, "dur_10", null));
            menu.addItem(new WatchUi.MenuItem("30s", null, "dur_30", null));
            menu.addItem(new WatchUi.MenuItem("60s", null, "dur_60", null));
            menu.addItem(new WatchUi.MenuItem("120s", null, "dur_120", null));
            menu.addItem(new WatchUi.MenuItem("300s", null, "dur_300", null));
            WatchUi.pushView(menu, new DurationMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
        } else if (idStr.equals("labelStyle")) {
            var menu = new WatchUi.Menu2({:title => "Label Style"});
            menu.addItem(new WatchUi.MenuItem("Text (PW/HR)", null, "label_0", null));
            menu.addItem(new WatchUi.MenuItem("Icon", null, "label_1", null));
            WatchUi.pushView(menu, new LabelMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
        }
    }
}

class ModeMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() { Menu2InputDelegate.initialize(); }

    function onSelect(menuItem as WatchUi.MenuItem) as Void {
        var id = menuItem.getId();
        if (id instanceof Lang.String) {
            var idStr = id as String;
            if (idStr.substring(0, 5).equals("mode_")) {
                var modeNum = idStr.substring(5, 6).toNumber();
                if (modeNum != null) {
                    Storage.setValue("mode", modeNum);
                }
            }
        }
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}

class DurationMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() { Menu2InputDelegate.initialize(); }

    function onSelect(menuItem as WatchUi.MenuItem) as Void {
        var id = menuItem.getId();
        if (id instanceof Lang.String) {
            var idStr = id as String;
            if (idStr.substring(0, 4).equals("dur_")) {
                var dur = idStr.substring(4, idStr.length()).toNumber();
                if (dur != null) {
                    Storage.setValue("rollingDuration", dur);
                }
            }
        }
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}

class LabelMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() { Menu2InputDelegate.initialize(); }

    function onSelect(menuItem as WatchUi.MenuItem) as Void {
        var id = menuItem.getId();
        if (id instanceof Lang.String) {
            var idStr = id as String;
            if (idStr.equals("label_0")) {
                Storage.setValue("labelStyle", 0);
            } else if (idStr.equals("label_1")) {
                Storage.setValue("labelStyle", 1);
            }
        }
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
