//
//  AppDelegate.m
//  FlickrFotoApp
//
//  Created by Kristoffer Anger on 2019-02-22.
//  Copyright © 2019 kriang. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "UIColor+ThemeColors.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // create root view controller
    RootViewController *root = [[RootViewController alloc]initWithStyle:LayoutStyleGrid];

    // add to navigation controller
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:root];
    navigationController.navigationBar.barTintColor = [UIColor colorFromHexString:kKnowitGreen];
    navigationController.navigationBar.tintColor = [UIColor whiteColor];
    navigationController.navigationBar.largeTitleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    navigationController.navigationBar.titleTextAttributes =  @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    navigationController.navigationBar.prefersLargeTitles = YES;

    // add to window
    self.window = [UIWindow new];
    [self.window setRootViewController:navigationController];
    [self.window makeKeyAndVisible];
        
    return YES;
}

@end
