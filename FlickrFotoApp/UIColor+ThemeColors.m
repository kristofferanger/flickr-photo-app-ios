//
//  UIColor+ThemeColors.m
//  FlickrFotoApp
//
//  Created by Kristoffer Anger on 2019-03-03.
//  Copyright © 2019 kriang. All rights reserved.
//

#import "UIColor+ThemeColors.h"

@implementation UIColor (ThemeColors)


+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (UIColor *)lighten:(CGFloat)value;    { //value 0 = original, 1 = white
    
    value = MAX(0, MIN(1, value));
    CGFloat r, g, b, a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    r+=(1-r)*value;
    g+=(1-g)*value;
    b+=(1-b)*value;
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}


- (UIImage *)imageWithSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [self setFill];
    UIRectFill(CGRectMake(0.0f, 0.0f, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
