//
//  LinPhoneGap.js
//
//  Created by John Roy on 04/01/2014
//  Copyright (c) 2014 BabelRoom. All rights reserved.

(function(){
    var cordovaRef = window.PhoneGap || window.Cordova || window.cordova; // old to new fallbacks
    var LinPhoneGap = function(){
        this.callback = null;
    }

    /**
     */
    LinPhoneGap.prototype.initPhone = function(fn) {
        this.callback = fn;
        fn({canCall:true,canHangup:false,canStartVideo:false,canStopVideo:false});
    }
 
    /**
     */
    LinPhoneGap.prototype.log = function() {
        cordovaRef.exec(null, null, "LinPhoneGap", "log", [arguments]);
    }
 
    /**
     */
    LinPhoneGap.prototype.call = function(num,cb) {
        cordovaRef.exec(function(){cb();}, function(){cb('err');}, "LinPhoneGap", "call", [num]);
    }
 
    /**
     */
    LinPhoneGap.prototype.hangup = function(cb) {
        cordovaRef.exec(function(){cb();}, function(){cb('err');}, "LinPhoneGap", "hangup", []);
    }
 
    /**
     */
    LinPhoneGap.prototype.videoOn = function(cb) {
        cordovaRef.exec(function(){cb();}, function(){cb('err');}, "LinPhoneGap", "videoOnOff", [true]);
    }
 
    /**
     */
    LinPhoneGap.prototype.videoOff = function(cb) {
        cordovaRef.exec(function(){cb();}, function(){cb('err');}, "LinPhoneGap", "videoOnOff", [false]);
    }
 
    /**
     */
    LinPhoneGap.prototype._phoneEvent = function(state) {
        this.callback && this.callback(state);
    }
 
    cordovaRef.addConstructor(function(){
        if(!window.plugins)
        {
            window.plugins = {};
        }
        window.plugins.LinPhoneGap = new LinPhoneGap();
    });
})();

