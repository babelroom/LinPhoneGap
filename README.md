
Description
===========
Phonegap (Cordova) plugin to wrap the linphone library softphone library for phonegap videophone applications.


Important
=========
In order to use this plugin you will need to download and build the linphone iOS libraries and then add them to your phonegap project. This is a challenging task. Start at linphone.org


Simple Usage
=====

```javascript

    window.plugins.LinPhoneGap.call("+16505551212",function(err){});

```

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
```
```javascript
<script>
    var inCall = false;
    function onCallUpdate(dict) {
        document.getElementById('call').disabled = (dict.canCall!==true);
        document.getElementById('hangup').disabled = (dict.canHangup!==true);
        document.getElementById('videoOn').disabled = (dict.canStartVideo!==true);
        document.getElementById('videoOff').disabled = (dict.canStopVideo!==true);
        inCall = (dict.canCall!==true);
        }

    function doCall() {
        var number = document.getElementById('number').value;
        window.plugins.LinPhoneGap.call(number,function(err){});
        }

    function doHangup() { window.plugins.LinPhoneGap.hangup(function(err){}); }
    function doVideoOn() { window.plugins.LinPhoneGap.videoOn(function(err){}); }
    function doVideoOff() { window.plugins.LinPhoneGap.videoOff(function(err){}); }
</script>
```

Installation
============
cordova local plugin add LinPhoneGap

