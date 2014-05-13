#ifdef _LIBPASS_INTERNAL
// MobileGestalt stuff for UDID
extern "C" CFPropertyListRef MGCopyAnswer(CFStringRef property);

// returns the device's UDID. Because we are in SpringBoard this works
NSString* getUDID()
{
    NSString *udid = (__bridge NSString*)MGCopyAnswer(CFSTR("UniqueDeviceID"));
    return udid;
}
#endif

@interface SBUserAgent
- (void)lockAndDimDevice;
+ (id)sharedUserAgent;
@end

@interface SBDeviceLockController
- (BOOL)attemptDeviceUnlockWithPassword:(id)fp8 appRequested:(BOOL)fp12;
- (BOOL)isPasscodeLocked;
+ (id)sharedController;
- (BOOL)deviceHasPasscodeSet;
@end

@interface SBLockScreenManager
- (BOOL)attemptUnlockWithPasscode:(id)fp8;
- (void)_finishUIUnlockFromSource:(int)fp8 withOptions:(id)fp12;
- (void)unlockUIFromSource:(int)fp8 withOptions:(id)fp12;
- (BOOL)isUILocked;
@end

@interface BBBulletinRequest : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *sectionID;
@end

@interface SBBulletinBannerController : NSObject
+ (SBBulletinBannerController *)sharedInstance;
- (void)observer:(id)observer addBulletin:(BBBulletinRequest *)bulletin forFeed:(int)feed;
@end

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


