//
//  ListViewController.m
//  FlickrFotoApp
//
//  Created by Kristoffer Anger on 2019-03-03.
//  Copyright © 2019 kriang. All rights reserved.
//


#import "PhotoViewController.h"
#import "PhotoDetailsViewController.h"

#import "APIHelpers.h"
#import "UIView+AutoLayoutSupport.h"
#import "UIColor+ThemeColors.h"
#import "UIView+Elevation.h"

#import "URLImage.h"
#import "PhotoTableViewCell.h"
#import "PhotoCollectionViewCell.h"

#define DEFAULT_STYLE LayoutStyleGrid

@interface PhotoViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchResultsUpdating>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSArray *tableViewData;
@property (strong, nonatomic) NSArray *filteredTableViewData;
@property (strong, nonatomic) UIImage *placeholderImage;

@end

@implementation PhotoViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Nature on Flickr";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"ic_menu_36pt"] style:UIBarButtonItemStyleDone target:self action:@selector(showMenu:)];
    
    _searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.obscuresBackgroundDuringPresentation = false;
    self.searchController.searchBar.placeholder = @"Search photos";
    self.searchController.searchBar.tintColor = [UIColor whiteColor];
    self.searchController.searchBar.barTintColor = [UIColor whiteColor];
    self.searchController.searchBar.barStyle = UIBarStyleBlack;
    self.navigationItem.searchController = self.searchController;
    
    self.definesPresentationContext = YES;
    
    [self createLayoutWithStyle:DEFAULT_STYLE];
    [self createGestureRecognizers];
    [self fetchData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


#pragma mark - API methods

- (void)fetchData {
    [APIHelpers makeRequestWithEndpoint:@"/" queryParameters:@{@"method":@"flickr.photos.search", @"tags":@"nature"} completion:^(NSDictionary * _Nonnull response) {
        NSError *error = [response objectForKey:@"error"];
        if (error == nil) {
            NSArray *photos = [[response objectForKey:@"result"] valueForKeyPath:@"photos.photo"];
            
            // will lazily reload data in table and collection view
            self.tableViewData = [self filteredPhotoArray:photos];
        }
        else {
            NSLog(@"Fetch error: %@", error.localizedDescription);
        }
    }];
}

#pragma mark - Action methods

- (void)showMenu:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(toggleMenuPage)]) {
        [self.delegate toggleMenuPage];
    }
}

#pragma mark - Getters / setters

- (UIView *)coverView {
    if (_coverView == nil) {
        _coverView = [[UIView alloc]initWithFrame:CGRectZero];
        _coverView.hidden = YES;
    }
    return _coverView;
}

- (UIImage *)placeholderImage {
    if (_placeholderImage == nil) {
        _placeholderImage = [[UIColor lightGrayColor] imageWithSize:[self defaultImageSize]];
    }
    return _placeholderImage;
}

- (void)setStyle:(LayoutStyle)style {
    
    if (style != _style) {
        [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self createLayoutWithStyle:style];
        [self.view addSubviewPinnedToEdges:self.coverView];
        
        //reload data if layout changed
        [self fetchData];
        
        _style = style;
    }
}

- (void)setTableViewData:(NSArray *)tableViewData {
    if (tableViewData != _tableViewData) {
        _tableViewData = tableViewData;
        [self.tableView reloadData];
        [self.collectionView reloadData];
    }
}

#pragma mark - Helper methods

- (CGSize)defaultItemSize {
    
    CGFloat quarterOfWidth = MIN(self.view.bounds.size.width, self.view.bounds.size.height)/4 - 8;
    return CGSizeMake(quarterOfWidth, quarterOfWidth);
}

- (CGSize)defaultImageSize {
    return CGSizeMake(self.view.bounds.size.width, 2*self.view.bounds.size.width/3);
}

- (NSArray *)filteredPhotoArray:(NSArray *)array {
    return [[[array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"!(%K IN %@)", @"title", @[@"", @" ", @"."]]]reverseObjectEnumerator] allObjects];
}

// gestures handle by delegate
- (void)createGestureRecognizers {

    [self.view addSubviewPinnedToEdges:self.coverView];
    
    SEL closeMenuSelector = @selector(handleCloseMenuPanGesture:);
    if ([self.delegate respondsToSelector:closeMenuSelector]) {
        [self.coverView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.delegate action:closeMenuSelector]];
    }
    
    SEL openMenuSelector = @selector(handleOpenMenuPanGesture:);
    if ([self.delegate respondsToSelector:openMenuSelector]) {
        UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self.delegate action:openMenuSelector];
        [pan setEdges:UIRectEdgeLeft];
        [self.view addGestureRecognizer:pan];
    }
}

