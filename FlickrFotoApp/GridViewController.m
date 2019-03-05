//
//  GridViewController.m
//  FlickrFotoApp
//
//  Created by Kristoffer Anger on 2019-03-05.
//  Copyright © 2019 kriang. All rights reserved.
//

#import "GridViewController.h"
#import "APIHelpers.h"
#import "UIView+AutoLayoutSupport.h"
#import "UIColor+ThemeColors.h"
#import "URLImage.h"
#import "PhotoDetailsViewController.h"
#import "PhotoCollectionViewCell.h"

#define IMAGE_TAG 100

@interface GridViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UISearchDisplayDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *collectionViewData;
@property (strong, nonatomic) UISearchController *searchController;
@property (nonatomic, strong) NSArray *filteredCollectionViewData;

@end

@implementation GridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Latest on Flickr";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"ic_menu_36pt"] style:UIBarButtonItemStyleDone target:self action:@selector(showMenu:)];
    [self createLayout];
    [self fetchData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)createLayout {
    
    self.view.backgroundColor = [UIColor colorFromHexString:kBackgroundLightGray];
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = [self defaultItemSize];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [self.collectionView registerClass:[PhotoCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubviewPinnedToEdges:self.collectionView];
    
    _searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.obscuresBackgroundDuringPresentation = false;
    self.searchController.searchBar.placeholder = @"Search photos";
    self.searchController.searchBar.tintColor = [UIColor whiteColor];
    self.searchController.searchBar.barTintColor = [UIColor whiteColor];
    self.searchController.searchBar.barStyle = UIBarStyleBlack;
    
    self.navigationItem.searchController = self.searchController;
    self.definesPresentationContext = YES;

}

#pragma mark - api methods

- (void)fetchData {
    [APIHelpers makeRequestWithEndpoint:@"/" queryParameters:@{@"method":@"flickr.photos.getRecent"} completion:^(NSDictionary * _Nonnull response) {
        NSError *error = [response objectForKey:@"error"];
        if (error == nil) {
            NSArray *photos = [[response objectForKey:@"result"] valueForKeyPath:@"photos.photo"];
            self.collectionViewData = [self filteredPhotoArray:photos];
        }
        else {
            NSLog(@"Fetch error: %@", error.localizedDescription);
        }
    }];
}

#pragma mark - Action methods

- (void)showMenu:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - getters / setterrs

- (void)setCollectionViewData:(NSArray *)collectionViewData {
    if (collectionViewData != _collectionViewData) {
        _collectionViewData = collectionViewData;
        [self.collectionView reloadData];
    }
}

#pragma mark - helper methods

- (CGSize)defaultItemSize {
    CGFloat quarterOfWidth = self.view.bounds.size.width/4 - 8;
    return CGSizeMake(quarterOfWidth, quarterOfWidth);
}

- (NSArray *)filteredPhotoArray:(NSArray *)array {
    return [[[array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"!(%K IN %@)", @"title", @[@"", @" ", @"."]]]reverseObjectEnumerator] allObjects];
}

#pragma mark - UICollectionView delegate methods

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];
    [cell.imageDataTask cancel];
    
    NSDictionary *info = [[self isFiltering] ? self.filteredCollectionViewData : self.collectionViewData objectAtIndex:indexPath.row];

    NSString *imageId = [info objectForKey:@"id"];
    NSString *farm = [info objectForKey:@"farm"];
    NSString *server = [info objectForKey:@"server"];
    NSString *secret = [info objectForKey:@"secret"];
    
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIImageView *imageView = [[UIImageView alloc]init];
    [cell.contentView addSubviewPinnedToEdges:imageView];

    // set image
    cell.imageDataTask = [URLImage imageURL:[NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@.jpg", farm, server, imageId, secret] withCompletion:^(UIImage *image, NSError *error) {
        if (error == nil) {
            imageView.image = image;
        }
    }];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self isFiltering] ? self.filteredCollectionViewData.count : self.collectionViewData.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *info = [[self isFiltering] ? self.filteredCollectionViewData : self.collectionViewData objectAtIndex:indexPath.row];

    PhotoDetailsViewController *details = [[PhotoDetailsViewController alloc]initWithPhotoInfo:info];
    [self.navigationController pushViewController:details animated:YES];
}

#pragma mark - UISearchController delegate/helper methods

- (BOOL)isFiltering {
    return self.searchController.isActive && self.searchController.searchBar.text.length>0;
}

- (void)updateSearchResultsForSearchController:(nonnull UISearchController *)searchController {
    self.filteredCollectionViewData = [self.collectionViewData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"title", [searchController.searchBar text]]];
    [self.collectionView reloadData];
}

@end
