//
//  UIView+Elevation.h
//  BlogProject
//
//  Created by Kristoffer Anger on 2018-10-03.
//  Copyright © 2018 Kristoffer Anger. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Elevation)

- (void)elevate:(CGFloat)elevation;

- (void)elevate:(CGFloat)elevation shadowOffset:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
