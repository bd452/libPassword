#import "libPass.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <substrate.h>
#import "NSData+AES.m"
#define SETTINGS_FILE @"/var/mobile/Library/Preferences/com.bd452.libPass.plist"

@implementation libPass

+ (id) sharedInstance
{
    static libPass *instance;
    if (!instance)
        instance = [[libPass alloc] init];
        
    return instance;
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
		if ([libPass sharedInstance].isPasscodeOn)
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
    if (self.delegate)
        [self.delegate passwordWasEntered:password];
}
@end

// *****************************************************************************
// SpringBoard hooks start here
// *****************************************************************************

%hook SBLockScreenViewControllerBase
- (void)_transitionWallpaperFromLock {
	if ([libPass sharedInstance].isPasscodeOn == NO) {
		[(SBLockScreenManager *)[%c(SBLockScreenManager) sharedInstance] attemptUnlockWithPasscode:[NSString stringWithFormat:@"%@",[libPass sharedInstance].devicePasscode]];
	}
	%orig;
}
%end

%hook SBLockScreenManager
- (BOOL)attemptUnlockWithPasscode:(id)fp8 {
    %orig;

	[[libPass sharedInstance] passwordWasEnteredHandler:fp8];

	if ([libPass sharedInstance].isPasscodeOn == NO)
    {
		return 	%orig([libPass sharedInstance].devicePasscode);
	}
    return %orig;
}

- (void)_finishUIUnlockFromSource:(int)fp8 withOptions:(id)fp12 {
	[[libPass sharedInstance] setPasscodeToggle:YES];
	%orig;
}

%end

%hook SBDeviceLockController
- (BOOL)attemptDeviceUnlockWithPassword:(id)arg1 appRequested:(BOOL)arg2 {
    BOOL result = %orig([libPass sharedInstance].isPasscodeOn ? arg1 : [libPass sharedInstance].devicePasscode, arg2);

    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:SETTINGS_FILE];
    if (!prefs)
        prefs = [[NSMutableDictionary alloc] init];

    if ([arg1 isKindOfClass:[NSString class]] && ![prefs[@"devicePasscode"] isKindOfClass:[NSData class]] && result)
    {
        [libPass sharedInstance].devicePasscode = arg1;
        [prefs setObject:[[arg1 dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptWithKey:getUDID()] forKey:@"devicePasscode"];
        [prefs writeToFile:SETTINGS_FILE atomically:YES];
    }
    else if ([prefs[@"devicePasscode"] isKindOfClass:[NSData class]])
    {
        NSData *passcodeData = [prefs[@"devicePasscode"] AES256DecryptWithKey:getUDID()];
        [libPass sharedInstance].devicePasscode = [NSString stringWithUTF8String:[[[NSString alloc] initWithData:passcodeData encoding:NSUTF8StringEncoding] UTF8String]];
            
        if (result)
        {
            if ([libPass sharedInstance].devicePasscode != arg1 && [arg1 isKindOfClass:[NSString class]])
            {
                [libPass sharedInstance].devicePasscode = arg1;
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
    else if (result && [libPass sharedInstance].devicePasscode != nil && [libPass sharedInstance].devicePasscode != arg1 && [arg1 isKindOfClass:[NSString class]])
    {
        NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:SETTINGS_FILE];
        if (!prefs)
            prefs = [[NSMutableDictionary alloc] init];
        [libPass sharedInstance].devicePasscode = arg1;
        [prefs setObject:[[arg1 dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptWithKey:getUDID()] forKey:@"devicePasscode"];
        [prefs writeToFile:SETTINGS_FILE atomically:YES];
    }

    return result;
}

%end

%hook SBUserAgent
- (BOOL)deviceIsPasscodeLocked {
	NSLog(@"SBUserAgent deviceIsPasscodeLocked: %d", %orig);
	if ([libPass sharedInstance].isPasscodeOn == NO) {
		NSLog(@"device is NOT passcode locked");
		return NO;
	}
	else {
		NSLog(@"device is origin");
		return %orig;
	}
}
%end

%ctor
{
	NSDictionary *prefs=[[NSDictionary alloc] initWithContentsOfFile:SETTINGS_FILE];
    if ([prefs objectForKey:@"savedPasscode"] != nil)
    {
        NSData *passcodeData = [prefs[@"savedPasscode"] AES256DecryptWithKey:getUDID()];
        [libPass sharedInstance].devicePasscode = [NSString stringWithUTF8String:[[[NSString alloc] initWithData:passcodeData encoding:NSUTF8StringEncoding] UTF8String]];
    }
}
