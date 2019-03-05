//
//  UIColor+ThemeColors.h
//  FlickrFotoApp
//
//  Created by Kristoffer Anger on 2019-03-03.
//  Copyright © 2019 kriang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *kBackgroundGray = @"#d5d5d5";
static NSString *kBackgroundLightGray = @"#f5f5f5";
static NSString *kTextGray = @"#808080";
static NSString *kKnowitGreen = @"#3F8D7D";

@interface UIColor (ThemeColors)

+ (UIColor *)colorFromHexString:(NSString *)hexString;
- (UIColor *)lighten:(CGFloat)value;
- (UIImage *)imageWithSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
