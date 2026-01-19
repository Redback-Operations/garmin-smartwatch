using Toybox.WatchUi as WatchUi;
using Toybox.Graphics as Gfx;

class HomeScreenView extends WatchUi.View {

    // Demo values (replace later)
    var timeStr  = "05:06.77";
    var distStr  = "12.02 KM";
    var spmStr   = "166 spm";
    var elevStr  = "1.35 M";
    var hrStr    = "143 HRM";

    const ICON_SIZE = 32;
    const ICON_GAP  = 10;

    // Icons (keep INSIDE the class)
    var iconDistance as WatchUi.BitmapResource;
    var iconCadence  as WatchUi.BitmapResource;
    var iconStride   as WatchUi.BitmapResource;
    var iconHr       as WatchUi.BitmapResource;

    function initialize() {
        View.initialize();

        // NOTE: because icons are in resources/drawables/
        iconDistance = WatchUi.loadResource(Rez.Drawables.ICON_DISTANCE);
        iconCadence  = WatchUi.loadResource(Rez.Drawables.ICON_CADENCE);
        iconStride   = WatchUi.loadResource(Rez.Drawables.ICON_STRIDE);
        iconHr       = WatchUi.loadResource(Rez.Drawables.ICON_HR);
    }

    function onUpdate(dc as Gfx.Dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();

        // Background
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();

        // Time
        dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_BLACK);
        dc.drawText(w/2, h*0.17, Gfx.FONT_LARGE, timeStr, Gfx.TEXT_JUSTIFY_CENTER);

        // Values
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        var valueFont = Gfx.FONT_TINY;

        var iconX = w * 0.30;
        var textX = w * 0.45;

        var startY = h * 0.34;
        var gapY   = h * 0.12;

        drawRow(dc, iconDistance, distStr, iconX, textX, startY + gapY*0, valueFont);
        drawRow(dc, iconCadence,  spmStr,  iconX, textX, startY + gapY*1, valueFont);
        drawRow(dc, iconStride,   elevStr, iconX, textX, startY + gapY*2, valueFont);
        drawRow(dc, iconHr,       hrStr,   iconX, textX, startY + gapY*3, valueFont);
    }

    function drawRow(dc as Gfx.Dc,
                     icon as WatchUi.BitmapResource,
                     value ,
                     iconX ,
                     textX ,
                     y ,
                     font ) {

        var iconY = y - (ICON_SIZE / 2)+20;
        if (iconY < 0) { iconY = 0; }

        dc.drawBitmap(iconX, iconY, icon);
        dc.drawText(textX, y, font, value, Gfx.TEXT_JUSTIFY_LEFT);
    }
}
