import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application;
import Toybox.Lang;
import Toybox.Math;

class SettingsView extends WatchUi.View {

    // to store the coords and width/heigh of the button (for cadence for now) 
    private var _buttonCoords as Array<Number>?; 


    function initialize() {
        View.initialize();
        _buttonCoords = [0, 0, 0, 0] as Array<Number>;
    }
    
    
    function onLayout(dc as Dc) as Void {

        // Define button dimensions based on screen size (rough values for now)
        var screenWidth = dc.getWidth();
        var screenHeight = dc.getHeight();

        var x1 = screenWidth * 0.2;
        var y1 = screenHeight / 2;
        var width = screenWidth - (screenWidth * 0.4);
        var height = screenHeight / 3;

        // Sets button coords
        _buttonCoords = [x1, y1, width, height] as Array<Number>;
        System.println(x1.toString() + " and " + y1.toString() + " and " + width.toString() + " and " + height.toString());

    }

    function onShow() as Void {}

    function onUpdate(dc as Dc) as Void {

        View.onUpdate(dc);
        drawCadenceButton(dc);

    }
    
    // Draws the temp button
    function drawCadenceButton(dc as Dc) as Void {

        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLUE);
        dc.drawRoundedRectangle(_buttonCoords[0], _buttonCoords[1], _buttonCoords[2], _buttonCoords[3], 10);

    }

    // Public getter method for the button coordinates
    function getButtonCoords() as Array<Number> {
        return _buttonCoords;
    }

        function refreshScreen() as Void{
        WatchUi.requestUpdate();
    }
    
    function onHide() as Void {}
}