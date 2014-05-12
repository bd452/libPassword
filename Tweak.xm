#import "libPass.h"

%hook SBLockScreenViewControllerBase
- (void)_transitionWallpaperFromLock {
	if (isLockedUnsecure) {
		[(SBLockScreenManager *)[%c(SBLockScreenManager) sharedInstance] attemptUnlockWithPasscode:[NSString stringWithFormat:@"%@",decodedString]];
	}
    
	%orig;
}
%end

%hook SBLockScreenManager

-(BOOL)isUILocked {
	isLocked = %orig;
	NSLog(@"SBLock Screen Manager: %d", %orig);
	return %orig;
}

- (void)unlockUIFromSource:(int)fp8 withOptions:(id)fp12 {
	isUsingAction = NO;
	%log;
	%orig;
}

- (BOOL)attemptUnlockWithPasscode:(id)fp8 {
    
    %orig;
	[libPass passwordWasEnteredHandler:fp8];
	if (isUsingAction || isLockedUnsecure || isToggled) {
		return 	[(SBLockScreenManager *)[%c(SBLockScreenManager) sharedInstance] attemptUnlockWithPasscode:[NSString stringWithFormat:@"%@",decodedString]];
	}
    return %orig;
}

- (void)_finishUIUnlockFromSource:(int)fp8 withOptions:(id)fp12 {
	[libPass setIsPasscodeForced:NO];
    isLockedUnsecure = NO;
	%orig;
}

%end


%hook SBDeviceLockController

- (BOOL)attemptDeviceUnlockWithPassword:(id)fp8 appRequested:(BOOL)fp12 {
    
    NSLog(@"attempt device unlock with password %d", %orig);
	//NSLog(@"%@",passCode);
    
	if (isUsingAction || isLockedUnsecure || isToggled) {
		//NSDictionary *prefs=[[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.bd452.libPass.plist"];
		//tweakEnabled = [[prefs objectForKey:@"tweakIsEnabled"] boolValue];
		//NSString *savedCode = [NSString stringWithFormat:@"%@",[prefs objectForKey:@"savedPasscode"]];
		fp8 = [NSString stringWithFormat:@"%@",decodedString];
		//fp8 = [NSString stringWithFormat:@"%@",[prefs objectForKey:@"savedPasscode"]];
		//[prefs release];
		//[savedCode release];
	}
    
    
	return %orig;
    
}

-(BOOL)deviceHasPasscodeSet {
	deviceCodeIsOn = %orig;
	NSLog(@"SBDevice Lock Controller: %d", %orig);
	return %orig;
}

%end

%hook SBUserAgent
- (BOOL)deviceIsPasscodeLocked {
    
	NSLog(@"SBUserAgent deviceIsPasscodeLocked: %d", %orig);
	if (isLockedUnsecure || isToggled) {
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
	NSDictionary *prefs=[[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.bd452.libPass.plist"];
	passCode = [NSString stringWithFormat:@"%@",[prefs objectForKey:@"savedPasscode"]];
	NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:[prefs objectForKey:@"savedPasscode"] options:0];
	decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/com.bd452.libPass.plist"];
	//[prefs release];
	if (!fileExists) {
        
		NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/libPass/doNotDelete.plist"];
		//[tempDict setObject:@"" forKey:@"savedPasscode"];
		[tempDict writeToFile:@"/var/mobile/Library/Preferences/com.bd452.libPass.plist" atomically:YES];
	}
}
