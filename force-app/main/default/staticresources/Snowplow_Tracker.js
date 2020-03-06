console.log("start: gdx_analytics.js");
;(function(p,l,o,w,i,n,g){if(!p[i]){p.GlobalSnowplowNamespace=p.GlobalSnowplowNamespace||[];
 p.GlobalSnowplowNamespace.push(i);p[i]=function(){(p[i].q=p[i].q||[]).push(arguments)
 };p[i].q=p[i].q||[];n=l.createElement(o);g=l.getElementsByTagName(o)[0];n.async=1;
 n.src=w;g.parentNode.insertBefore(n,g)}}(window,document,"script","/resource/snowplow_inline_tracker","snowplow"));
var collector = 'spt.apps.gov.bc.ca';
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
window.snowplow('enableActivityTracking', 30, 30);
window.snowplow('enableLinkClickTracking');
reset_contexts(); 
window.snowplow('trackPageView');

function trackPageView () {
    window.snowplow('trackPageView');
}

function reset_contexts() {
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
    window.snowplow('addGlobalContexts', [{
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
    }]);
}

var JSONString = '';
var ComponentName = '';
var NavigatingComponent = '';
var buttonName = '';
var button = '';
(function(){
    JSONSnowplow = function (captureText) {
		JSONString = captureText;
        reset_contexts();
    }
})();

(function(){
    CompLoadSnowplow = function (captureText) {
		console.log('captureText: '+captureText);
		ComponentName = captureText;
		reset_contexts();
        if ( typeof JSONString == 'undefined' || !(JSONString)) {
            setTimeout(trackPageView, 1000);
        } else {
            trackPageView();
        }
    }
})();

(function(){
    CompNavigateSnowplow = function (captureText1, captureText2) {
		console.log('captureText1: '+captureText1);
		console.log('captureText2: '+captureText2);
		buttonName = captureText1;
		NavigatingComponent = captureText2;


    window.snowplow('trackSelfDescribingEvent', {
        schema: 'iglu:ca.bc.gov.myfs/button_click/jsonschema/1-0-0',
        data: {
          button_name: buttonName,
          component_name: NavigatingComponent
        }
    });
		
    }
})();

function EstimateSP () {
    if ( typeof button == 'undefined' || !(button)) {
        button = 'Undefined';
    }

    var total = 0;
    var estimate_list = [];
    var count = document.getElementsByClassName('child-index').length;
    var estimate_tag_list = document.getElementsByClassName('uiOutputCurrency');
    for(var i = 0; i < estimate_tag_list.length; i++) {
        estimate_list.push(Number(estimate_tag_list[i].textContent.replace(/[\$,]/g, '')));
        total = total + Number(estimate_tag_list[i].textContent.replace(/[\$,]/g, ''));
    }

    window.snowplow('trackSelfDescribingEvent', {
        schema: 'iglu:ca.bc.gov.myfs/estimator/jsonschema/2-0-0',
        data: {
          count: count,
          button: button,
          total: total,
          estimates: estimate_list
        }
    });
}

function set_triggers() {
    var estimate_button_list = document.getElementsByClassName('estimate-btn');
    for(var i = 0; i < estimate_button_list.length; i++) {
        estimate_button_list[i].addEventListener("click", function(){ button = 'estimate'; setTimeout(EstimateSP, 2000);});
    }
   
    var register_button_list = document.getElementsByClassName('register-btn');
    for(var i = 0; i < register_button_list.length; i++) {
        register_button_list[i].addEventListener("click", function(){ button = 'register'; EstimateSP();});
    }
}
setTimeout(set_triggers, 4000);
console.log("end: gdx_analytics.js");

