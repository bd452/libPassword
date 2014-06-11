#import "libPass.h"
#import "headers.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <substrate.h>
#import "NSData+AES.m"
#define SETTINGS_FILE @"/var/mobile/Library/Preferences/com.bd452.libPass.plist"

// MobileGestalt stuff for UDID
extern "C" CFPropertyListRef MGCopyAnswer(CFStringRef property);

// returns the device's UDID. Because we are in SpringBoard this works
NSString* getUDID()
{
    NSString *udid = (__bridge NSString*)MGCopyAnswer(CFSTR("UniqueDeviceID"));
    return udid;
}

%hook SBLockStateAggregator
-(void)_updateLockState
{
    %orig;
    if (![self hasAnyLockState]) // device is unlocked
        [[LibPass sharedInstance] deviceWasUnlockedHandler];
}
%end

%hook SBLockScreenViewController
-(void)passcodeLockViewPasscodeEntered:(SBUIPasscodeLockViewWithKeyboard*)arg1
{
    //NSLog(@"LibPass: passcodeLockViewPasscodeEntered %@", [arg1 passcode]);

    if ([[arg1 passcode] isKindOfClass:[NSString class]])
        [[LibPass sharedInstance] passwordWasEnteredHandler:[arg1 passcode]];
    else
        [[LibPass sharedInstance] passwordWasEnteredHandler:[[LibPass sharedInstance] getEffectiveDevicePasscode]];

    %orig;
}
%end

%hook SBDeviceLockController
- (BOOL)attemptDeviceUnlockWithPassword:(id)arg1 appRequested:(BOOL)arg2 {
    BOOL result;

    if ([LibPass sharedInstance].isPasscodeOn)
    {
        // Passcode should not be arbitrarily bypassed, but we can still run checks
        result = %orig;

        if (!result && [arg1 isKindOfClass:[NSString class]] && [[LibPass sharedInstance] shouldAllowPasscode:arg1])
        {
            // Passcode is not the system passcode but it should still be allowed access
            // For example, something like TimePasscode could be possible by registering a delegate to return YES
            // if the entered passcode is the correct TP passcode. LibPassword will then perform a %orig using the system 
            // passcode (which should be granted access), not always bypassing the passcode but allowing for 
            // more than passcode to be "correct"
            result = %orig([[LibPass sharedInstance] getEffectiveDevicePasscode], arg2);
            
            // We already know it isn't the correct device passcode.
            // Not returning here would cause many further problems.
            return result;
        }
    }
    else
    {
        // Passcode should be bypassed (no matter what)
        if ([[LibPass sharedInstance] isPasscodeAvailable])
            result = %orig([[LibPass sharedInstance] getEffectiveDevicePasscode], arg2);
        else
            result = %orig; // No device passcode stored
    }
    
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:SETTINGS_FILE];
    if (!prefs)
        prefs = [[NSMutableDictionary alloc] init];

    if ([arg1 isKindOfClass:[NSString class]] && ![prefs[@"savedPasscode"] isKindOfClass:[NSData class]] && result)
    {
        [LibPass sharedInstance].devicePasscode = arg1;
        [prefs setObject:[[arg1 dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptWithKey:getUDID()] forKey:@"savedPasscode"];
        [prefs writeToFile:SETTINGS_FILE atomically:YES];
    }
    else if ([prefs[@"savedPasscode"] isKindOfClass:[NSData class]])
    {
        NSData *passcodeData = [prefs[@"savedPasscode"] AES256DecryptWithKey:getUDID()];
        [LibPass sharedInstance].devicePasscode = [NSString stringWithUTF8String:[[[NSString alloc] initWithData:passcodeData encoding:NSUTF8StringEncoding] UTF8String]];
            
        if (result)
        {
            if ([LibPass sharedInstance].devicePasscode != arg1 && [arg1 isKindOfClass:[NSString class]])
            {
                [LibPass sharedInstance].devicePasscode = arg1;
                [prefs setObject:[[arg1 dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptWithKey:getUDID()] forKey:@"savedPasscode"];
                [prefs writeToFile:SETTINGS_FILE atomically:YES];
            }
        }
    }
    else
    {
        if (![prefs[@"savedPasscode"] isKindOfClass:[NSData class]])// no passcode stored
        {
            UIAlertView *alert = [[UIAlertView alloc]
                initWithTitle:@"LibPass"
                message:@"No device passcode stored. Please unlock the device with your passcode."
                delegate:nil
                cancelButtonTitle:@"OK"
                otherButtonTitles:nil];
            [alert show];
        }
        else if (result && [LibPass sharedInstance].devicePasscode != nil && [LibPass sharedInstance].devicePasscode != arg1 && [arg1 isKindOfClass:[NSString class]])
        {
            // Basically here are the checks:
            // 1. arg1 actually is correct and a NSString
            // 2. arg1 != an existing stored passcode

            [LibPass sharedInstance].devicePasscode = arg1;
            [prefs setObject:[[arg1 dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptWithKey:getUDID()] forKey:@"savedPasscode"];
            [prefs writeToFile:SETTINGS_FILE atomically:YES];
        }
    }

    return result;
}

%end

%hook SBUserAgent
- (BOOL)deviceIsPasscodeLocked 
{
    // If the passcode should be bypassed return NO.
    // Otherwise, return the default value

	if ([LibPass sharedInstance].isPasscodeOn == NO)
		return NO;
	else
		return %orig;
}
%end

%hook AndroidLockView
- (_Bool)isPatternRequired 
{ 
    if ([LibPass sharedInstance].toggleValue)
        return NO;
    return %orig;
}
%end

%ctor
{
	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:SETTINGS_FILE];
    if (prefs && [prefs objectForKey:@"savedPasscode"] != nil)
    {
        NSData *passcodeData = [prefs[@"savedPasscode"] AES256DecryptWithKey:getUDID()];
        [LibPass sharedInstance].devicePasscode = [NSString stringWithUTF8String:[[[NSString alloc] initWithData:passcodeData encoding:NSUTF8StringEncoding] UTF8String]];
    }
}
