//
//  LinPhoneGap.m
//
//  Created by John Roy on 04/01/2014
//  Copyright (c) 2014 BabelRoom. All rights reserved.

#import "LinPhoneGap.h"
#import <Cordova/CDV.h>



#if 0

#import "LinphoneManager.h"
#import "lpconfig.h"

struct _ConfigCtx {
//    LinphoneCore *lc;
    LpConfig *lpConfig;
    const char *section;
};
void iterate_config_entry(const char *entry, void *ctx)
{
    struct _ConfigCtx *pCtx = (struct _ConfigCtx *)ctx;
    NSLog(@"%s::%s",pCtx->section,entry);
}
void iterate_config_sections(const char *section, void *ctx)
{
    struct _ConfigCtx *pCtx = (struct _ConfigCtx *)ctx;
    pCtx->section = section;
    lp_config_for_each_entry(pCtx->lpConfig, section, iterate_config_entry, ctx);
}
void iterate_codecs(const char *type, const MSList *codecs)
{
//- (void)transformCodecsToKeys: (const MSList *)codecs {
	LinphoneCore *lc=[LinphoneManager getLc];
	const MSList *elem=codecs;
	for(;elem!=NULL;elem=elem->next){
		PayloadType *pt=(PayloadType*)elem->data;
        int value = -1;
		NSString *pref=[LinphoneManager getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
		if (pref)
            value = linphone_core_payload_type_enabled(lc,pt)?1:0;
        NSLog(@"%s: %s:%d (%@) = %d", type, pt->mime_type, pt->clock_rate, pref?pref:@"___", value);
	}
}

@implementation BRSIP

//@synthesize callbackId;


/*
// Set observer
[[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(callUpdateEvent:)
                                             name:kLinphoneCallUpdate
                                           object:nil];
*/
- (void)pluginInitialize
{
    // You can listen to more app notifications, see:
    // http://developer.apple.com/library/ios/#DOCUMENTATION/UIKit/Reference/UIApplication_Class/Reference/Reference.html#//apple_ref/doc/uid/TP40006728-CH3-DontLinkElementID_4
    
    // NOTE: if you want to use these, make sure you uncomment the corresponding notification handler
    
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPause) name:UIApplicationDidEnterBackgroundNotification object:nil];
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onResume) name:UIApplicationWillEnterForegroundNotification object:nil];
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onOrientationWillChange) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onOrientationDidChange:) name:
UIApplicationDidChangeStatusBarOrientationNotification object:nil];
//        UIDeviceOrientationDidChangeNotification object:nil];
    
    // Added in 2.3.0
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLocalNotification:) name:CDVLocalNotification object:nil];
    
    // Added in 2.5.0
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageDidLoad:) name:CDVPageDidLoadNotification object:self.webView];
    NSLog(@"JR1");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callUpdateEvent:)
                                                 name:kLinphoneCallUpdate
                                               object:nil];
    if(![LinphoneManager isLcReady]) {
        [[LinphoneManager instance]	startLibLinphone];
    }
    if([LinphoneManager isLcReady]) {
        LinphoneCore* lc = [LinphoneManager getLc];
        
        [self checkOrientation];
        
        struct _ConfigCtx ctx;
        ctx.lpConfig = linphone_core_get_config(lc);
        lp_config_for_each_section(ctx.lpConfig, iterate_config_sections, &ctx);
        iterate_codecs("Audio", linphone_core_get_audio_codecs(lc));
        iterate_codecs("Video", linphone_core_get_video_codecs(lc));
        
        CGRect rect = [[UIScreen mainScreen] bounds];
//        CGRect viewPreviewRect = CGRectMake(10, 10, 500, 500);
        CGRect rectPreview = CGRectMake(rect.size.width-180, rect.size.height-240, 150, 200);
//        UIView* myView = [[UIView alloc] initWithFrame:viewRect];
        UIView* myView = [[UIView alloc] initWithFrame:rect];
        //myView.backgroundColor = [UIColor brownColor]; ... for illustration
        myView.backgroundColor = [UIColor whiteColor];
//        - (void)insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview
        UIView* myPreview = [[UIView alloc] initWithFrame:rectPreview];
        
        [self.webView.superview insertSubview:myView belowSubview:self.webView];
        [self.webView.superview insertSubview:myPreview aboveSubview:myView];
        [self.webView setOpaque:NO];
        self.webView.backgroundColor = [UIColor clearColor];
        linphone_core_set_native_video_window_id(lc, (unsigned long)myView);
        linphone_core_set_native_preview_window_id(lc, (unsigned long)myPreview);
        linphone_core_enable_video_preview(lc,1);   // this is necessary at present until we fix/set core config
    }
    
    [super pluginInitialize];
    NSLog(@"JR2");
}

