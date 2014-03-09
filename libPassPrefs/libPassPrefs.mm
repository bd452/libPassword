#import <Preferences/Preferences.h>
#import <CommonCrypto/CommonCryptor.h>
#import <RevMobAds/RevMobAds.h>




@interface libPassPrefsListController: PSListController <UIActionSheetDelegate> {

	CGSize theContentSize;
	PSSpecifier *passcodeBox;
}
-(void)whatIsLove;
@end


int whatIsLoveInt = 0;


@implementation libPassPrefsListController


#pragma mark specifiers

- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"libPassPrefs" target:self] retain];
	}
	return _specifiers;
}

#pragma mark init

-(instancetype)init {
	self = [super init];
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
		
		[RevMobAds startSessionWithAppID:@"53191b71842325aa78a3f4c7"];
		//[RevMobAds session].testingMode = RevMobAdsTestingModeWithAds;
		[[RevMobAds session] showBanner];
		
		/*passcodeBox = [self specifierForID:@"passwordCell"].target;
		
		[passcodeBox setDelegate:self];
		[passcodeBox setReturnKeyType:UIReturnKeyDone];
		[passcodeBox addTarget:self
						action:@selector(textFieldFinished:)
			  forControlEvents:UIControlEventEditingDidEndOnExit];
		
		*/
		
		
		
		
		
		// Constraint keeps ad in the center of the screen at all times.
		
		
		
		UIButton *addButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
		[addButton addTarget:self action:@selector(infoPressed:) forControlEvents:UIControlEventTouchUpInside];
		UIBarButtonItem *barButtton = [[UIBarButtonItem alloc] initWithCustomView:addButton];
		//- (void)pushNavigationItem:(UINavigationItem *)item animated:(BOOL)animated
		//NSArray *actionButtonItems = @[barButtton];
		[self.navigationItem setRightBarButtonItem:barButtton];
		
		
		
		//self.navigationItem.rightBarButtonItem = barButtton;
	}
	return self;
}

#pragma mark info button pressed

- (void)infoPressed:(UIButton *)__unused sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"libPassword: By Bryce Dougherty" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Donate", @"Twitter", @"My Website", @"What is love?", nil];
    
	//[sheet show];
    [sheet showFromBarButtonItem:[self.navigationItem rightBarButtonItem] animated:YES];
}

#pragma mark What is love?

- (void)whatIsLove {
	NSMutableString *label = [NSMutableString stringWithString:@"Baby don't hurt me"];
	switch (whatIsLoveInt) {
		case 0:
			label = [NSMutableString stringWithString:@"Baby don't hurt me"];
			whatIsLoveInt = 1;
			break;
		case 1:
			label = [NSMutableString stringWithString:@"Don't hurt me"];
			whatIsLoveInt = 2;
			break;
		case 2:
			label = [NSMutableString stringWithString:@"No more"];
			whatIsLoveInt = 3;
			break;
		case 3:
			label = [NSMutableString stringWithString:@"No more"];
			whatIsLoveInt = 4;
		default:
			whatIsLoveInt = 0;
			break;
	}
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:label message:nil delegate:self cancelButtonTitle:@"..." otherButtonTitles:nil];
    // optional - add more buttons:
    [alert show];
	[alert release];
}

#pragma mark Hash Code

- (void)hashCode:(NSString *)password {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	
	NSData *plainData = [password dataUsingEncoding:NSUTF8StringEncoding];
	NSString *base64String = [plainData base64EncodedStringWithOptions:0];

	NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.bd452.libPass.plist"];
	[tempDict setObject:base64String forKey:@"savedPasscode"];
	[tempDict writeToFile:@"/var/mobile/Library/Preferences/com.bd452.libPass.plist" atomically:YES];
	
	[pool drain];
	
	
}

#pragma mark respring popup

-(void)respringPopup {
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Save Dava"
												   message:@"You've got to respring to save your password!"
												  delegate:self
										 cancelButtonTitle:@"Oh Hell No!"
										 otherButtonTitles:@"Fine", nil];
	[alert show];
	[alert release];
	[self.view endEditing:YES];
	
}

#pragma mark alert view delegate

-(void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
        if (buttonIndex == 0){
			
        }
		else if(buttonIndex==1){
			system("killall backboardd");
        }

}

#pragma mark Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=LCLSST7FKNUYY"]];
    }
    else if (buttonIndex == 1) {
        NSString *user = @"bd452";
        
        NSArray *schemes = @[[NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=%@", user]], [NSURL URLWithString:[NSString stringWithFormat:@"tweetbot://%@/timeline", user]], [NSURL URLWithString:[NSString stringWithFormat:@"twitterrific:///profile?screen_name=%@", user]]];
        
        for (NSURL *URL in schemes) {
            if ([[UIApplication sharedApplication] canOpenURL:URL]) {
                [[UIApplication sharedApplication] openURL:URL];
                return;
            }
        }
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/%@", user]]];
        
    }
    else if (buttonIndex == 2) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://bd452.com"]];
    }
	else if (buttonIndex == 3) {
		[self whatIsLove];
	}
    
}


-(id)initForContentSize:(CGSize)contentSize
{
	theContentSize = contentSize;
	return [super initForContentSize:contentSize];
}

#pragma mark dealloc

-(void)dealloc {
	[[RevMobAds session] hideBanner];
	[super dealloc];
}

/*-(void)_showKeyboard {
	[super _showKeyboard];
	[[RevMobAds session] hideBanner];
}
*/
- (void)keyboardDidShow:(NSNotification *)note
{
	[[RevMobAds session] hideBanner];
	
    /* move your views here */
}
- (void)keyboardDidHide:(NSNotification *)note
{
	[[RevMobAds session] showBanner];
    /* move your views here */
}
- (IBAction)textFieldFinished:(id)sender
{
    [sender resignFirstResponder];
}


@end

// vim:ft=objc