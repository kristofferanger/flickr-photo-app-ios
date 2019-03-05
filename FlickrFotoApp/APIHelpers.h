//
//  APIHelpers.h
//  MyRobotFriends
//
//  Created by Kristoffer Anger on 2018-03-24.
//  Copyright © 2018 Kristoffer Anger. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface APIHelpers : NSObject

@property (class, nonatomic) NSTimeInterval defaultTimeoutInterval;

+ (NSURLSessionDataTask *)makeRequestWithEndpoint:(nonnull NSString *)endpoint queryParameters:(nullable NSDictionary *)parameters completion:(void (^)(NSDictionary *response))completion;

@end

NS_ASSUME_NONNULL_END
