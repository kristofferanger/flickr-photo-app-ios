//
//  PhotoDetailsViewController.m
//  FlickrFotoApp
//
//  Created by Kristoffer Anger on 2019-03-05.
//  Copyright © 2019 kriang. All rights reserved.
//

#import "PhotoDetailsViewController.h"
#import "APIHelpers.h"
#import "UIView+AutoLayoutSupport.h"
#import "UIColor+ThemeColors.h"
#import "URLImage.h"

#define DEFAULT_MARGIN 15.f

@interface PhotoDetailsViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) NSDictionary *photoInfo;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation PhotoDetailsViewController


- (instancetype)initWithPhotoInfo:(NSDictionary *)photoInfo {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.photoInfo = photoInfo;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createLayout];
    [self fetchUserData];
}

- (void)createLayout {
    
    self.view.backgroundColor = [UIColor colorFromHexString:kBackgroundLightGray];
    
    _imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    self.imageView.clipsToBounds = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;

    _titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.font = [UIFont fontWithDescriptor:[[self.titleLabel.font fontDescriptor]fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:self.titleLabel.font.pointSize];
    
    _dateLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    
    UIStackView *verticalStackView = [[UIStackView alloc]initWithArrangedSubviews:@[self.imageView, self.titleLabel, self.dateLabel]];
    verticalStackView.distribution = UIStackViewDistributionFill;
    verticalStackView.axis = UILayoutConstraintAxisVertical;
    verticalStackView.spacing = DEFAULT_MARGIN;
    [self.view addSubview:verticalStackView pinToXPosition:LayoutPositionEdgeToEdge withDistance:DEFAULT_MARGIN pinToYPosition:LayoutPositionEdgeToEdge withDistance:DEFAULT_MARGIN];
    
    _spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.tintColor = [UIColor blackColor];
    self.spinner.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    [self.spinner startAnimating];
    [self.view addSubview:self.spinner];
    
    
}

- (void)updateLayoutWithUserName:(NSString *)userName andDate:(NSString *)dateString {
    
    // set title
    self.title = [@"@" stringByAppendingString:userName ?: @" ..."];
    
    // set labels
    self.titleLabel.text = [self.photoInfo objectForKey:@"title"];
    self.dateLabel.text = dateString;
    
    // set image
    NSString *imageId = [self.photoInfo objectForKey:@"id"];
    NSString *farm = [self.photoInfo objectForKey:@"farm"];
    NSString *server = [self.photoInfo objectForKey:@"server"];
    NSString *secret = [self.photoInfo objectForKey:@"secret"];
    
    [URLImage imageURL:[NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@.jpg", farm, server, imageId, secret] withCompletion:^(UIImage *image, NSError *error) {
        if (error == nil) {
            self.imageView.image = image;
        }
    }];
}


- (void)fetchUserData {
    
    NSNumber *photoId = [self.photoInfo objectForKey:@"id"];
    [APIHelpers makeRequestWithEndpoint:@"/" queryParameters:@{@"method":@"flickr.photos.getInfo", @"photo_id":photoId} completion:^(NSDictionary * _Nonnull response) {
        
        [self.spinner removeFromSuperview];
        NSDictionary *result = [response objectForKey:@"result"];
        if (result) {
            NSString *userName = [result valueForKeyPath:@"photo.owner.username"];
            NSString *dateString = [result valueForKeyPath:@"photo.dates.taken"];
             [self updateLayoutWithUserName:userName andDate:dateString];
        }
        else {
            NSLog(@"An error happend: %@", [response objectForKey:@"error"]);
        }
    }];
}


@end
