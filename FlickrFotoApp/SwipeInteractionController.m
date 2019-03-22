//
//  SwipeInteractionController.m
//  FlickrFotoApp
//
//  Created by Kristoffer Anger on 2019-03-22.
//  Copyright © 2019 kriang. All rights reserved.
//

#import "SwipeInteractionController.h"

@implementation SwipeInteractionController

- (instancetype)initWithViewController:(UIViewController *)viewController {
    
    self = [super init];
    if (self) {
        self.viewController = viewController;
    }
    return self;
}

@end
