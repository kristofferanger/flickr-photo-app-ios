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
    LayoutStyleGrid,
    LayoutStyleList
};

@interface RootViewController : UIViewController

@property (nonatomic, readonly) LayoutStyle style;

- (instancetype)initWithStyle:(LayoutStyle)style;

@end

NS_ASSUME_NONNULL_END
