//
//  URLImage.m
//  FlickrFotoApp
//
//  Created by Kristoffer Anger on 2019-03-04.
//  Copyright © 2019 kriang. All rights reserved.
//

#import "URLImage.h"

@implementation URLImage

+ (NSURLSessionDataTask *)imageURL:(NSString *)imageURL withCompletion:(void (^)(UIImage *image, NSError *error))completion {
    
    // create cache path
    NSString *imageName = imageURL.lastPathComponent;
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *cachedImageDataPath = [cachesPath stringByAppendingPathComponent:imageName];
    
    // check if image exists in caches already
    if ([[NSFileManager defaultManager]fileExistsAtPath:cachedImageDataPath]) {
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:cachedImageDataPath]];
        completion(image, nil);
        return nil;
    }
    else {
        // fetch new image
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
        request.timeoutInterval = 6;
        NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
            
            if (data == nil) {
                completion(nil, error);
            }
            else {
                UIImage *image = nil;
                @try {
                    image = [UIImage imageWithData:data];
                }
                @catch (NSException *exception) {
                    NSLog(@"Image data in bad format");
                }
                @finally {
                    
                    if (image == nil) {
                        completion(nil, [NSError errorWithDomain:@"ImageDataFormatError" code:10000 userInfo:nil]);
                    }
                    else {
                        // store image in cache
                        if (![[NSFileManager defaultManager] fileExistsAtPath:cachedImageDataPath]) {
                            [data writeToFile:cachedImageDataPath atomically:YES];
                        }
                        // return on main thread
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(image, nil);
                        });
                    }
                }
            }
        }];
        [dataTask resume];
        return dataTask;
    }
}



@end
