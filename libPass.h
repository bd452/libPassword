#import "headers.h"

@protocol LibPassDelegate <NSObject>
@optional
// Used to allow basic detection of different passcodes
-(void)passwordWasEntered:(NSString*)password;
// Used during shouldAllowPasscode: to check if the passcode is "correct"
-(BOOL)shouldAllowPasscode:(NSString*)password;
@end

@interface LibPass : NSObject
{
    NSMutableArray *delegates;
}
// This is probably a really, really bad idea...
@property (nonatomic, retain) NSString* devicePasscode;
@property (nonatomic) BOOL isPasscodeOn;

+ (instancetype) sharedInstance;

// Registers a delegate for eitehr shouldAllowPasscode and/or passwordWasEnteredHandler
- (void) registerDelegate:(id)delegate;
// Deregisters a delegate for eitehr shouldAllowPasscode and/or passwordWasEnteredHandler
- (void) deregisterDelegate:(id)delegate;
- (BOOL) shouldAllowPasscode:(NSString*)passcode;
- (void) passwordWasEnteredHandler:(NSString *)password;
// Toggles whether the passcode should be temporarily bypassed
- (void) togglePasscode;
// Sets whether the passcode should be temporarily bypassed
- (void) setPasscodeToggle:(BOOL)enabled;
// Unlocks, bypassing the passcode if 'enabled' is YES
- (void) unlockWithCodeEnabled:(BOOL)enabled;
// Locks, setting the passcodeToggle to the enabled flag
- (void) lockWithCodeEnabled:(BOOL)enabled;
@end


