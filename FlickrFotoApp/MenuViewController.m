//
//  MenuViewController.m
//  FlickrFotoApp
//
//  Created by Kristoffer Anger on 2019-03-01.
//  Copyright © 2019 kriang. All rights reserved.
//

#import "MenuViewController.h"

#import "UIColor+ThemeColors.h"
#import "UIView+AutoLayoutSupport.h"

#define WHY_NOT YES
#define GOLDEN_RATIO ((1 + sqrt(5))/2.f)
#define MENU_WIDTH 240.f
#define ANIMATION_DURATION 0.25f

@interface MenuViewController ()

// private properties
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, strong) UIViewPropertyAnimator *animator;

// readonly calculated properties
@property (nonatomic, readonly) PhotoViewController *photoViewController;
@property (nonatomic, readonly) UINavigationController *navigationContainer;
@property (readonly) BOOL isOpen;

@end

@implementation MenuViewController

#pragma mark - Getters / setters

- (PhotoViewController *)photoViewController {
    PhotoViewController *root = self.navigationContainer.viewControllers.firstObject;
    return root;
}

- (UINavigationController *)navigationContainer {
    return self.childViewControllers.firstObject;
}

- (BOOL)isOpen {
    return self.navigationContainer.view.frame.origin.x != 0;
}

#pragma mark - Override methods

- (instancetype)initWithButtonInfoArray:(NSArray *)buttons {
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        _buttons = buttons;
    }
    return self;
}

- (BOOL)shouldAutorotate {
    return WHY_NOT;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createViewLayout];
}

#pragma mark - Helper methods

- (void)createViewLayout {
    
    self.view.backgroundColor = [UIColor colorFromHexString:kBackgroundGray];
    
    UIStackView *stackView = [[UIStackView alloc]initWithFrame:CGRectZero];
    stackView.alignment = UIStackViewAlignmentTop;
    stackView.distribution = UIStackViewDistributionEqualSpacing;
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = 30;
    [self.view addSubview:stackView pinToXPosition:LayoutPositionLeft withDistance:30 pinToYPosition:LayoutPositionTop withDistance:50];
    
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

- (UIViewPropertyAnimator *)menuAnimatorToPoint:(CGPoint)point {

    UIView *blurView = [[UIView alloc]initWithFrame:CGRectZero];
    blurView.backgroundColor = [UIColor colorWithWhite:0 alpha:1/GOLDEN_RATIO];
    blurView.alpha = point.x == 0 ? 0 : 1;
    [self.view insertSubview:blurView belowSubview:self.navigationContainer.view];
    [blurView pinToEdges];
    
    UIViewPropertyAnimator *menuAnimator = [[UIViewPropertyAnimator alloc]initWithDuration:ANIMATION_DURATION curve:UIViewAnimationCurveEaseOut animations:^{

        CGRect navigationContainerFrame = self.navigationContainer.view.frame;
        navigationContainerFrame.origin = point;
        self.navigationContainer.view.frame = navigationContainerFrame;
        blurView.alpha = point.x == 0 ? 1 :0;
    }];
    [menuAnimator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        self.photoViewController.coverView.hidden = !self.isOpen;
        [blurView removeFromSuperview];
    }];
    return menuAnimator;
}

- (void)interactiveMenuAnimatorWithPanGesture:(UIPanGestureRecognizer *)gesture toPoint:(CGPoint)point {
    
    // calculate progression
    CGPoint translation = [gesture translationInView:self.view];
    CGFloat direction = CGPointEqualToPoint(CGPointZero, point) ? -1 : 1;
    CGFloat fractionComplete = translation.x * direction / MENU_WIDTH;
    
    // handle gesture
    switch (gesture.state) {
            
        case UIGestureRecognizerStateBegan:{
            self.animator = [self menuAnimatorToPoint:point];
            [self.animator pauseAnimation];
            break;
        }
        case UIGestureRecognizerStateChanged:{
            [self.animator setFractionComplete:fractionComplete];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            self.animator.reversed = fractionComplete < 1 - 1/GOLDEN_RATIO;
            [self.animator continueAnimationWithTimingParameters:nil durationFactor:0];
            break;
        }
        default: {
            break;
        }
    }
}

#pragma mark - Action methods

- (void)buttonPressed:(UIButton *)button {
    
    NSDictionary *buttonInfo = [[self.buttons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@", @"button_title", button.currentTitle]]firstObject];
    self.photoViewController.style = (LayoutStyle)[[buttonInfo objectForKey:@"style"] integerValue];
    [self toggleMenuPage];
}

#pragma mark - PhotoViewControllerDelegate methods

- (void)handleOpenMenuPanGesture:(UIPanGestureRecognizer *)gesture {
    [self interactiveMenuAnimatorWithPanGesture:gesture toPoint:CGPointMake(MENU_WIDTH, 0)];
}

- (void)handleCloseMenuPanGesture:(UIPanGestureRecognizer *)gesture {
    [self interactiveMenuAnimatorWithPanGesture:gesture toPoint:CGPointZero];
}

- (void)toggleMenuPage {
    self.animator = [self menuAnimatorToPoint:self.isOpen ? CGPointZero : CGPointMake(MENU_WIDTH, 0)];
    [self.animator startAnimation];
}



@end
