//
//  URLImage.h
//  FlickrFotoApp
//
//  Created by Kristoffer Anger on 2019-03-04.
//  Copyright © 2019 kriang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface URLImage : NSObject

+ (nullable NSURLSessionDataTask *)imageURL:(NSString *)imageURL withCompletion:(void (^)(UIImage *image, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
