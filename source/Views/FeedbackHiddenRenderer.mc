import Toybox.Graphics;

module FeedbackHiddenRenderer {

    function draw(dc as Dc, app as GarminApp) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;

        // This renderer is used only for the four-second transition notice.
        // Its callers return to the main dashboard when the notice expires.
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        if (!app.shouldShowFeedbackHiddenNotice()) {
            return;
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (height * 0.36).toNumber(),
            Graphics.FONT_MEDIUM,
            "FEEDBACK",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            centerX,
            (height * 0.48).toNumber(),
            Graphics.FONT_MEDIUM,
            "HIDDEN",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (height * 0.61).toNumber(),
            Graphics.FONT_XTINY,
            "Cadence is still recording",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        var activeDots = (app.getFeedbackActiveSeconds() % 3) + 1;
        var dotRadius = (width * 0.012).toNumber();
        if (dotRadius < 2) { dotRadius = 2; }
        var dotGap = (width * 0.075).toNumber();
        var firstDotX = centerX - dotGap;
        var dotY = (height * 0.72).toNumber();

        for (var i = 0; i < 3; i++) {
            dc.setColor(
                i < activeDots ? Graphics.COLOR_GREEN : Graphics.COLOR_DK_GRAY,
                Graphics.COLOR_TRANSPARENT
            );
            dc.fillCircle(firstDotX + (i * dotGap), dotY, dotRadius);
        }
    }
}
