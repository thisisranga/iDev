//
//  NSString+HexColor.m


#import "NSString+HexColor.h"


@implementation NSString (HexColor)

-(UIColor *)getHexColor
{
	NSString *newString = nil;
	if ([self hasPrefix:@"#"]) 
	{
		newString = [self substringFromIndex:1];
	}
	else if([self hasPrefix:@"0x"])
	{
		newString = [self substringFromIndex:2];
	}
	
	if([self length] ==6)
		newString = self;
	
	// wrong string so retunrn a defalut white color
	if ([newString length] !=6) 
	{
		return [UIColor clearColor];
	}
	
	NSRange range;  
    range.location = 0;  
    range.length = 2;  
    
	NSString *rString = [newString substringWithRange:range];  
	
    range.location = 2;  
    NSString *gString = [newString substringWithRange:range];  
	
    range.location = 4;  
    NSString *bString = [newString substringWithRange:range];  
	unsigned int r, g, b;  
    [[NSScanner scannerWithString:rString] scanHexInt:&r];  
    [[NSScanner scannerWithString:gString] scanHexInt:&g];  
    [[NSScanner scannerWithString:bString] scanHexInt:&b];  
	
	
    return [UIColor colorWithRed:((float) r / 255.0f)  
                           green:((float) g / 255.0f)  
                            blue:((float) b / 255.0f)  
                           alpha:1.0f];  
}
@end
