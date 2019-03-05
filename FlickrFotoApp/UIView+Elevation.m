//
//  UIView+Elevation.m
//  BlogProject
//
//  Created by Kristoffer Anger on 2018-10-03.
//  Copyright © 2018 Kristoffer Anger. All rights reserved.
//

#import "UIView+Elevation.h"

@implementation UIView (Elevation)


- (void)elevate:(CGFloat)elevation {
    [self elevate:elevation shadowOffset:CGSizeMake(0, 0)];
}

- (void)elevate:(CGFloat)elevation shadowOffset:(CGSize)size {
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = size;
    self.layer.shadowRadius = elevation;
    self.layer.shadowOpacity = 0.4;
}

@end
