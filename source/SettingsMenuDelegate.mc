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
        var mode = Storage.getValue("mode");
        if (mode == null) { mode = 0; }
        var labelStyle = Storage.getValue("labelStyle");
        if (labelStyle == null) { labelStyle = 0; }

        var menu = new WatchUi.Menu2({:title => "Settings"});
        menu.addItem(new WatchUi.ToggleMenuItem("Current", null, "mode_0", mode == 0, null));
        menu.addItem(new WatchUi.ToggleMenuItem("Workout Average", null, "mode_1", mode == 1, null));
        menu.addItem(new WatchUi.ToggleMenuItem("Round Average", null, "mode_2", mode == 2, null));
        menu.addItem(new WatchUi.ToggleMenuItem("Rolling Average", null, "mode_3", mode == 3, null));
        menu.addItem(new WatchUi.ToggleMenuItem("Label: Icon", null, "labelStyle", labelStyle == 1, null));

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
        if (id instanceof Lang.String) {
            var idStr = id as String;
            if (idStr.equals("labelStyle")) {
                var current = Storage.getValue("labelStyle");
                Storage.setValue("labelStyle", (current == 1) ? 0 : 1);
            } else if (idStr.substring(0, 5).equals("mode_")) {
                var modeNum = idStr.substring(5, 6).toNumber();
                if (modeNum != null) {
                    Storage.setValue("mode", modeNum);
                }
            }
        }
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
