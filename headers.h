@interface SBUserAgent
- (void)lockAndDimDevice;
+ (id)sharedUserAgent;
@end

@interface SBLockScreenViewController
-(void)passcodeLockViewPasscodeEntered:(id)entered;
@end

@interface SBDeviceLockController : NSObject
- (BOOL)attemptDeviceUnlockWithPassword:(id)fp8 appRequested:(BOOL)fp12;
- (BOOL)isPasscodeLocked;
+ (id)sharedController;
- (BOOL)deviceHasPasscodeSet;

// TimePasscode / Pro
- (NSString *)getCurrentPasscode;
- (NSString *)getCurrentPasscode:(NSDictionary*)arg1;
@end

@interface SBLockScreenManager
@property(readonly, assign, nonatomic) SBLockScreenViewController/*Base*/* lockScreenViewController;
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
