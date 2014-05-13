// MobileGestalt stuff for UDID
extern "C" CFPropertyListRef MGCopyAnswer(CFStringRef property);

// returns the device's UDID. Because we are in SpringBoard this works
NSString* getUDID()
{
    NSString *udid = (__bridge NSString*)MGCopyAnswer(CFSTR("UniqueDeviceID"));
    return udid;
}

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
-(void)passwordWasEntered:(NSString *)password;
@end

@interface LibPass : NSObject
{
    NSMutableArray *delegates;
}

@property (retain) id delegate;
// This is probably a really, really bad idea...
@property (nonatomic, retain) NSString* devicePasscode;
@property (nonatomic) BOOL isPasscodeOn;

+ (instancetype) sharedInstance;

- (void)passwordWasEnteredHandler:(NSString *)password;
- (void)togglePasscode;
- (void)setPasscodeToggle:(BOOL)enabled;
- (void)unlockWithCodeEnabled:(BOOL)enabled;
- (void)lockWithCodeEnabled:(BOOL)enabled;
@end
