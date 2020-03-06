console.log("start: gdx_analytics.js");
;(function(p,l,o,w,i,n,g){if(!p[i]){p.GlobalSnowplowNamespace=p.GlobalSnowplowNamespace||[];
 p.GlobalSnowplowNamespace.push(i);p[i]=function(){(p[i].q=p[i].q||[]).push(arguments)
 };p[i].q=p[i].q||[];n=l.createElement(o);g=l.getElementsByTagName(o)[0];n.async=1;
 n.src=w;g.parentNode.insertBefore(n,g)}}(window,document,"script","/resource/snowplow_inline_tracker","snowplow"));
var collector = 'spm.gov.bc.ca';
 window.snowplow('newTracker','rt',collector, {
  appId: "Snowplow_standalone_MyFS",
  platform: 'web',
  post: true,
  forceSecureTracker: true,
  contexts: {
   webPage: true,
   performanceTiming: true
  }
 });


console.log("make initial snowplow call") 
 window.snowplow('enableActivityTracking', 30, 30); // Ping every 30 seconds after 30 seconds
 window.snowplow('enableLinkClickTracking');
 reset_contexts(); 
 window.snowplow('trackPageView');


function trackPageView () {
	window.snowplow('trackPageView');
}

console.log("begin: define custom tracking function definitions");
function reset_contexts() {
	console.log('set up global Snowplow contexts'); 

	if ( typeof ComponentName == 'undefined' || !(ComponentName)) {
		console.log('ERROR: ComponentName was not defined'); 
		ComponentName = 'Undefined'; 
	} 
	try {
                component_list = JSON.parse(JSONString);
        } 
        catch(err) {
                console.log('JSON parse error: ' + err.message);
                component_list = [];
        }
        window.snowplow('clearGlobalContexts' ); 
        window.snowplow('addGlobalContexts', [
                {
                        schema: 'iglu:ca.bc.gov.myfs/component_name/jsonschema/1-0-0',
                        data: {
                                component_name: ComponentName
                        }
                },
                {
                        schema: 'iglu:ca.bc.gov.myfs/nav/jsonschema/1-0-0',
                        data: {
                                component_list: component_list
                        }
                }
        ])
}
console.log("end: define custom tracking function definitions");


var JSONString = '';
var ComponentName = '';
var button = '';
console.log('Method call from MyFS for JSON');
(function(){
      
        JSONSnowplow = function (captureText) {
		JSONString = captureText;
		console.log('captureText:'+JSONString);

		reset_contexts();
        }
})();

console.log('Method call from MyFS on component load');
(function(){
      
        CompLoadSnowplow = function (captureText) {
		ComponentName = captureText;
		console.log('captureText:'+ComponentName);

		reset_contexts();
		// If JSONString is not yet set, delay the pageview for 0.1 seconds to allow it to be populated by a JSONSnowplow call first. Otherwise, call right away. 
		if ( typeof JSONString == 'undefined' || !(JSONString)) {
			setTimeout(trackPageView, 100);
		} else {
			trackPageView();
		}
        }
})();

console.log('Function that executes the Snowplow call on an Estimator click');
function EstimateSP () {
    if ( typeof button == 'undefined' || !(button)) {
        console.log('ERROR: button was not defined');
    button = 'Undefined';
    }

    var total = 0;
    var estimate_list = [];

    var estimate_tag_list = document.getElementsByClassName('uiOutputCurrency');
    for(var i = 0; i < estimate_tag_list.length; i++) {
        estimate_list.push(Number(estimate_tag_list[i].textContent.replace(/[\$,]/g, '')));
        total = total + Number(estimate_tag_list[i].textContent.replace(/[\$,]/g, ''));
    }

    console.log('estimate_list: ' + estimate_list);

    window.snowplow('trackSelfDescribingEvent', {
        schema: 'iglu:ca.bc.gov.myfs/estimator/jsonschema/1-0-0',
        data: {
          button: button,
          total: total,
          estimates: estimate_list
        }
    });
}


function set_triggers() {
    console.log('set button triggers');
    var estimate_button_list = document.getElementsByClassName('estimate-btn');

    console.log('estimate_button_list');
    console.log(estimate_button_list);
    for(var i = 0; i < estimate_button_list.length; i++) {
        console.log('estimate button: ' + i);
        console.log(estimate_button_list[i]);
        estimate_button_list[i].addEventListener("click", function(){ button = 'estimate'; setTimeout(EstimateSP, 500);});
    }
   
    var register_button_list = document.getElementsByClassName('register-btn');
    for(var i = 0; i < register_button_list.length; i++) {
        console.log('register button: ' + i);
        console.log(register_button_list[i]);
        register_button_list[i].addEventListener("click", function(){ button = 'register'; EstimateSP();});
    }


}
setTimeout(set_triggers, 2000);


console.log("end: gdx_analytics.js");
