//
//  MenuViewController.h
//  FlickrFotoApp
//
//  Created by Kristoffer Anger on 2019-03-01.
//  Copyright © 2019 kriang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MenuViewController : UIViewController <PhotoViewControllerDelegate>

- (instancetype)initWithButtonInfoArray:(NSArray *)buttons;

@end

NS_ASSUME_NONNULL_END
