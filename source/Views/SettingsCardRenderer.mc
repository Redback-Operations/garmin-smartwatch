import Toybox.Graphics;
import Toybox.Lang;

module SettingsCardRenderer {

    function draw(dc as Dc, icon, title as String, subtitle as String) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var compact = width < 300;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        if (icon != null) {
            dc.drawBitmap(
                centerX - (icon.getWidth() / 2),
                (height * 0.22).toNumber(),
                icon
            );
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (height * 0.57).toNumber(),
            compact ? Graphics.FONT_SMALL : Graphics.FONT_MEDIUM,
            title,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        if (subtitle.length() > 0) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                centerX,
                (height * 0.72).toNumber(),
                Graphics.FONT_XTINY,
                subtitle,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        }
    }
}
