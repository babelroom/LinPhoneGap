**NOTE**
========
Code is currently being refactored. Do not use. Preliminary.







Description
===========
Wraps linphone library functions to allow adding videophone features to a phonegap (cordova) app


Usage
=====

```javascript

...Error return by the plugin : ["feature","empty"] ???

            var inCall = false, pin = null, firsttime = true;
            function onCallUpdate(dict) {
                document.getElementById('call').disabled = (dict.canCall!==true);
                document.getElementById('hangup').disabled = (dict.canHangup!==true);
                document.getElementById('videoOn').disabled = (dict.canStartVideo!==true);
                document.getElementById('videoOff').disabled = (dict.canStopVideo!==true);
                inCall = (dict.canCall!==true);
            }




            function ready() {
                // doesn't seem this is ever called
//                window.plugins.BRSIP.fubar(function(msg){alert(msg?msg:"OK");});
//                window.plugins.BRSIP.fubar(foo2,foo2);
                //foo2({_state:"foo"});
console.log=window.plugins.BRSIP.log;
window.plugins.BRSIP.log("foo");
                window.plugins.BRSIP.initPhone(onCallUpdate);
                window.BR.api.v1.init(init_arg);
//                window.BR.api.v1.currentUser(function(e,d){
                /*
                window.BR.api.v1.addSelf('/john',{name:"Luloo"},function(e,d){
                                             console.log(e||JSON.stringify(d));
                                            });
                 */
                document.getElementById('enter').disabled = false;
            }
            function doLogin(name) {
                window.BR.api.v1.addSelf(room,{name:name},function(e,d){                 /* addSelf so cookie gets set */
                        if (!e && d.user && d.user.id /* d.user.name also exists FYI */) {
                            document.getElementById('enter').innerHTML = "Please wait...";
                            setTimeout(checkInvitation,0);     // bit of a hack, change so SIP connections auto-retry on server...
                            }
//                                         console.log(e||JSON.stringify(d));
                    });
            }
            function checkInvitation(callToLogin) {
                window.BR.api.v1.invitation(room,function(e,d){
                    console.log(e||JSON.stringify(d));
                    if (!e && d) {
                        if (d.pin) {
                            pin = d.pin;
                            document.getElementById('enter').disabled = false;
                            document.getElementById('text').disabled = true;
                            document.getElementById('enter').innerHTML = "Enter Room";
                            doEnterRoom();
                            }
                        else if (d.pin===null && callToLogin)
                            callToLogin();
                        else
                            document.getElementById('enter').disabled = false;
                        }
                    else
                        document.getElementById('enter').disabled = false;
                });
            }
            function goBack() {
                //window.location.href = "room.html";
                if (inCall)
                    window.plugins.BRSIP.hangup();
                document.getElementById('roomiframe').src = "https://babelroom.com/";   // seems this is the only way to close webview room, i.e. point to a new VALID url
                document.body.style['background-color'] = '#5678a7';
                document.getElementById('home').style.visibility = 'visible';
                document.getElementById('room').style.visibility = 'hidden';
            }
            function enterRoom() {
                document.getElementById('enter').disabled = true;
                checkInvitation(function(){doLogin(document.getElementById('text').value);});
            }
            function doEnterRoom() {
                if (firsttime) {
                    doCall();
                    firsttime = false;
                    }
                document.getElementById('roomiframe').src = url+room;
//                document.body.style['background-color'] = '#000000';
                document.body.style['background-color'] = 'transparent';
                document.getElementById('home').style.visibility = 'hidden';
                document.getElementById('room').style.visibility = 'visible';
            }
//            function fubar(p) {
//                window.plugins.BRSIP.echo(p,function(msg){alert(msg?msg:"OK");});
//            }
            function doCall() {
//console.log("pin="+pin);
                window.plugins.BRSIP.call(pin,addr,function(err){/*alert('OK')*/;});
            }
            function doHangup() {
                window.plugins.BRSIP.hangup(function(err){/*alert('OK')*/;});
            }
            function doVideoOn() { window.plugins.BRSIP.videoOn(function(err){;}); }
            function doVideoOff() { window.plugins.BRSIP.videoOff(function(err){;}); }
//            function jrtest(str){
//                //alert(str);
//                foo2(str);
//            }
        </script>


```

Installation
============
cordova local plugin add "current repo"

