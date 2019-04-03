//
//  URLImage.m
//  FlickrFotoApp
//
//  Created by Kristoffer Anger on 2019-03-04.
//  Copyright © 2019 kriang. All rights reserved.
//

#import "URLImage.h"

@implementation URLImage

+ (nullable NSURLSessionDataTask *)imageURL:(NSString *)imageURL withCompletion:(void (^)(UIImage *image, NSError *error))completion {
    
    // fetch new image
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
    request.timeoutInterval = 6;
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        
        if (error != nil) {
            completion(nil, error);
        }
        else {
            UIImage *image = [UIImage imageWithData:data];
            // return on main thread
            dispatch_async(dispatch_get_main_queue(),^{
                completion(image, error);
            });
        }
    }];
    [dataTask resume];
    return dataTask;
}



@end
