//
//  UIView+AutoLayoutSupport.m
//  ZaccoConference
//
//  Created by Kristoffer Anger on 2018-09-13.
//  Copyright © 2018 Kristoffer Anger. All rights reserved.
//

#import "UIView+AutoLayoutSupport.h"

#define HIGH_PRIORITY 751

@implementation UIView (AutoLayoutSupport)

- (void)addSubviewPinnedToEdges:(UIView *)subview {
    [self addSubview:subview pinToXPosition:LayoutPositionEdgeToEdge withDistance:0 pinToYPosition:LayoutPositionEdgeToEdge withDistance:0];
}


- (void)addSubview:(UIView *)subview pinToXPosition:(LayoutPosition)xPosition withDistance:(CGFloat)xSpace pinToYPosition:(LayoutPosition)yPosition withDistance:(CGFloat)ySpace {
    
    // add subview
    [self addSubview:subview];
    
    //add constraints on subview
    [subview pinToXPosition:xPosition withDistance:xSpace pinToYPosition:yPosition withDistance:ySpace];
}


- (void)pinToXPosition:(LayoutPosition)xPosition withDistance:(CGFloat)xSpace pinToYPosition:(LayoutPosition)yPosition withDistance:(CGFloat)ySpace {

    // add horizontal constraints
    [self pinToPosition:xPosition inDimension:LayoutDimensionHorizontal withLeadingDistance:xSpace trailingDistance:xSpace];

    // add vertical constraints
    [self pinToPosition:yPosition inDimension:LayoutDimensionVertical withLeadingDistance:ySpace trailingDistance:ySpace];
}


- (void)pinToPosition:(LayoutPosition)layoutPosition inDimension:(LayoutDimension)layoutDimension withLeadingDistance:(CGFloat)leading trailingDistance:(CGFloat)trailing {
    
    // enable constraint changes
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    // calculate size and spring values
    CGFloat aspectValue, spring, superAspectValue;
    NSString *visualFormat = nil;
    
    if (layoutDimension == LayoutDimensionHorizontal) {
        
        // horisontal aspect and spring - calculate from width values
        aspectValue = MAX(self.bounds.size.width, self.intrinsicContentSize.width);
        superAspectValue = MAX(self.superview.bounds.size.width, self.superview.intrinsicContentSize.width);
        spring = MAX(0, (superAspectValue - aspectValue)/2);
        visualFormat = @"H:";
    }
    else {
        // vertical aspect and spring - calculate from height values
        aspectValue = MAX(self.bounds.size.height, self.intrinsicContentSize.height);
        superAspectValue = MAX(self.superview.bounds.size.height, self.superview.intrinsicContentSize.height);
        spring = MAX(0, (superAspectValue - aspectValue)/2);
        visualFormat = @"V:";
    }
    
    // create visual format
    switch (layoutPosition) {
        case LayoutPositionCenter:
            visualFormat = [visualFormat stringByAppendingString:@"|-spring-[view(aspectValue@highPriority)]-spring-|"];
            break;
        case LayoutPositionTop:
        case LayoutPositionLeft:
            visualFormat = [visualFormat stringByAppendingString:@"|-leading@highPriority-[view(>=aspectValue)]"];
            break;
        case LayoutPositionBottom:
        case LayoutPositionRight:
            visualFormat = [visualFormat stringByAppendingString:@"[view(>=aspectValue)]-trailing@highPriority-|"];
            break;
        case LayoutPositionEdgeToEdge:
            visualFormat = [visualFormat stringByAppendingString:@"|-leading@highestPriority-[view(>=aspectValue)]-trailing@highPriority-|"];
            break;
    }
    
    // set parameters
    NSDictionary *views = [NSDictionary dictionaryWithObjectsAndKeys:self, @"view", nil];
    NSDictionary *metrics = @{@"aspectValue": [NSNumber numberWithFloat:aspectValue],
                              @"leading": [NSNumber numberWithFloat:leading],
                              @"trailing": [NSNumber numberWithFloat:trailing],
                              @"spring": [NSNumber numberWithFloat:spring],
                              @"highPriority": [NSNumber numberWithInteger:HIGH_PRIORITY],
                              @"highestPriority": [NSNumber numberWithInteger:HIGH_PRIORITY+1]
                              };
    NSLayoutFormatOptions options = kNilOptions;
    
    // create constraints with paramters
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormat options:options metrics:metrics views:views];
    
    // activate constraints
    [NSLayoutConstraint activateConstraints:constraints];
}

@end


