//
//  RNLeanplum.m
//  RNLeanplum
//
//  Created by Bassel Dagher on 8/18/17.
//  Copyright © 2017-2018 Branding Brand. All rights reserved.
//

#import "RNLeanplum.h"

#if __has_include(<Leanplum/Leanplum.h>)
#import <Leanplum/Leanplum.h>
#elif __has_include("Leanplum.h")
#import "Leanplum.h"
#else
#import "Leanplum/Leanplum.h"
#endif
#import <React/RCTLog.h>
static NSString * const kRNLeanplumDuplicateStartErrorCode = @"RNLeanplumDuplicateStart";
static NSString * const kRNLeanplumDuplicateStartErrorReason = @"Leanplum: Already called start. Calling start a second time has no effect.";

@implementation RNLeanplum
RCT_EXPORT_MODULE(Leanplum);

- (RNLeanplum *)init {

    self=[super init];
#ifdef DEBUG
    LEANPLUM_USE_ADVERTISING_ID;
    [Leanplum setAppId:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"LeanplumAppId"]
    withDevelopmentKey:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"LeanplumDevSecret"]];
#else
    [Leanplum setAppId:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"LeanplumAppId"]
     withProductionKey:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"LeanplumProdSecret"]];
#endif

    // Optional: Tracks in-app purchases automatically as the "Purchase" event.
    // To require valid receipts upon purchase or change your reported
    // currency code from USD, update your app settings.
    // [Leanplum trackInAppPurchases];

    // Optional: Tracks all screens in your app as states in Leanplum.
    [Leanplum trackAllAppScreens];

    // Optional: Activates UI Editor.
    // Requires the Leanplum-iOS-UIEditor framework.
    // [[LeanplumUIEditor sharedEditor] allowInterfaceEditing];

    // Sets the app version, which otherwise defaults to
    // the build number (CFBundleVersion).
    [Leanplum setAppVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    [Leanplum start];
id notificationCenterClass = NSClassFromString(@"UNUserNotificationCenter");
  if (notificationCenterClass) {
    // iOS 10.
    SEL selector = NSSelectorFromString(@"currentNotificationCenter");
    id notificationCenter =
    ((id (*)(id, SEL)) [notificationCenterClass methodForSelector:selector])
    (notificationCenterClass, selector);
    if (notificationCenter) {
      selector = NSSelectorFromString(@"requestAuthorizationWithOptions:completionHandler:");
      IMP method = [notificationCenter methodForSelector:selector];
      void (*func)(id, SEL, unsigned long long, void (^)(BOOL, NSError *__nullable)) =
      (void *) method;
      func(notificationCenter, selector,
           0b111, /* badges, sounds, alerts */
           ^(BOOL granted, NSError *__nullable error) {
             if (error) {
               NSLog(@"Leanplum: Failed to request authorization for user "
                     "notifications: %@", error);
             }
           });
    }
    [[UIApplication sharedApplication] registerForRemoteNotifications];
  } else if ([[UIApplication sharedApplication] respondsToSelector:
              @selector(registerUserNotificationSettings:)]) {
    // iOS 8-9.
    UIUserNotificationSettings *settings = [UIUserNotificationSettings
                                            settingsForTypes:UIUserNotificationTypeAlert |
                                            UIUserNotificationTypeBadge |
                                            UIUserNotificationTypeSound categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
  } else {
    // iOS 7 and below.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
#pragma clang diagnostic pop
     UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge];
  }
    // Starts a new session and updates the app content from Leanplum.
    return self;
}
RCT_REMAP_METHOD(setApiConnectionSettings,
                 setApiHostName:(NSString *)hostName withServletName:(NSString *)servletName usingSsl:(BOOL)ssl) {
    [Leanplum setApiHostName:hostName withServletName:servletName usingSsl:ssl];
}

RCT_REMAP_METHOD(setNetworkTimeout,
                 setNetworkTimeoutSeconds:(int)seconds forDownloads:(int)downloadSeconds) {
    [Leanplum setNetworkTimeoutSeconds:seconds forDownloads:downloadSeconds];
}

RCT_EXPORT_METHOD(setNetworkActivityIndicatorEnabled:(BOOL)enabled) {
    [Leanplum setNetworkActivityIndicatorEnabled:enabled];
}

RCT_EXPORT_METHOD(setCanDownloadContentMidSessionInProductionMode:(BOOL)value) {
    [Leanplum setCanDownloadContentMidSessionInProductionMode:value];
}

RCT_EXPORT_METHOD(setFileHashingEnabledInDevelopmentMode:(BOOL)enabled) {
    [Leanplum setFileHashingEnabledInDevelopmentMode:enabled];
}

RCT_EXPORT_METHOD(setVerboseLoggingInDevelopmentMode:(BOOL)enabled) {
    [Leanplum setVerboseLoggingInDevelopmentMode:enabled];
}

RCT_EXPORT_METHOD(setInAppPurchaseEventName:(NSString *)event) {
    [Leanplum setInAppPurchaseEventName:event];
}

RCT_REMAP_METHOD(setAppIdForDevelopmentMode,
                 setAppId:(NSString *)appId withDevelopmentKey:(NSString *)accessKey) {
    [Leanplum setAppId:appId withDevelopmentKey:accessKey];
}

