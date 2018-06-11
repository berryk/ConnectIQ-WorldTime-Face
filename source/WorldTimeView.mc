using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;
using Toybox.Application as Application; 

class WorldTimeView extends Ui.View {

	var utcOffset = new Time.Duration(-Sys.getClockTime().timeZoneOffset);
	
	var tzLocations = [];
	var UTC_Offsets = {};
	
    var faceWidth;
    var faceHeight;
    var moveBarColors;
    var textSize;
    var textHeight;
    var textWidth;
    var smallFont;
    var largeFont;
    var tzFont;
    var tinyFont;
    
    function initialize() {
        var timezoneSetting = Application.getApp().getProperty("timezones");
        for (var i = 1; i <= timezoneSetting; i++) {
		var name = Application.getApp().getProperty("tz"+i+"_name");
		var offset = Application.getApp().getProperty("tz"+i+"_offset");
		var dst = Application.getApp().getProperty("tz"+i+"_dst");
		if (name.equals("")) {
			continue;
		} else {
			tzLocations.add(name);
		        System.println("Name:<"+name+">");	
			if (dst == true ) {
				offset = offset+1;
			}
			UTC_Offsets.put(name,offset);
		}
	}

        View.initialize();
    } 
						
    //! Load your resources here
    function onLayout(dc) {
        
        smallFont = Gfx.FONT_XTINY;
        
        tinyFont = Gfx.FONT_XTINY;
	largeFont = Gfx.FONT_NUMBER_HOT;
        tzFont = Gfx.FONT_MEDIUM;
        faceWidth = dc.getWidth();
        faceHeight = dc.getHeight();
        textSize = dc.getTextDimensions("MLB:20", tzFont);
        textHeight = textSize[1];
        textWidth = textSize[0];
        
    }

    //! Restore the state of the app and prepare the view to be shown
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
    
        var clockTime = Sys.getClockTime();
        var now = Time.now();
        // Set background color
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
	//dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
        dc.clear();
        
        // Get the local time
        var localTime = Lang.format("$1$:$2$", [clockTime.hour.format("%02d"), clockTime.min.format("%02d")]);
        var localTimeSize = dc.getTextDimensions(localTime, largeFont);        
        dc.drawText((faceWidth/2), (faceHeight/2)-(localTimeSize[1]/2), largeFont, localTime, Gfx.TEXT_JUSTIFY_CENTER);
        
        // Get date
        var info = Calendar.info(Time.now(), Time.FORMAT_LONG);
	var dateStr = Lang.format("$1$ $2$ $3$\n", [info.day_of_week.substring(0, 3), info.day.format("%02d"), info.month ]);

        var battSize = dc.getTextDimensions("50%",tinyFont); 
        dc.drawText((faceWidth/2), battSize[1]*1, smallFont, dateStr, Gfx.TEXT_JUSTIFY_CENTER);
		
	//Get UTC Time
	var utcNow = now.add(utcOffset);
        var utcInfo = Calendar.info(utcNow, Time.FORMAT_SHORT);
        var utcTime = Lang.format("UTC time:$1$:$2$\n", [utcInfo.hour.format("%02d"), utcInfo.min.format("%02d")]);
        
        var tzString="";
        var row = 0;
        var zones = tzLocations.size();
	
	if (zones > 4) {
		tzFont = Gfx.FONT_SMALL; 
	} else {
		tzFont = Gfx.FONT_MEDIUM;
	}
 
        var xGap = ((faceWidth - (zones/2)*textWidth)/((zones/2)+1))+0.5*textWidth ;
        var xPosn = 0; 
        var tzPosn = battSize[1]*2;
        var y = tzPosn;
        
        for (var i = 0; i < zones; ++i) {
        	
        	
     		var location = tzLocations[i];
		var tzOffset = UTC_Offsets[location];
		var tzHour = utcInfo.hour + tzOffset;
		if (tzHour > 23){
			tzHour = tzHour - 24; 
		}
		if (tzHour < 0){
			tzHour = tzHour + 24;
		}
			
		tzString = location + ":" + tzHour.format("%02d");
			
		xPosn = xPosn + xGap; 
		dc.drawText(xPosn, y, tzFont, tzString, Gfx.TEXT_JUSTIFY_CENTER);
		xPosn = xPosn + 0.5*textWidth; 
			
		if( i==((zones/2)-1)){ 
			xPosn = 0;
			y = faceHeight - textHeight - tzPosn; 
		}
	}
		
	var activityInfo = ActivityMonitor.getInfo();
        if(activityInfo.stepGoal == 0)
        {
            activityInfo.stepGoal = 5000;
        }

        var goal = activityInfo.stepGoal;
        var steps = activityInfo.steps;
        
        var stepsString = Lang.format("$1$/$2$", [steps, goal]);
        dc.drawText(faceWidth/2, faceHeight - (battSize[1]*2), smallFont, stepsString, Gfx.TEXT_JUSTIFY_CENTER);

        var x = faceWidth / 2;

	var narrow = 80;

        var settings = Sys.getDeviceSettings();

        if (PhoneConnected.isConnected()) {
            PhoneConnected.drawIcon(dc, narrow+1, 12, Gfx.COLOR_WHITE);
        }

        var stats = Sys.getSystemStats();
        var batteryString = Lang.format("$1$%",[stats.battery.format("%d")]);
        dc.drawText(faceWidth-1-narrow, 0, tinyFont, batteryString, Gfx.TEXT_JUSTIFY_RIGHT);
    }


    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

    function settingsChanged() {

        tzLocations = [];
	UTC_Offsets = {};
        var timezoneSetting = Application.getApp().getProperty("timezones");
        for (var i = 1; i <= timezoneSetting; i++) {
		var name = Application.getApp().getProperty("tz"+i+"_name");
		var offset = Application.getApp().getProperty("tz"+i+"_offset");
		var dst = Application.getApp().getProperty("tz"+i+"_dst");
		if (name.equals("")) {
			continue;
		} else {
			tzLocations.add(name);
		        System.println("Name:<"+name+">");	
			if (dst == true ) {
				offset = offset+1;
			}
			UTC_Offsets.put(name,offset);
		}
	}
    } 
						
}
