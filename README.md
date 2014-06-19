
Description
===========
Phonegap (Cordova) plugin to wrap the linphone softphone library for phonegap videophone applications.


Important
=========
In order to use this plugin you will need to download and build the linphone iOS libraries and then add them to your phonegap project.

This is a challenging task. Start at linphone.org

This is a preliminary implementation refactored from a working project. At this point we've not taken this refactored code forward to build a working app. Useful as a reference or starting point for your own plugin. YMMV.

If there's interest we'll commit more time to enhancing and maintaining this.


Usage
=====

```html
<div>
    <input type="text" id="number" value="Guest" />
    <button id="call" onClick="javascript:doCall();" disabled>Call</button>
    <button id="hangup" onClick="javascript:doHangup();" disabled>Hangup</button>
    <button id="videoOn" onClick="javascript:doVideoOn();" disabled>Video On</button>
    <button id="videoOff" onClick="javascript:doVideoOff();" disabled>Video Off</button>
</div>
<script>
    // see below
</script>
```
```javascript
    var inCall = false;
    function onCallUpdate(dict) {
        document.getElementById('call').disabled = (dict.canCall!==true);
        document.getElementById('hangup').disabled = (dict.canHangup!==true);
        document.getElementById('videoOn').disabled = (dict.canStartVideo!==true);
        document.getElementById('videoOff').disabled = (dict.canStopVideo!==true);
        inCall = (dict.canCall!==true);
        }

    function setup() {
        window.plugins.LinPhoneGap.call(number,function(err){});
        window.plugins.LinPhoneGap.initPhone(onCallUpdate);
        }

    function doCall() {
        var number = document.getElementById('number').value;
        window.plugins.LinPhoneGap.call(number,function(err){});
        }

    function doHangup() { window.plugins.LinPhoneGap.hangup(function(err){}); }
    function doVideoOn() { window.plugins.LinPhoneGap.videoOn(function(err){}); }
    function doVideoOff() { window.plugins.LinPhoneGap.videoOff(function(err){}); }

    /* *IMPORTANT*
    You will need to invoke window.plugins.LinPhoneGap.initPhone(onCallUpdate) before using these
    functions. Exactly how you do that will depend on your environment, frameworks and target
    browsers. 
    */
    
```

Installation
============
cordova plugin add https://github.com/babelroom/LinPhoneGap.git

