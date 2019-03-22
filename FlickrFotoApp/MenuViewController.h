//
//  MenuViewController.h
//  FlickrFotoApp
//
//  Created by Kristoffer Anger on 2019-03-01.
//  Copyright © 2019 kriang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MenuViewController;
@protocol MenuViewControllerDelegate <NSObject>

- (void)menuViewController:(MenuViewController *)menu dismissedWithSelectedInfo:(nullable NSDictionary *)info;

@end

@interface MenuViewController : UIViewController

@property (nonatomic, weak) id <MenuViewControllerDelegate> delegate;

- (instancetype)initWithButtonInfoArray:(NSArray *)buttons;

@end

NS_ASSUME_NONNULL_END
