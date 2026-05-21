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

        var menu = new WatchUi.Menu2({:title => "Calculation Mode"});
        menu.addItem(new WatchUi.ToggleMenuItem("Current", null, 0, mode == 0, null));
        menu.addItem(new WatchUi.ToggleMenuItem("Workout Average", null, 1, mode == 1, null));
        menu.addItem(new WatchUi.ToggleMenuItem("Round Average", null, 2, mode == 2, null));
        menu.addItem(new WatchUi.ToggleMenuItem("Rolling Average", null, 3, mode == 3, null));

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
        if (id instanceof Number) {
            Storage.setValue("mode", id as Number);
        }
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
