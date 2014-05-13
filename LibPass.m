#import "libPass.h"
#import "headers.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <substrate.h>
#import "NSData+AES.m"
#define SETTINGS_FILE @"/var/mobile/Library/Preferences/com.bd452.libPass.plist"

@implementation LibPass
+ (id) sharedInstance
{
    // This (helps) prevent multiple instances from being created which would cause issues
    static LibPass *instance;
    if (!instance)
        instance = [[LibPass alloc] init];
    
    return instance;
}

- (id) init
{
    delegates = [[NSMutableArray alloc] init];
    self.isPasscodeOn = YES;
    self.devicePasscode = nil;
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
    
    // This shows a banner notification to the user
    // letting them know what status the passcode is in right now.
    
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

// This is used when unlocking the device and isPasscodeOn == YES to allow for
// multiple passcode to be used and the like.
// This opens the door to a large variety of possibilities.
- (BOOL) shouldAllowPasscode:(NSString*)passcode
{
    BOOL result = [passcode isEqualToString:self.devicePasscode];
    
    for (id delegate in delegates)
    {
        if (delegate && [delegate respondsToSelector:@selector(shouldAllowPasscode:)])
        {
            result = result || [delegate shouldAllowPasscode:passcode];
        }
    }
    
    return result;
}

-(BOOL) toggleValue
{
    return !self.isPasscodeOn;
}

@end
