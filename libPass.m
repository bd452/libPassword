
#import "libPass.h"


#pragma mark hello
NSString *passCode = nil;
NSString *decodedString = nil;




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
		//NSDictionary *prefs=[[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.bd452.libPass.plist"];

		//tweakEnabled = [[prefs objectForKey:@"tweakIsEnabled"] boolValue];
		//NSString *savedCode = [NSString stringWithFormat:@"%@",[prefs objectForKey:@"savedPasscode"]];
		//fp8 = [NSString stringWithFormat:@"%@",[prefs objectForKey:@"savedPasscode"]];
		//fp8 = [NSString stringWithFormat:@"%@",decodedString];
		return 	[(SBLockScreenManager *)[%c(SBLockScreenManager) sharedInstance] attemptUnlockWithPasscode:[NSString stringWithFormat:@"%@",decodedString]];
				//fp8 = [NSString stringWithFormat:@"%@",[prefs objectForKey:@"savedPasscode"]];
		//[prefs release];
		//[savedCode release];

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

/*-(BOOL)isPasscodeLocked {

	if (!isLocked || isLockedUnsecure || isToggled) {
		return NO;
	}
	else {
		return deviceCodeIsOn;
	}
}
*/


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

#pragma mark libPass

@implementation libPass
//@synthesize isPasscodeForced;
@synthesize delegate;

+(void)unlockWithCodeEnabled:(BOOL)enabled {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//NSDictionary *prefs=[[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.bd452.libPass.plist"];
	//tweakEnabled = [[prefs objectForKey:@"tweakIsEnabled"] boolValue];
	//passCode = [NSString stringWithFormat:@"%@",[prefs objectForKey:@"savedPasscode"]];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/com.bd452.libPass.plist"];
	//[prefs release];
	if (fileExists) {




	if ([passCode isEqual:@""]) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"libPass" message:@"Please put a password into the libPassword preferences pane before using a libPass-enabled tweak" delegate:self cancelButtonTitle:@"Yes Sir!" otherButtonTitles:nil] autorelease];
		// optional - add more buttons:
		[alert show];
		[pool drain];
		[passCode release];
		enabled = YES;
	}

	if (enabled) {
	//	[(SBLockScreenManager *)[%c(SBLockScreenManager) sharedInstance] unlockUIFromSource:1 withOptions:nil];
	[(SBLockScreenManager *)[%c(SBLockScreenManager) sharedInstance] unlockUIFromSource:1 withOptions:nil];
		[pool drain];
	}

	if (!enabled) {
		isUsingAction = YES;
		[(SBLockScreenManager *)[%c(SBLockScreenManager) sharedInstance] attemptUnlockWithPasscode:[NSString stringWithFormat:@"%@",decodedString]];
		[pool drain];
	}
		[pool drain];
		}
	else if (!fileExists){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"libPass" message:@"Please put a password into the libPassword preferences pane before using a libPass-enabled tweak" delegate:self cancelButtonTitle:@"Yes Sir!" otherButtonTitles:nil];
		// optional - add more buttons:
		[alert show];
		[alert release];
		enabled = YES;
		[pool drain];

	}

}

+ (BOOL)isPasscodeEntered {
	return [passCode isEqual:@""];
}

