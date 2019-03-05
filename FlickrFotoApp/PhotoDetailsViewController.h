//
//  PhotoDetailsViewController.h
//  FlickrFotoApp
//
//  Created by Kristoffer Anger on 2019-03-05.
//  Copyright © 2019 kriang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoDetailsViewController : UIViewController

- (instancetype)initWithPhotoInfo:(NSDictionary *)photoInfo;
@end

NS_ASSUME_NONNULL_END
