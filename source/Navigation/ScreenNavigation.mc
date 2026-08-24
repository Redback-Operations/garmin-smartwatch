import Toybox.System;
import Toybox.WatchUi;
import Toybox.Lang;

// Centralizes page-loop ordering and transition direction. Garmin maps the
// next-page behavior to DOWN / swipe UP and the previous-page behavior to
// UP / swipe DOWN.
module ScreenNavigation {
    const HOME_SIMPLE = :simple_home;
    const HOME_TIME = :time_home;

    const SETTINGS_ROOT = :settings_root;
    const SETTINGS_CADENCE = :settings_cadence;
    const SETTINGS_BAR_CHART = :settings_bar_chart;
    const SETTINGS_SUMMARY = :settings_summary;
    const SETTINGS_RESET = :settings_reset;

    function showAdvanced(homePage, isNext as Boolean) as Void {
        var view = new AdvancedView();
        var transition = isNext ? WatchUi.SLIDE_UP : WatchUi.SLIDE_DOWN;

        logNavigation(isNext, getHomeLabel(homePage), "advanced");
        WatchUi.switchToView(
            view,
            new AdvancedViewDelegate(view, homePage),
            transition
        );
    }

    function showHome(homePage, isNext as Boolean) as Void {
        var transition = isNext ? WatchUi.SLIDE_UP : WatchUi.SLIDE_DOWN;
        var homeLabel = getHomeLabel(homePage);

        logNavigation(isNext, "advanced", homeLabel);

        if (homePage == HOME_TIME) {
            WatchUi.switchToView(
                new TimeView(),
                new TimeViewDelegate(),
                transition
            );
            return;
        }

        WatchUi.switchToView(
            new SimpleView(),
            new SimpleViewDelegate(),
            transition
        );
    }

    function showNextSettingsPage(currentPage) as Void {
        showSettingsPage(currentPage, getNextSettingsPage(currentPage), true);
    }

    function showPreviousSettingsPage(currentPage) as Void {
        showSettingsPage(currentPage, getPreviousSettingsPage(currentPage), false);
    }

    private function getNextSettingsPage(currentPage) {
        if (currentPage == SETTINGS_ROOT) { return SETTINGS_CADENCE; }
        if (currentPage == SETTINGS_CADENCE) { return SETTINGS_BAR_CHART; }
        if (currentPage == SETTINGS_BAR_CHART) { return SETTINGS_SUMMARY; }
        if (currentPage == SETTINGS_SUMMARY) { return SETTINGS_RESET; }
        return SETTINGS_ROOT;
    }

    private function getPreviousSettingsPage(currentPage) {
        if (currentPage == SETTINGS_ROOT) { return SETTINGS_RESET; }
        if (currentPage == SETTINGS_CADENCE) { return SETTINGS_ROOT; }
        if (currentPage == SETTINGS_BAR_CHART) { return SETTINGS_CADENCE; }
        if (currentPage == SETTINGS_SUMMARY) { return SETTINGS_BAR_CHART; }
        return SETTINGS_SUMMARY;
    }

    private function showSettingsPage(currentPage, targetPage, isNext as Boolean) as Void {
        var transition = isNext ? WatchUi.SLIDE_UP : WatchUi.SLIDE_DOWN;

        logNavigation(
            isNext,
            getSettingsLabel(currentPage),
            getSettingsLabel(targetPage)
        );

        if (targetPage == SETTINGS_ROOT) {
            WatchUi.switchToView(
                new SettingsView(),
                new SettingsMenuDelegate(),
                transition
            );
        } else if (targetPage == SETTINGS_CADENCE) {
            WatchUi.switchToView(
                new CadenceSettingsMenuView(),
                new CadenceSettingsMenuDelegate(),
                transition
            );
        } else if (targetPage == SETTINGS_BAR_CHART) {
            WatchUi.switchToView(
                new BarChartSettingsMenuView(),
                new BarChartSettingsMenuDelegate(),
                transition
            );
        } else if (targetPage == SETTINGS_SUMMARY) {
            WatchUi.switchToView(
                new SummarySettingsMenuView(),
                new SummarySettingsMenuDelegate(),
                transition
            );
        } else {
            var view = new ResetSettingsView();
            WatchUi.switchToView(
                view,
                new ResetSettingsDelegate(view),
                transition
            );
        }
    }

    private function getHomeLabel(homePage) as String {
        return homePage == HOME_TIME ? "time" : "simple";
    }

    private function getSettingsLabel(page) as String {
        if (page == SETTINGS_ROOT) { return "settings"; }
        if (page == SETTINGS_CADENCE) { return "cadence"; }
        if (page == SETTINGS_BAR_CHART) { return "bar_chart"; }
        if (page == SETTINGS_SUMMARY) { return "summary"; }
        return "reset";
    }

    private function logNavigation(isNext as Boolean, fromPage as String, toPage as String) as Void {
        var direction = isNext ? "DOWN" : "UP";
        System.println(
            "[NAV] direction=" + direction +
            " from=" + fromPage +
            " to=" + toPage
        );
    }
}