+ (void)lockWithCodeEnabled:(BOOL)enabled {
	NSLog(@"Lock with code enabled: %d", enabled);
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//NSDictionary *prefs=[[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.bd452.libPass.plist"];
	//tweakEnabled = [[prefs objectForKey:@"tweakIsEnabled"] boolValue];
	//passCode = [NSString stringWithFormat:@"%@",[prefs objectForKey:@"savedPasscode"]];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/com.bd452.libPass.plist"];
	//[prefs release];
	if (fileExists) {




		if ([passCode isEqual:@""]) {
			UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"libPass" message:@"Please put a password into the libPassword preferences pane before using a libPass-enabled tweak" delegate:self cancelButtonTitle:@"Yes Sir!" otherButtonTitles:nil] autorelease];
			// optional - add more buttons:
			[alert show];
			[pool drain];
			[passCode release];
			enabled = YES;
		}

		if (enabled) {
			[(SBUserAgent *)[%c(SBUserAgent) sharedUserAgent] lockAndDimDevice];
		}

		if (!enabled) {
			[(SBUserAgent *)[%c(SBUserAgent) sharedUserAgent] lockAndDimDevice];
			isLockedUnsecure = YES;
			NSLog(@"Locked with code disabled");
			[pool drain];
		}
		[pool drain];
	}
	else if (!fileExists){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"libPass" message:@"Please put a password into the libPassword preferences pane before using a libPass-enabled tweak" delegate:self cancelButtonTitle:@"Yes Sir!" otherButtonTitles:nil];
		// optional - add more buttons:
		[alert show];
		[alert release];
		enabled = YES;
		[pool drain];

	}

}

+ (BOOL)isPasscodeForced {
    return isPasscodeForced;
}
+(void)respringAfterDelay:(int)seconds {

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		system("killall backboardd");
	});

}

+ (void)setIsPasscodeForced:(BOOL)value {
	isPasscodeForced = value;
}
+ (void)togglePasscode {
	isToggled = !isToggled;
	NSLog(@"Passcode Toggling");
	Class bulletinBannerController = objc_getClass("SBBulletinBannerController");
	Class bulletinRequest = objc_getClass("BBBulletinRequest");

	if (bulletinBannerController && bulletinRequest) {
		BBBulletinRequest *request = [[bulletinRequest alloc] init];
		request.title = @"Password";
		NSString *passcodeEnabledString = @"YES";
		if (!isToggled) { passcodeEnabledString = @"enabled"; }
		else { passcodeEnabledString = @"disabled"; }
		request.message = [NSString stringWithFormat:@"Password now %@", passcodeEnabledString];
		request.sectionID = @"com.bd452.libpass";
		[(SBBulletinBannerController *)[bulletinBannerController sharedInstance] observer:nil addBulletin:request forFeed:2];
		[request release];
		[passcodeEnabledString release];
		return;
	}




}
+(BOOL)toggleValue {
	return isToggled;
}

+(void)setPasscodeToggle:(BOOL)enabled {
	isToggled = enabled;
	/*
	Class bulletinBannerController = objc_getClass("SBBulletinBannerController");
	Class bulletinRequest = objc_getClass("BBBulletinRequest");

	if (bulletinBannerController && bulletinRequest) {
		BBBulletinRequest *request = [[bulletinRequest alloc] init];
		request.title = @"Password";
		NSString *passcodeEnabledString = @"YES";
		if (!isToggled) { passcodeEnabledString = @"enabled"; }
		else { passcodeEnabledString = @"disabled"; }
		request.message = [NSString stringWithFormat:@"Password now %@", passcodeEnabledString];
		request.sectionID = @"com.bd452.libpass";
		[(SBBulletinBannerController *)[bulletinBannerController sharedInstance] observer:nil addBulletin:request forFeed:2];
		[request release];
		[passcodeEnabledString release];
		return;
	}
*/
}
/*+(void)passwordEntered:(NSString *)password {
	libPass *theInstance = [[self alloc]init];
	[theInstance passwordWasEnteredHandler:password];
	[theInstance release];
}
 */
+(void)passwordWasEnteredHandler:(NSString *)password {

	[[[[self alloc]init] delegate] passwordWasEntered:password];




}
+(void)registerForEvent:(NSString *)event fromSender:(NSString *)sender {
	if ([event isEqual:@"unlockEvent"]) {
		registered_bypassAction = YES;
	}
	if ([event isEqual:@"toggleEvent"]) {
		registered_toggleAction = YES;
	}
	if ([event isEqual:@"lockEvent"]) {
		registered_ttpAction = YES;
	}
	else {
		NSLog(@"You tried to register a libPassword event that doesn't exist D:");
	}


}



@end



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
		[tempDict release];
	}

	[prefs release];
	[decodedData release];
}
