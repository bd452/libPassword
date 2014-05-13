#import "libPass.h"

// This is entirely for backwards compatibility.
// DO NOT begin using it.

#ifndef _LIBPASS_INTERNAL
__deprecated
#endif
@protocol libPassEvents <NSObject>
@optional

-(void)passwordWasEntered:(NSString *)password;

@end


#ifndef _LIBPASS_INTERNAL
__deprecated
#endif
@interface libPass : NSObject <libPassEvents> {
    
	id <libPassEvents> delegate;
    
}
@property (retain) id delegate;
+(void)passwordWasEnteredHandler:(NSString *)password;
//+ (void)passwordEntered:(NSString *)password;
+ (void)togglePasscode;
+ (BOOL)toggleValue;
+(void)setPasscodeToggle:(BOOL)enabled;
+ (BOOL)isPasscodeEntered;
//+ (BOOL)checkPrefsFileIsGood;
//+ (NSDictionary *)libPassPrefs;
+ (BOOL)isPasscodeForced;
+ (void)setIsPasscodeForced:(BOOL)value;
//Event can be "unlockEvent", "toggleEvent", or "lockEvent", respectively.
//The tweak won't register your actions without using this
+(void)registerForEvent:(NSString *)event fromSender:(NSString *)sender;
+(void)unlockWithCodeEnabled:(BOOL)enabled;
+(void)lockWithCodeEnabled:(BOOL)enabled;
+(void)respringAfterDelay:(int)seconds;

//@property (nonatomic) BOOL isPasscodeForced;
@end