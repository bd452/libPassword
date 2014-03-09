
#import "libPass.h"



NSString *passCode = nil;
NSString *decodedString = nil;

%hook SBLockScreenView

- (void)setPasscodeView:(id)fp8 {
	
	%orig;
	
	
		
	

	
	if (isLockedUnsecure) {
		
	UIView *passcodeView = MSHookIvar<UIView *>(self, "_passcodeView");
		NSLog(@"%@", passcodeView.subviews);
		UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 568.0)];
		view1.alpha = 0.4;
		view1.autoresizesSubviews = YES;
		view1.backgroundColor = [UIColor blackColor];
		view1.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	//SEL setCodeAlpha = NSSelectorFromString(@"setHidden:isLockedUnsecure:")
	
	//passcodeView.subviews.hidden = isLockedUnsecure;
	//UIView *backgroundView = [[passcodeView.subviews objectAtIndex:1] copy];

		//[passcodeView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
		[[passcodeView.subviews objectAtIndex:2] removeFromSuperview];
		[[passcodeView.subviews objectAtIndex:3] removeFromSuperview];
		[[passcodeView.subviews objectAtIndex:4] removeFromSuperview];
		[[passcodeView.subviews objectAtIndex:5] removeFromSuperview];
		[[passcodeView.subviews objectAtIndex:6] removeFromSuperview];
		//[passcodeView addSubview:backgroundView];
		//[passcodeView addSubview:view1];
		//[passcodeView release];
		
	}

}



%end


%hook SBLockScreenManager

-(BOOL)isUILocked {
	isLocked = %orig;
	return %orig;
}

- (void)unlockUIFromSource:(int)fp8 withOptions:(id)fp12 {
	isUsingAction = NO;

	%orig;
}

- (BOOL)attemptUnlockWithPasscode:(id)fp8 {
	
	
	[libPass passwordWasEnteredHandler:fp8];
	if (isUsingAction || isLockedUnsecure || isToggled) {
		//NSDictionary *prefs=[[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.bd452.libPass.plist"];
		
		//tweakEnabled = [[prefs objectForKey:@"tweakIsEnabled"] boolValue];
		//NSString *savedCode = [NSString stringWithFormat:@"%@",[prefs objectForKey:@"savedPasscode"]];
		//fp8 = [NSString stringWithFormat:@"%@",[prefs objectForKey:@"savedPasscode"]];
		fp8 = [NSString stringWithFormat:@"%@",decodedString];
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

-(BOOL)isPasscodeLocked {
	if (!isLocked || isLockedUnsecure || isToggled) {
		return NO;
	}
	else {
		return deviceCodeIsOn;
	}
}
-(BOOL)deviceHasPasscodeSet {
	deviceCodeIsOn = %orig;
	return %orig;
}

%end

/*%hook SBUserAgent


-(void)lockAndDimDevice {
	isLockedUnsecure = NO;
	isLocked = YES;
	%orig;
}


%end*/

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
		[(SBLockScreenManager *)[%c(SBLockScreenManager) sharedInstance] unlockUIFromSource:1 withOptions:nil];
		[pool drain];
	}
	
	if (!enabled) {
		isUsingAction = YES;
		[(SBLockScreenManager *)[%c(SBLockScreenManager) sharedInstance] _finishUIUnlockFromSource:1 withOptions:nil];
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
