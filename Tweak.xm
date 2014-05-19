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

/*
    What does this do?
    So far, nothing has been observed...

%hook SBLockScreenViewControllerBase
- (void)_transitionWallpaperFromLock {
	if ([LibPass sharedInstance].isPasscodeOn == NO) {
		[(SBLockScreenManager *)[%c(SBLockScreenManager) sharedInstance] attemptUnlockWithPasscode:[NSString stringWithFormat:@"%@",[LibPass sharedInstance].devicePasscode]];
	}
	%orig;
}
%end
*/

%hook SBLockScreenManager
- (void)_finishUIUnlockFromSource:(int)fp8 withOptions:(id)fp12 {
	[[LibPass sharedInstance] setPasscodeToggle:YES];
	%orig;
}
%end

%hook SBDeviceLockController
- (BOOL)attemptDeviceUnlockWithPassword:(id)arg1 appRequested:(BOOL)arg2 {
    BOOL result;

    // We should possibly add result checks to make sure we aren't feeding anything an invalid password.
    // Unless, of course, something wants the invalid password (e.g. a GuestMode type tweak)...
    if ([arg1 isKindOfClass:[NSString class]])
        [[LibPass sharedInstance] passwordWasEnteredHandler:arg1];
    else
        [[LibPass sharedInstance] passwordWasEnteredHandler:[[LibPass sharedInstance] getEffectiveDevicePasscode]];

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

%ctor
{
	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:SETTINGS_FILE];
    if (prefs && [prefs objectForKey:@"savedPasscode"] != nil)
    {
        NSData *passcodeData = [prefs[@"savedPasscode"] AES256DecryptWithKey:getUDID()];
        [LibPass sharedInstance].devicePasscode = [NSString stringWithUTF8String:[[[NSString alloc] initWithData:passcodeData encoding:NSUTF8StringEncoding] UTF8String]];
    }
}
