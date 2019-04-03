//
//  ListViewController.h
//  FlickrFotoApp
//
//  Created by Kristoffer Anger on 2019-03-03.
//  Copyright © 2019 kriang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LayoutStyle) {
    LayoutStyleUndefined,
    LayoutStyleGrid,
    LayoutStyleList
};

@protocol PhotoViewControllerDelegate <NSObject>

- (void)toggleMenuPage;
- (void)handleOpenMenuPanGesture:(UIPanGestureRecognizer *)panGesture;
- (void)handleCloseMenuPanGesture:(UIPanGestureRecognizer *)panGesture;

@end

@interface PhotoViewController : UIViewController  

@property (nonatomic, weak) id <PhotoViewControllerDelegate> delegate;

@property (nonatomic) LayoutStyle style;
@property (nonatomic, strong) UIView *coverView; // hidden by default

@end

NS_ASSUME_NONNULL_END
