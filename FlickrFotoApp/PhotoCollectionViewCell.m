//
//  PhotoCollectionViewCell.m
//  FlickrFotoApp
//
//  Created by Kristoffer Anger on 2019-03-05.
//  Copyright © 2019 kriang. All rights reserved.
//

#import "PhotoCollectionViewCell.h"
#import "UIView+AutoLayoutSupport.h"

@implementation PhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)rect {
    self = [super initWithFrame:rect];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        
        _photoView = [[UIImageView alloc]initWithFrame:rect];
        [self.contentView addSubviewPinnedToEdges:self.photoView];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    // clear content of image view
    self.photoView.image = nil;
}

@end
