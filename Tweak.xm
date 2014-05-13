#import "libPass.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <substrate.h>
#import "NSData+AES.m"
#define SETTINGS_FILE @"/var/mobile/Library/Preferences/com.bd452.libPass.plist"

@implementation LibPass

+ (id) sharedInstance
{
    static LibPass *instance;
    if (!instance)
        instance = [[LibPass alloc] init];
        
    return instance;
}

- (id) init
{
    delegates = [[NSMutableArray alloc] init];
    return [super init];
}

-(BOOL) isDelegateRegistered:(id)delegate
{
    return [delegates indexOfObject:delegate] != NSNotFound;
}

-(void) registerDelegate:(id)delegate
{
    if ([self isDelegateRegistered:delegate] || delegate == nil)
        return;
    
    [delegates addObject:delegate];
}
-(void) deregisterDelegate:(id)delegate
{
    if (![self isDelegateRegistered:delegate] || delegate == nil)
        return;

    NSUInteger num = [delegates indexOfObject:delegate];
    if (NSNotFound == num)
        return;
    [delegates removeObjectAtIndex:num];
}

- (void)unlockWithCodeEnabled:(BOOL)enabled 
{
    if (enabled) {
        [(SBLockScreenManager *)[objc_getClass("SBLockScreenManager") sharedInstance] unlockUIFromSource:1 withOptions:nil];
    }
    else
    {
        [self setPasscodeToggle:NO];
        [(SBLockScreenManager *)[objc_getClass("SBLockScreenManager") sharedInstance] attemptUnlockWithPasscode:[NSString stringWithFormat:@"%@", self.devicePasscode]];
    }
}

- (void)lockWithCodeEnabled:(BOOL)enabled
{
    [(SBUserAgent *)[objc_getClass("SBUserAgent") sharedUserAgent] lockAndDimDevice];
    [self setPasscodeToggle:enabled];
}

- (void)togglePasscode {
	self.isPasscodeOn = !self.isPasscodeOn;

	Class bulletinBannerController = objc_getClass("SBBulletinBannerController");
	Class bulletinRequest = objc_getClass("BBBulletinRequest");
    
	if (bulletinBannerController && bulletinRequest) {
		BBBulletinRequest *request = [[bulletinRequest alloc] init];
		request.title = @"Password";
		NSString *passcodeEnabledString;
		if ([LibPass sharedInstance].isPasscodeOn)
            passcodeEnabledString = @"enabled";
		else
            passcodeEnabledString = @"disabled";
		request.message = [NSString stringWithFormat:@"Password now %@", passcodeEnabledString];
		request.sectionID = @"com.bd452.libpass";
		[(SBBulletinBannerController *)[bulletinBannerController sharedInstance] observer:nil addBulletin:request forFeed:2];
		return;
	}

}

-(void)setPasscodeToggle:(BOOL)enabled
{
	self.isPasscodeOn = enabled;
}

-(void)passwordWasEnteredHandler:(NSString *)password {
    for (id delegate in delegates)
    {
        if (delegate && [delegate conformsToProtocol:@protocol(LibPassDelegate)] && [delegate respondsToSelector:@selector(passwordWasEntered:)])
        {
            [delegate passwordWasEntered:password];
        }
    }
}

- (BOOL) shouldAllowPasscode:(NSString*)passcode
{
    BOOL result = passcode == self.devicePasscode;;
    
    for (id delegate in delegates)
    {
        if (delegate && [delegate conformsToProtocol:@protocol(LibPassDelegate)] && [delegate respondsToSelector:@selector(shouldAllowPasscode:)])
        {
            [delegate shouldAllowPasscode:passcode];
        }
    }

    return result;
}

@end

// *****************************************************************************
// SpringBoard hooks start here
// *****************************************************************************

%hook SBLockScreenViewControllerBase
- (void)_transitionWallpaperFromLock {
	if ([LibPass sharedInstance].isPasscodeOn == NO) {
		[(SBLockScreenManager *)[%c(SBLockScreenManager) sharedInstance] attemptUnlockWithPasscode:[NSString stringWithFormat:@"%@",[LibPass sharedInstance].devicePasscode]];
	}
	%orig;
}
%end

