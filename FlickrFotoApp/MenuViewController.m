//
//  MenuViewController.m
//  FlickrFotoApp
//
//  Created by Kristoffer Anger on 2019-03-01.
//  Copyright © 2019 kriang. All rights reserved.
//

#import "MenuViewController.h"
#import "ListViewController.h"

#import "UIColor+ThemeColors.h"
#import "UIView+AutoLayoutSupport.h"
#import "UIView+Elevation.h"

#define MENU_WIDTH 200.f

@interface MenuViewController () <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

@property (nonatomic, strong) UIView *snapshot;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, strong) UINavigationController *dismissedController;
@end

@implementation MenuViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self createViewLayout];
    
    // push inital view controller instantly - but queue for appropriate draw cycle
    __weak MenuViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf pushViewControllerWithName:@"GridViewController" animated:NO];
    });
}

- (void)createViewLayout {
    
    self.view.backgroundColor = [UIColor colorFromHexString:kBackgroundGray];
    
    UIStackView *stackView = [[UIStackView alloc]initWithFrame:CGRectZero];
    stackView.alignment = UIStackViewAlignmentTop;
    stackView.distribution = UIStackViewDistributionEqualSpacing;
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = 30;
    [self.view addSubview:stackView pinToXPosition:LayoutPositionLeft withDistance:30 pinToYPosition:LayoutPositionTop withDistance:60];
    
    for (NSDictionary *buttonInfo in self.buttons) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tintColor = [UIColor colorFromHexString:kKnowitGreen];
        UIImage *buttonImage = [[UIImage imageNamed:[buttonInfo objectForKey:@"image_name"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [button setImage:buttonImage forState:UIControlStateNormal];
        [button setTitle:[buttonInfo objectForKey:@"button_title"] forState:UIControlStateNormal];
        [button setTitleColor:button.tintColor forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [stackView addArrangedSubview:button];
    }
}

#pragma mark - Getters/setters

- (NSArray *)buttons {
    if (_buttons == nil) {
        _buttons = @[@{@"button_title":@"Grid view", @"image_name":@"ic_view_module_36pt", @"view_controller":@"GridViewController"},
                     @{@"button_title":@"List view", @"image_name":@"ic_view_list_36pt", @"view_controller":@"ListViewController"},
                    ];
    }
    return _buttons;
}

#pragma mark - Action methods

- (void)buttonPressed:(UIButton *)button {
    
    NSDictionary *buttonInfo = [[self.buttons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@", @"button_title", button.currentTitle]] firstObject];
    NSString *viewControllerName = [buttonInfo objectForKey:@"view_controller"] ?: @"GridViewController";
    [self pushViewControllerWithName:viewControllerName animated:YES];
}

- (void)pushViewControllerWithName:(NSString *)viewControllerName animated:(BOOL)animated {
    
    // push previous controller if it's exists
    if ([self.dismissedController.viewControllers.firstObject isKindOfClass:NSClassFromString(viewControllerName)]) {
        [self.navigationController presentViewController:self.dismissedController animated:animated completion:nil];
    }
    else {
        UIViewController *viewController = [[NSClassFromString(viewControllerName) alloc]initWithNibName:nil bundle:nil];
        UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:viewController];
        
        navigationController.navigationBar.barTintColor = [UIColor colorFromHexString:kKnowitGreen];
        navigationController.navigationBar.tintColor = [UIColor whiteColor];
        navigationController.navigationBar.largeTitleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
        navigationController.navigationBar.titleTextAttributes =  @{NSForegroundColorAttributeName:[UIColor whiteColor]};
        navigationController.navigationBar.prefersLargeTitles = YES;
        navigationController.transitioningDelegate = self;
        [self.navigationController presentViewController:navigationController animated:animated completion:nil];
    }
}

#pragma mark - UIViewControllerTransitioningDelegate methods

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning methods

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    
    UINavigationController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UINavigationController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    self.dismissedController = fromViewController;
    CGFloat duration = [self transitionDuration:transitionContext];
    
    if ([self.navigationController.presentedViewController isEqual:fromViewController]) {
        
        [transitionContext.containerView addSubview:toViewController.view];
        
        UIView *blackOverlayView = [[UIView alloc]initWithFrame:toViewController.view.frame];
        blackOverlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        [transitionContext.containerView addSubview:blackOverlayView];
        
        _snapshot = [fromViewController.view snapshotViewAfterScreenUpdates:YES];
        [self.snapshot elevate:10];
        [transitionContext.containerView addSubview:self.snapshot];

        UIViewPropertyAnimator *animation = [[UIViewPropertyAnimator alloc]initWithDuration:duration dampingRatio:0.6 animations:^{
            blackOverlayView.alpha = 0;
            self.snapshot.frame = [self updateRect:self.snapshot.frame withNewOrigin:CGPointMake(MENU_WIDTH, 0)];
        }];
        
        [animation addCompletion:^(UIViewAnimatingPosition finalPosition) {
            [self.view addSubview:self.snapshot];
            [blackOverlayView removeFromSuperview];
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
        
        [animation startAnimation];
    }
    else {
        [transitionContext.containerView addSubview:fromViewController.view];
        
        UIView *blackOverlayView = [[UIView alloc]initWithFrame:fromViewController.view.frame];
        blackOverlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        [transitionContext.containerView addSubview:blackOverlayView];
        
        toViewController.view.hidden = YES;
        [transitionContext.containerView addSubview:toViewController.view];
    
        [transitionContext.containerView addSubview:self.snapshot];
        
        UIViewPropertyAnimator *animation = [[UIViewPropertyAnimator alloc]initWithDuration:duration dampingRatio:0.6 animations:^{
            blackOverlayView.alpha = 0.7;
            self.snapshot.frame = [self updateRect:self.snapshot.frame withNewOrigin:CGPointMake(0, 0)];
        }];
        
        [animation addCompletion:^(UIViewAnimatingPosition finalPosition) {
            toViewController.view.hidden = NO;
            [self.snapshot removeFromSuperview];
            [blackOverlayView removeFromSuperview];
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];

        [animation startAnimation];
    }
}


#pragma mark - Helper methods

- (CGRect)updateRect:(CGRect)rect withNewOrigin:(CGPoint)origin {
    rect.origin = origin;
    return rect;
}

@end
