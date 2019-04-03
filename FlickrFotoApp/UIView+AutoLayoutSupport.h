//
//  UIView+AutoLayoutSupport.h
//  ZaccoConference
//
//  Created by Kristoffer Anger on 2018-09-13.
//  Copyright © 2018 Kristoffer Anger. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LayoutPosition) {
    LayoutPositionCenter,
    LayoutPositionTop,
    LayoutPositionBottom,
    LayoutPositionLeft,
    LayoutPositionRight,
    LayoutPositionEdgeToEdge,
};

typedef NS_ENUM(NSInteger, LayoutDimension) {
    LayoutDimensionHorizontal,
    LayoutDimensionVertical
};

@interface UIView (AutoLayoutSupport)

/*
 ----------------------------------
 auto layout methods for superview
 ----------------------------------
 */

- (void)addSubviewPinnedToEdges:(UIView *)subview;

- (void)addSubview:(UIView *)subview pinToXPosition:(LayoutPosition)xPosition withDistance:(CGFloat)xSpace pinToYPosition:(LayoutPosition)yPosition withDistance:(CGFloat)ySpace;


/*
 ----------------------------------
 auto layout methods for subview
 ----------------------------------
 */

- (void)pinToEdges;

- (void)pinToPosition:(LayoutPosition)layoutPosition inDimension:(LayoutDimension)layoutDimension withLeadingDistance:(CGFloat)leading trailingDistance:(CGFloat)trailing;

@end

NS_ASSUME_NONNULL_END
