//
//  PhotoTableViewCell.m
//  FlickrFotoApp
//
//  Created by Kristoffer Anger on 2019-03-05.
//  Copyright © 2019 kriang. All rights reserved.
//

#import "PhotoTableViewCell.h"
#import "UIView+AutoLayoutSupport.h"
#import "UIView+Elevation.h"

#define DEFAULT_SPACING 5.0f
#define DEFAULT_IMAGE_HEIGHT 180.0f

@implementation PhotoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self createCell];
    }
    return self;
}

- (void)createCell {
    
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    self.titleLabel.adjustsFontForContentSizeCategory = YES;
    self.titleLabel.font = [UIFont fontWithDescriptor:[[self.titleLabel.font fontDescriptor]fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:self.titleLabel.font.pointSize];
    self.titleLabel.numberOfLines = 0;
    
    _detailsLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    self.detailsLabel.adjustsFontForContentSizeCategory = YES;
    self.detailsLabel.numberOfLines = 0;
    
    UIStackView *verticalStackView = [[UIStackView alloc]initWithArrangedSubviews:@[self.titleLabel, self.detailsLabel]];
    verticalStackView.axis = UILayoutConstraintAxisVertical;
    verticalStackView.spacing = DEFAULT_SPACING;
    UIView *textContainerView = [[UIView alloc]initWithFrame:CGRectZero];
    [textContainerView addSubview:verticalStackView pinToXPosition:LayoutPositionEdgeToEdge withDistance:10 pinToYPosition:LayoutPositionEdgeToEdge withDistance:12];
    
    _photoView = [[UIImageView alloc]initWithFrame:CGRectZero];
    self.photoView.contentMode = UIViewContentModeScaleAspectFill;
    self.photoView.clipsToBounds = YES;
    self.photoView.backgroundColor = [UIColor lightGrayColor];
    [self.photoView.heightAnchor constraintEqualToConstant:DEFAULT_IMAGE_HEIGHT].active = YES;
    [self.photoView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.photoView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];

    UIStackView *containerStackView = [[UIStackView alloc]initWithArrangedSubviews:@[self.photoView, textContainerView]];
    containerStackView.axis = UILayoutConstraintAxisVertical;
    containerStackView.alignment = UIStackViewAlignmentFill;
    
    UIView *elevatedBackgroundView = [[UIView alloc]initWithFrame:CGRectZero];
    [elevatedBackgroundView elevate:4.0 shadowOffset:CGSizeMake(0, 4.0)];
    elevatedBackgroundView.backgroundColor = [UIColor whiteColor];
    [elevatedBackgroundView addSubviewPinnedToEdges:containerStackView];
    
    [self.contentView addSubview:elevatedBackgroundView pinToXPosition:LayoutPositionEdgeToEdge withDistance:20 pinToYPosition:LayoutPositionEdgeToEdge withDistance:12];
}

@end
