import Toybox.Graphics;
import Toybox.WatchUi;

class PostFeedbackSettingsView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        var icon = WatchUi.loadResource(
            dc.getWidth() < 300
                ? Rez.Drawables.PostFeedbackIconCompact
                : Rez.Drawables.PostFeedbackIcon
        );
        SettingsCardRenderer.draw(dc, icon, "Post Feedback", "START to open");
    }
}