RCT_REMAP_METHOD(setAppIdForProductionMode,
                 setAppId:(NSString *)appId withProductionKey:(NSString *)accessKey) {
    [Leanplum setAppId:appId withProductionKey:accessKey];
}

RCT_EXPORT_METHOD(setDeviceId:(NSString *)deviceId) {
    [Leanplum setDeviceId:deviceId];
}

RCT_EXPORT_METHOD(setAppVersion:(NSString *)appVersion) {
    [Leanplum setAppVersion:appVersion];
}

RCT_REMAP_METHOD(start,
                 startWithUserId:(NSString *)userId userAttributes:(NSDictionary *)attributes resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    if (![Leanplum hasStarted]) {
        return [Leanplum startWithUserId:userId userAttributes:attributes responseHandler:^(BOOL success) {
            return resolve(@(success));
        }];
    } else {
        reject(kRNLeanplumDuplicateStartErrorCode, kRNLeanplumDuplicateStartErrorReason, nil);
    }
}

RCT_REMAP_METHOD(hasStarted,
                 hasStartedWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    return resolve(@([Leanplum hasStarted]));
}

RCT_REMAP_METHOD(hasStartedAndRegisteredAsDeveloper,
                 hasStartedAndRegisteredAsDeveloperWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    return resolve(@([Leanplum hasStartedAndRegisteredAsDeveloper]));
}

RCT_EXPORT_METHOD(onStartResponse:(RCTResponseSenderBlock)callback) {
    return [Leanplum onStartResponse:^(BOOL success) {
        return callback(@[@(success)]);
    }];
}

RCT_EXPORT_METHOD(onVariablesChanged:(RCTResponseSenderBlock)callback) {
    return [Leanplum onVariablesChanged:^{
        return callback(@[]);
    }];
}

RCT_EXPORT_METHOD(onInterfaceChanged:(RCTResponseSenderBlock)callback) {
    return [Leanplum onInterfaceChanged:^{
        return callback(@[]);
    }];
}

RCT_EXPORT_METHOD(onVariablesChangedAndNoDownloadsPending:(RCTResponseSenderBlock)callback) {
    return [Leanplum onVariablesChangedAndNoDownloadsPending:^{
        return callback(@[]);
    }];
}

RCT_EXPORT_METHOD(onceVariablesChangedAndNoDownloadsPending:(RCTResponseSenderBlock)callback) {
    return [Leanplum onceVariablesChangedAndNoDownloadsPending:^{
        return callback(@[]);
    }];
}

RCT_EXPORT_METHOD(setUserId:(NSString *)userId) {
    return [Leanplum setUserId:userId];
}

RCT_REMAP_METHOD(setUserAttributes,
                 setUserId:(NSString *)userId withUserAttributes:(NSDictionary *)attributes) {
    return [Leanplum setUserId:userId withUserAttributes:attributes];
}

RCT_EXPORT_METHOD(setTrafficSourceInfo:(NSDictionary *)info) {
    return [Leanplum setTrafficSourceInfo:info];
}

RCT_EXPORT_METHOD(advanceTo:(NSString *)state withInfo:(NSString *)info andParameters:(NSDictionary *)params) {
    return [Leanplum advanceTo:state withInfo:info andParameters:params];
}

RCT_EXPORT_METHOD(pauseState) {
    return [Leanplum pauseState];
}

RCT_EXPORT_METHOD(resumeState) {
    return [Leanplum resumeState];
}

RCT_EXPORT_METHOD(trackAllAppScreens) {
    return [Leanplum trackAllAppScreens];
}

RCT_EXPORT_METHOD(trackPurchase:(NSString *)event withValue:(double)value andCurrencyCode:(NSString *)currencyCode andParameters:(NSDictionary *)params) {
    return [Leanplum trackPurchase:event withValue:value andCurrencyCode:currencyCode andParameters:params];
}

RCT_EXPORT_METHOD(trackInAppPurchases) {
    return [Leanplum trackInAppPurchases];
}

RCT_EXPORT_METHOD(track:(NSString *)event withValue:(double)value andInfo:(NSString *)info andParameters:(NSDictionary *)params) {
    return [Leanplum track:event withValue:value andInfo:info andParameters:params];
}

RCT_REMAP_METHOD(variants,
                 variantsWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    return resolve([Leanplum variants]);
}

RCT_EXPORT_METHOD(forceContentUpdate:(RCTResponseSenderBlock)callback) {
    if (callback) {
        return [Leanplum forceContentUpdate:^{
            return callback(@[]);
        }];
    }

    return [Leanplum forceContentUpdate];
}

RCT_EXPORT_METHOD(enableTestMode) {
    return [Leanplum enableTestMode];
}

RCT_EXPORT_METHOD(setTestModeEnabled:(BOOL)isTestModeEnabled) {
    return [Leanplum setTestModeEnabled:isTestModeEnabled];
}

RCT_EXPORT_METHOD(setPushSetup:(RCTResponseSenderBlock)callback) {
    return [Leanplum setPushSetup:^{
        return callback(@[]);
    }];
}

RCT_REMAP_METHOD(isPreLeanplumInstall,
                 isPreLeanplumInstallWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    return resolve(@([Leanplum isPreLeanplumInstall]));
}

RCT_REMAP_METHOD(deviceId,
                 deviceIdWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    return resolve([Leanplum deviceId]);
}

RCT_REMAP_METHOD(userId,
                 userIdWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    return resolve([Leanplum userId]);
}

@end
