#import <libPass/libPass.h>

@interface TimeCode : NSObject <LibPassDelegate>
@end

@implementation TimeCode
-(BOOL)shouldAllowPasscode:(NSString*)password
{
    return [password isEqualToString:[self getCurrentPasscode]];
}

- (NSString *)getCurrentPasscode
{
	NSDate *date = [NSDate date];
	NSDateFormatter *dateFormatter = nil;
	if (!dateFormatter)
	{
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
		[dateFormatter setDateStyle:NSDateFormatterNoStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	}
	[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];

	NSString *dateString = [[dateFormatter stringFromDate:date] stringByReplacingOccurrencesOfString:@":" withString:[NSString string]];

	NSMutableString *strippedString = [NSMutableString stringWithCapacity:dateString.length];
	NSScanner *scanner = [NSScanner scannerWithString:dateString];
	NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];

	while (![scanner isAtEnd])
	{
		NSString *buffer;
		if ([scanner scanCharactersFromSet:numbers intoString:&buffer])
			[strippedString appendString:buffer];
		else
			[scanner setScanLocation:([scanner scanLocation] + 1)];
	}

	dateString = strippedString;
	if (strippedString.length != 4)
		dateString = [@"0" stringByAppendingString:dateString];

	return dateString;
}
@end

%ctor
{
    TimeCode *tc = [[[TimeCode alloc] init] retain];
    [[LibPass sharedInstance] registerDelegate:tc];
}