#import <Preferences/Preferences.h>

@interface libPassPrefsListController: PSListController {
}
-(void)whatIsLove;
@end
int whatIsLoveInt = 0;
@implementation libPassPrefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"libPassPrefs" target:self] retain];
	}
	return _specifiers;
}
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
}

@end

// vim:ft=objc
