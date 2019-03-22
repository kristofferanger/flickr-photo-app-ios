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

@interface MenuViewController ()

@property (nonatomic, strong) NSArray *buttons;
@end

@implementation MenuViewController


#pragma mark - Override methods

- (instancetype)initWithButtonInfoArray:(NSArray *)buttons {
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        _buttons = buttons;
    }
    return self;
}

- (BOOL)shouldAutorotate {
    return NO;
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

#pragma mark - Action methods

- (void)buttonPressed:(UIButton *)button {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    NSDictionary *buttonInfo = [[self.buttons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@", @"button_title", button.currentTitle]]firstObject];
    
    if ([self.delegate respondsToSelector:@selector(menuViewController:dismissedWithSelectedInfo:)]) {
        [self.delegate menuViewController:self dismissedWithSelectedInfo:buttonInfo];
    }
}


@end
