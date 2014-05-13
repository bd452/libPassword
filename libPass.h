#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <substrate.h>
//#import <CommonCrypto/CommonCrypto.h>
#import <Security/Security.h>

NSString* getUDID()
{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
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

@interface SBLockScreenView
- (void)scrollViewDidScroll:(id)fp8;
- (void)setPasscodeView:(id)fp8;
- (id)initWithFrame:(struct CGRect)fp8;
- (void)_layoutPasscodeView;
- (void)willMoveToWindow:(id)fp8;
@end

@interface SBLockScreenViewController
-(BOOL)isPasscodeLockVisible;
@end

@interface SpringBoard
- (void)relaunchSpringBoard;
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

@interface libPass : NSObject <libPassEvents> 
@property (retain) id delegate;
@property (nonatomic, retain) NSString* devicePasscode;
@property (nonatomic) BOOL isPasscodeOn;

+ (instancetype) sharedInstance;

- (void)passwordWasEnteredHandler:(NSString *)password;
- (void)togglePasscode;
- (void)setPasscodeToggle:(BOOL)enabled;
- (void)unlockWithCodeEnabled:(BOOL)enabled;
- (void)lockWithCodeEnabled:(BOOL)enabled;
@end