%hook SBLockScreenManager
- (BOOL)attemptUnlockWithPasscode:(id)fp8
{
    // This may all be redundant (see [SBDeviceLockController attemptDeviceUnlockWithPassword:appRequested:])
    /*
	[[LibPass sharedInstance] passwordWasEnteredHandler:fp8];

	if ([LibPass sharedInstance].isPasscodeOn == NO)
    {
		return 	%orig([LibPass sharedInstance].devicePasscode);
	}
    */

    return %orig;
}

- (void)_finishUIUnlockFromSource:(int)fp8 withOptions:(id)fp12 {
	[[LibPass sharedInstance] setPasscodeToggle:YES];
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
            
            result = %orig([LibPass sharedInstance].devicePasscode, arg2);
        }
    }
    else
    {
        // Passcode should be bypassed (no matter what)
        result = %orig([LibPass sharedInstance].devicePasscode, arg2);
    }

    // We should possibly add result checks to make sure we aren't feeding anything an invalid password.
    // Unless, of course, something wants the invalid password (e.g. a GuestMode type tweak)...
    if ([arg1 isKindOfClass:[NSString class]])
        [[LibPass sharedInstance] passwordWasEnteredHandler:arg1];
    else
        [[LibPass sharedInstance] passwordWasEnteredHandler:[LibPass sharedInstance].devicePasscode];

    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:SETTINGS_FILE];
    if (!prefs)
        prefs = [[NSMutableDictionary alloc] init];

    if ([arg1 isKindOfClass:[NSString class]] && ![prefs[@"devicePasscode"] isKindOfClass:[NSData class]] && result)
    {
        [LibPass sharedInstance].devicePasscode = arg1;
        [prefs setObject:[[arg1 dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptWithKey:getUDID()] forKey:@"devicePasscode"];
        [prefs writeToFile:SETTINGS_FILE atomically:YES];
    }
    else if ([prefs[@"devicePasscode"] isKindOfClass:[NSData class]])
    {
        NSData *passcodeData = [prefs[@"devicePasscode"] AES256DecryptWithKey:getUDID()];
        [LibPass sharedInstance].devicePasscode = [NSString stringWithUTF8String:[[[NSString alloc] initWithData:passcodeData encoding:NSUTF8StringEncoding] UTF8String]];
            
        if (result)
        {
            if ([LibPass sharedInstance].devicePasscode != arg1 && [arg1 isKindOfClass:[NSString class]])
            {
                [LibPass sharedInstance].devicePasscode = arg1;
                [prefs setObject:[[arg1 dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptWithKey:getUDID()] forKey:@"devicePasscode"];
                [prefs writeToFile:SETTINGS_FILE atomically:YES];
            }
        }
    }
        
    if (![prefs[@"devicePasscode"] isKindOfClass:[NSData class]])// no passcode stored
    {
        UIAlertView *alert = [[UIAlertView alloc]
            initWithTitle:@"libPass"
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

        NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:SETTINGS_FILE];
        if (!prefs)
            prefs = [[NSMutableDictionary alloc] init];
        [LibPass sharedInstance].devicePasscode = arg1;
        [prefs setObject:[[arg1 dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptWithKey:getUDID()] forKey:@"devicePasscode"];
        [prefs writeToFile:SETTINGS_FILE atomically:YES];
    }

    return result;
}

%end

%hook SBUserAgent
- (BOOL)deviceIsPasscodeLocked 
{
	if ([LibPass sharedInstance].isPasscodeOn == NO)
		return NO;
	else
		return %orig;
}
%end

%ctor
{
	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:SETTINGS_FILE];
    if ([prefs objectForKey:@"savedPasscode"] != nil)
    {
        NSData *passcodeData = [prefs[@"savedPasscode"] AES256DecryptWithKey:getUDID()];
        [LibPass sharedInstance].devicePasscode = [NSString stringWithUTF8String:[[[NSString alloc] initWithData:passcodeData encoding:NSUTF8StringEncoding] UTF8String]];
    }
}
