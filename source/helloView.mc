using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;

class helloView extends Ui.View {

	var utcOffset = new Time.Duration(-Sys.getClockTime().timeZoneOffset);
	
	var DST = { "Aust" => 0, "USA" => 1, "EMEA" => 1, "China" => 0 };
	
	var Countries = { 	"MLB" => "Aust", 
						"HKG" => "China",
						"LON" => "EMEA",
						"NYC" => "USA",
						"OMA" => "USA",
						"SFO" => "USA" }; 
						
	
	var UTC_Offsets = {	"MLB" => 10, 
						"HKG" => 8,
						"LON" => 0,
						"NYC" => -5,
						"OMA" => -6,
						"SFO" => -8 };
						
	//var tzLocations = [ "LON", "HKG", "MLB", "SFO", "OMA", "NYC"];
	var tzLocations = [ "LON", "HKG", "SFO", "NYC"];
	
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
        var xGap = ((faceWidth - (zones/2)*textWidth)/((zones/2)+1))+0.5*textWidth ;
        var xPosn = 0; 
        var tzPosn = battSize[1]*2;
        var y = tzPosn;
        
        for (var i = 0; i < zones; ++i) {
        	
        	
     		var location = tzLocations[i];
        	// Look up the country for the tz
		var tzCountry = Countries[location]; 
		// Is the country in DST
		var tzDST = DST[tzCountry];
		// What is the UTC Offset
		var tzOffset = UTC_Offsets[location];
		var tzHour = utcInfo.hour + tzDST + tzOffset;
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
        
        //var distanceInMiles = activityInfo.distance.toFloat() / 160934;
        //var milesString = Lang.format("$1$mi",[distanceInMiles.format("%.02f")]);
        //dc.drawText(0, faceHeight - textHeight, smallFont, milesString, Gfx.TEXT_JUSTIFY_LEFT);

        var x = faceWidth / 2;
        //var y = dc.getHeight() / 3;
        //var x=0;

	var narrow = 80;

        var settings = Sys.getDeviceSettings();
        if(settings.phoneConnected)
	{
 		//dc.drawBitmap(14,56,bluetoothImage);
		dc.drawText(narrow, 0, tinyFont, "B", Gfx.TEXT_JUSTIFY_LEFT);
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

}
