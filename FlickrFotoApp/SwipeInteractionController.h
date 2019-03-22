//
//  SwipeInteractionController.h
//  FlickrFotoApp
//
//  Created by Kristoffer Anger on 2019-03-22.
//  Copyright © 2019 kriang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SwipeInteractionController : UIPercentDrivenInteractiveTransition

@property (nonatomic, weak) UIViewController *viewController;

- (instancetype)initWithViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
