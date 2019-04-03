//
//  AppDelegate.m
//  FlickrFotoApp
//
//  Created by Kristoffer Anger on 2019-02-22.
//  Copyright © 2019 kriang. All rights reserved.
//

#import "AppDelegate.h"
#import "PhotoViewController.h"
#import "UIColor+ThemeColors.h"
#import "MenuViewController.h"
#import "UIView+Elevation.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // create photo view controller
    PhotoViewController *root = [[PhotoViewController alloc]initWithNibName:nil bundle:nil];

    // add to navigation controller
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:root];
    navigationController.navigationBar.barTintColor = [UIColor colorFromHexString:kKnowitGreen];
    navigationController.navigationBar.tintColor = [UIColor whiteColor];
    navigationController.navigationBar.largeTitleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    navigationController.navigationBar.titleTextAttributes =  @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    navigationController.navigationBar.prefersLargeTitles = YES;
    [navigationController.view elevate:12.0];

    // create menu view controller
    NSArray *buttonInfoArray = @[@{@"button_title":@"Grid view", @"image_name":@"ic_view_module_36pt", @"style":@(LayoutStyleGrid)},
                                 @{@"button_title":@"List view", @"image_name":@"ic_view_list_36pt", @"style":@(LayoutStyleList)}];
    
    MenuViewController *menu = [[MenuViewController alloc]initWithButtonInfoArray:buttonInfoArray];
    
    // add navigation controller as child of the menu
    [menu addChildViewController:navigationController];
    [menu.view addSubview:navigationController.view];
    root.delegate = menu;

    // add to window
    self.window = [UIWindow new];
    [self.window setRootViewController:menu];
    [self.window makeKeyAndVisible];
        
    return YES;
}

@end
