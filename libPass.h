#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <substrate.h>
//#import <CommonCrypto/CommonCrypto.h>
#import <Security/Security.h>

BOOL isUsingAction = NO;
BOOL isLockedUnsecure = NO;
BOOL hasShownAlert = NO;
BOOL isFirstUnlock = YES;
BOOL tweakEnabled = NO;
BOOL isPasscodeForced = YES;
BOOL prefsFileIsGood = NO;
BOOL deviceCodeIsOn = YES;
BOOL isLocked = YES;
BOOL isToggled = NO;
//NSString *passCode = nil;



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

@interface SBLockScreenView
- (void)scrollViewDidScroll:(id)fp8;
- (void)setPasscodeView:(id)fp8;
- (id)initWithFrame:(struct CGRect)fp8;
- (void)_layoutPasscodeView;
- (void)willMoveToWindow:(id)fp8;
@end

@interface SpringBoard
- (void)relaunchSpringBoard;
@end

@interface DevicePINController

- (void)setOldPassword:(id)arg1;

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



	


@protocol libPassEvents <NSObject>
@optional

-(void)passwordWasEntered:(NSString *)password;

@end


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

+(void)unlockWithCodeEnabled:(BOOL)enabled;
+(void)lockWithCodeEnabled:(BOOL)enabled;
+(void)respringAfterDelay:(int)seconds;

//@property (nonatomic) BOOL isPasscodeForced;
@end






