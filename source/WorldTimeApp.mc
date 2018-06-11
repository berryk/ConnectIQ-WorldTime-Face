using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class WorldTimeApp extends App.AppBase {

    var face;

    function initialize() {
        AppBase.initialize();
    }

    //! onStart() is called on application start up
    function onStart(state) {
    }

    //! onStop() is called when your application is exiting
    function onStop(state) {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        face = new WorldTimeView(); 
	return [ face ];
    }

    function onSettingsChanged() {
    	face.settingsChanged();
        Ui.requestUpdate();
    }

}
