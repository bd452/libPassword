#import "libPass.h"
#define _LIBPASS_INTERNAL
#import "libPass_compat.h"
#undef _LIBPASS_INTERNAL

@implementation libPass
@synthesize delegate;

+(void)passwordWasEnteredHandler:(NSString *)password
{
    [[LibPass sharedInstance] passwordWasEnteredHandler:password];
}

+ (void)togglePasscode
{
    [[LibPass sharedInstance] togglePasscode];
}

+ (BOOL)toggleValue
{
    return ![LibPass sharedInstance].isPasscodeOn;
}

+ (void)setPasscodeToggle:(BOOL)enabled
{
    [[LibPass sharedInstance] setPasscodeToggle:enabled];
}

+ (BOOL)isPasscodeEntered
{
    return [LibPass sharedInstance].devicePasscode != nil;
}

+ (BOOL)isPasscodeForced
{
    return ![LibPass sharedInstance].isPasscodeOn;
}

+ (void)setIsPasscodeForced:(BOOL)value
{
    [[LibPass sharedInstance] setPasscodeToggle:value];
}

+ (void)registerForEvent:(NSString *)event fromSender:(NSString *)sender
{
    // always has been just an empty stub...
}

+ (void)unlockWithCodeEnabled:(BOOL)enabled
{
    [[LibPass sharedInstance] unlockWithCodeEnabled:enabled];
}

+ (void)lockWithCodeEnabled:(BOOL)enabled
{
    [[LibPass sharedInstance] lockWithCodeEnabled:enabled];
}

+ (void)respringAfterDelay:(int)seconds
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		system("killall -9 backboardd");
	});
}

@end