/*- (void)dispose
{
    NSLog(@"JR97");
}
- (void)onAppTerminate
{
    NSLog(@"JR98");
}
- (void)dealloc
{
    NSLog(@"JR99");
}*/

- (void)log:(CDVInvokedUrlCommand*)command
{
    id message = [command.arguments objectAtIndex:0];    // TODO check parameters!!
    NSLog(@"%@",message);
}

- (void)call:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* sipaddr = [command.arguments objectAtIndex:0];    // TODO check parameters!!
    if([LinphoneManager isLcReady]) {
        LinphoneCore* lc = [LinphoneManager getLc];
        if (!linphone_core_get_current_call(lc)) {  /* only 1 call at a time */
            [[LinphoneManager instance] call:sipaddr displayName:@"BabelRoom SIP" transfer:FALSE];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
    }
    if (pluginResult==nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)hangup:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    if([LinphoneManager isLcReady]) {
        LinphoneCore* lc = [LinphoneManager getLc];
        LinphoneCall* currentcall = linphone_core_get_current_call(lc);
/*  -- removed this -- but leave for reference
    if (linphone_core_is_in_conference(lc) || // In conference
        (linphone_core_get_conference_size(lc) > 0 && [UIHangUpButton callCount:lc] == 0) // Only one conf
        ) {
        linphone_core_terminate_conference(lc);
    } else if(currentcall != NULL) { // In a call
        linphone_core_terminate_call(lc, currentcall);
    } else {
        const MSList* calls = linphone_core_get_calls(lc);
        if (ms_list_size(calls) == 1) { // Only one call
            linphone_core_terminate_call(lc,(LinphoneCall*)(calls->data));
        }
    }*/
        if(currentcall != NULL) { // In a call
            linphone_core_terminate_call(lc, currentcall);
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
    } else {
        [LinphoneLogger logc:LinphoneLoggerWarning format:"Cannot trigger hangup button: Linphone core not ready"];
    }
    if (pluginResult==nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)callUpdateEvent: (NSNotification*) notif {
    LinphoneCall *call = [[notif.userInfo objectForKey: @"call"] pointerValue];
    LinphoneCallState state = [[notif.userInfo objectForKey: @"state"] intValue];
/*- (void)callUpdate:(LinphoneCall *)call state:(LinphoneCallState)state animated:(BOOL)animated {*/
    NSLog(@"JR5");
    // Fake call update
    if(call == NULL) {
        return;
    }

//    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:state];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"hotdog"];
//    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
//    [super writeJavascript:[pluginResult toSuccessCallbackString:self.callbackId]];
//    [super writeJavascript:[pluginResult toSuccessCallbackString:self.callbackId]];
//    [super writeJavascript:[pluginResult toErrorCallbackString:self.callbackId]];
    
//    NSString *jsStatement = [NSString stringWithFormat:@"window.plugins.BRSIP._phoneEvent('%s');", stateAsString];
    
    //    NSMutableString *jsStatement = [[NSMutableString alloc] initWithString:@"window.plugins.BRSIP._phoneEvent({"];
    NSMutableString *jsStatement = [NSMutableString stringWithString:@"window.plugins.BRSIP._phoneEvent({_:0"];
    switch (state) {
        case LinphoneCallIdle:                  /**<Initial call state */
        case LinphoneCallIncomingReceived:      /**<This is a new incoming call */
            return;
        case LinphoneCallOutgoingInit:          /**<An outgoing call is started */
            [jsStatement appendString:@",canCall:false"];
            break;
        case LinphoneCallOutgoingProgress:      /**<An outgoing call is in progress */
        case LinphoneCallOutgoingRinging:       /**<An outgoing call is ringing at remote end */
        case LinphoneCallOutgoingEarlyMedia:    /**<An outgoing call is proposed early media */
        case LinphoneCallConnected:             /**<Connected, the call is answered */
            return;
        case LinphoneCallStreamsRunning:        /**<The media streams are established and running*/
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            [jsStatement appendString:@",canHangup:true"];
            if (linphone_call_params_video_enabled(linphone_call_get_current_params(call))) {
                [jsStatement appendString:@",canStopVideo:true"];
                [jsStatement appendString:@",canStartVideo:false"];
                }
            else {
                [jsStatement appendString:@",canStartVideo:true"];
                [jsStatement appendString:@",canStopVideo:false"];
                }
            break;
        case LinphoneCallPausing:               /**<The call is pausing at the initiative of local end */
        case LinphoneCallPaused:                /**< The call is paused, remote end has accepted the pause */
        case LinphoneCallResuming:              /**<The call is being resumed by local end*/
        case LinphoneCallRefered:               /**<The call is being transfered to another party, resulting in a new outgoing call to follow immediately*/
        case LinphoneCallError:                 /**<The call encountered an error*/
        case LinphoneCallEnd:                   /**<The call ended normally*/
        case LinphoneCallPausedByRemote:        /**<The call is paused by remote end*/
        case LinphoneCallUpdatedByRemote:       /**<The call's parameters change is requested by remote end, used for example when video is added by remote */
        case LinphoneCallIncomingEarlyMedia:    /**<We are proposing early media to an incoming call */
        case LinphoneCallUpdating:              /**<A call update has been initiated by us */
            return;
        case LinphoneCallReleased: ;              /**< The call object is no more retained by the core */
            [jsStatement appendString:@",canCall:true,canHangup:false,canStartVideo:false,canStopVideo:false"];
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            break;
    }
/*    [jsStatement appendFormat:@",_state:'%s'", linphone_call_state_to_string(state)]; -- good for debugging, reference */
    [jsStatement appendString:@"})"];
    [super writeJavascript:jsStatement];
//    NSLog(@"JR7");
}

/*- (void)callUpdateEvent: (NSNotification*) notif {
    LinphoneCall *call = [[notif.userInfo objectForKey: @"call"] pointerValue];
    LinphoneCallState state = [[notif.userInfo objectForKey: @"state"] intValue];
    [self callUpdate:call state:state animated:TRUE];
    NSLog(@"JR6");
}*/

- (void)videoOnOff:(CDVInvokedUrlCommand*)command
{
    BOOL onOff = [[command.arguments objectAtIndex:0] boolValue];
    CDVPluginResult* pluginResult = nil;
    if([LinphoneManager isLcReady]) {
        LinphoneCore* lc = [LinphoneManager getLc];
        if (linphone_core_video_enabled(lc)) {
            LinphoneCall* call = linphone_core_get_current_call(lc);
            if (call) {
                LinphoneCallAppData* callAppData = (__bridge LinphoneCallAppData*)linphone_call_get_user_pointer(call);
                callAppData->videoRequested=onOff; /* will be used later to notify user if video was not activated because of the linphone core */
                LinphoneCallParams* call_params =  linphone_call_params_copy(linphone_call_get_current_params(call));
                linphone_call_params_enable_video(call_params, onOff);
                linphone_core_update_call(lc, call, call_params);
                linphone_call_params_destroy(call_params);
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            } else {
                [LinphoneLogger logc:LinphoneLoggerWarning format:"Cannot toggle video, because no current call"];
            }
        }
    }
    if (pluginResult==nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) checkOrientation
{
    /* now unused
    // for some reason oo is the *old* orientation
    UIInterfaceOrientation oo = [[[notif userInfo] objectForKey: UIApplicationStatusBarOrientationUserInfoKey] integerValue];
    */
    UIInterfaceOrientation co = [[UIApplication sharedApplication] statusBarOrientation];
    NSLog(@"orientation change - %d %d",0/*oo*/,co);
    int nr = -1;
    switch (co) {
        case UIInterfaceOrientationPortrait:
            NSLog(@"PU");
            nr = 0;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            NSLog(@"PD");
            nr = 180;
            break;
        case UIInterfaceOrientationLandscapeRight:
            NSLog(@"LR");
            nr = 270;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            NSLog(@"LL");
            nr = 90;
            break;
    }
    if (nr>=0 && [LinphoneManager isLcReady]) {
        int or = linphone_core_get_device_rotation([LinphoneManager getLc]);
        if (nr!=or) {
            LinphoneCore* lc = [LinphoneManager getLc];
            NSLog(@"rotation update - %d %d",nr,or);
            linphone_core_set_device_rotation(lc, nr);
            LinphoneCall* call = linphone_core_get_current_call([LinphoneManager getLc]);
            if (call && linphone_call_params_video_enabled(linphone_call_get_current_params(call))) {
                //Orientation has changed, must call update call
                linphone_core_update_call([LinphoneManager getLc], call, NULL);
            }
        }
    }
}

- (void) onOrientationDidChange: (NSNotification *) notif
{
    [self checkOrientation];
}

/*
video stuff:

- (void)onOn {
    if(![LinphoneManager isLcReady]) {
        [LinphoneLogger logc:LinphoneLoggerWarning format:"Cannot toggle video button: Linphone core not ready"];
        return;
    }
    
	LinphoneCore* lc = [LinphoneManager getLc];
    
    if (!linphone_core_video_enabled(lc))
        return;
    
    [self setEnabled: FALSE];
    [waitView startAnimating];
    
    LinphoneCall* call = linphone_core_get_current_call([LinphoneManager getLc]);
	if (call) {
		LinphoneCallAppData* callAppData = (LinphoneCallAppData*)linphone_call_get_user_pointer(call);
		callAppData->videoRequested=TRUE; /* will be used later to notify user if video was not activated because of the linphone core*./
        LinphoneCallParams* call_params =  linphone_call_params_copy(linphone_call_get_current_params(call));
        linphone_call_params_enable_video(call_params, TRUE);
        linphone_core_update_call(lc, call, call_params);
		linphone_call_params_destroy(call_params);
    } else {
		[LinphoneLogger logc:LinphoneLoggerWarning format:"Cannot toggle video button, because no current call"];
	}   
}

- (void)onOff {
    if(![LinphoneManager isLcReady]) {
        [LinphoneLogger logc:LinphoneLoggerWarning format:"Cannot toggle video button: Linphone core not ready"];
        return;
    }
    
	LinphoneCore* lc = [LinphoneManager getLc];
    
    if (!linphone_core_video_enabled(lc))
        return;
    
    [self setEnabled: FALSE];
    [waitView startAnimating];
    
    LinphoneCall* call = linphone_core_get_current_call([LinphoneManager getLc]);
	if (call) { 
        LinphoneCallParams* call_params =  linphone_call_params_copy(linphone_call_get_current_params(call));
        linphone_call_params_enable_video(call_params, FALSE);
        linphone_core_update_call(lc, call, call_params);
		linphone_call_params_destroy(call_params);
    } else {
		[LinphoneLogger logc:LinphoneLoggerWarning format:"Cannot toggle video button, because no current call"];
	}
}

*/

@end

#endif