- (void)createLayoutWithStyle:(LayoutStyle)style {
    
    self.view.backgroundColor = [UIColor colorFromHexString:kBackgroundLightGray];
    
    if (style == LayoutStyleList) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.tableFooterView = [UIView new];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        self.tableView.estimatedRowHeight = [self defaultImageSize].height + 40;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        
        [self.view addSubviewPinnedToEdges:self.tableView];
    }
    else {
        UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = [self defaultItemSize];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        [self.collectionView registerClass:[PhotoCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.backgroundColor = [UIColor clearColor];
        [self.view addSubviewPinnedToEdges:self.collectionView];
    }
}


#pragma mark - Tableview delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self isFiltering] ? self.filteredTableViewData.count : self.tableViewData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *photoCellIdentifier = @"PhotoCell";
    PhotoTableViewCell *cell = (PhotoTableViewCell *) [tableView dequeueReusableCellWithIdentifier:photoCellIdentifier];

    if (cell == nil) {
        cell = [[PhotoTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:photoCellIdentifier];
    }
    // cancel any previous downloading task
    [cell.imageDataTask cancel];
    
    // extract info
    NSDictionary *info = [[self isFiltering] ? self.filteredTableViewData : self.tableViewData objectAtIndex:indexPath.row];
    
    NSString *owner = [info objectForKey:@"owner"];
    NSString *imageId = [info objectForKey:@"id"];
    NSString *farm = [info objectForKey:@"farm"];
    NSString *server = [info objectForKey:@"server"];
    NSString *secret = [info objectForKey:@"secret"];
    NSString *imageSize = @"z";
    
    // set text labels
    cell.titleLabel.text = [info objectForKey:@"title"];
    cell.detailsLabel.text = [NSString stringWithFormat:@"By %@", owner];
    
    // set image
    cell.photoView.image = self.placeholderImage;
    cell.imageDataTask = [URLImage imageURL:[NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@_%@.jpg", farm, server, imageId, secret, imageSize] withCompletion:^(UIImage *image, NSError *error) {
        if (error == nil) {
            cell.photoView.image = image;
            [cell setNeedsDisplay];
        }
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *info = [[self isFiltering] ? self.filteredTableViewData : self.tableViewData objectAtIndex:indexPath.row];
    PhotoDetailsViewController *details = [[PhotoDetailsViewController alloc]initWithPhotoInfo:info];
    [self.navigationController pushViewController:details animated:YES];
}


#pragma mark - UICollectionView delegate methods

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self isFiltering] ? self.filteredTableViewData.count : self.tableViewData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    // cancel any previous downloading task
    [cell.imageDataTask cancel];
    
    NSDictionary *info = [[self isFiltering] ? self.filteredTableViewData : self.tableViewData objectAtIndex:indexPath.row];
    
    NSString *imageId = [info objectForKey:@"id"];
    NSString *farm = [info objectForKey:@"farm"];
    NSString *server = [info objectForKey:@"server"];
    NSString *secret = [info objectForKey:@"secret"];
    NSString *imageSize = @"q";

    // set image
    cell.imageDataTask = [URLImage imageURL:[NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@_%@.jpg", farm, server, imageId, secret, imageSize] withCompletion:^(UIImage *image, NSError *error) {
        if (error == nil) {
            cell.photoView.image = image;
        }
    }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
        
    NSDictionary *info = [[self isFiltering] ? self.filteredTableViewData : self.tableViewData objectAtIndex:indexPath.row];
    
    PhotoDetailsViewController *details = [[PhotoDetailsViewController alloc]initWithPhotoInfo:info];
    [self.navigationController pushViewController:details animated:YES];
}


#pragma mark - UISearchController delegate methods

- (BOOL)isFiltering {
    return self.searchController.isActive && self.searchController.searchBar.text.length>0;
}

- (void)updateSearchResultsForSearchController:(nonnull UISearchController *)searchController {
    self.filteredTableViewData = [self.tableViewData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"title", [searchController.searchBar text]]];
    [self.tableView reloadData];
    [self.collectionView reloadData];
}

#pragma mark - MenuViewControllerDelegate methods

@end
