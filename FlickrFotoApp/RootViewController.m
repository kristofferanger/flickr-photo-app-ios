//
//  ListViewController.m
//  FlickrFotoApp
//
//  Created by Kristoffer Anger on 2019-03-03.
//  Copyright © 2019 kriang. All rights reserved.
//

#import "RootViewController.h"
#import "APIHelpers.h"
#import "UIView+AutoLayoutSupport.h"
#import "UIColor+ThemeColors.h"
#import "URLImage.h"
#import "PhotoTableViewCell.h"
#import "PhotoDetailsViewController.h"
#import "PhotoCollectionViewCell.h"
#import "MenuViewController.h"
#import "UIView+Elevation.h"
#import "SwipeInteractionController.h"

#define MENU_WIDTH 200.f
#define MENU_ANIMATION_TIME 0.6f

@interface RootViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchResultsUpdating, UINavigationControllerDelegate, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, MenuViewControllerDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSArray *tableViewData;
@property (strong, nonatomic) NSArray *filteredTableViewData;
@property (strong, nonatomic) UIImage *placeholderImage;

@property (strong, nonatomic) UIView *snapshot;

@end

@implementation RootViewController

- (instancetype)initWithStyle:(LayoutStyle)style {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _style = style;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Latest on Flickr";
    
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
    
    [self createLayoutWithStyle:self.style];
    [self fetchData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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

#pragma mark - api methods

- (void)fetchData {
    [APIHelpers makeRequestWithEndpoint:@"/" queryParameters:@{@"method":@"flickr.photos.getRecent"} completion:^(NSDictionary * _Nonnull response) {
        NSError *error = [response objectForKey:@"error"];
        if (error == nil) {
            NSArray *photos = [[response objectForKey:@"result"] valueForKeyPath:@"photos.photo"];
            self.tableViewData = [self filteredPhotoArray:photos];
        }
        else {
            NSLog(@"Fetch error: %@", error.localizedDescription);
        }
    }];
}

#pragma mark - Action methods

- (void)showMenu:(id)sender {
    
    NSArray *buttonInfoArray = @[@{@"button_title":@"Grid view", @"image_name":@"ic_view_module_36pt", @"style":@(LayoutStyleGrid)},
                                 @{@"button_title":@"List view", @"image_name":@"ic_view_list_36pt", @"style":@(LayoutStyleList)}
                                 ];
    MenuViewController *menu = [[MenuViewController alloc]initWithButtonInfoArray:buttonInfoArray];
    menu.delegate = self;

    menu.modalPresentationStyle = UIModalPresentationCustom;
    menu.transitioningDelegate = self;
    
    [self.navigationController presentViewController:menu animated:YES completion:nil];
    [self fetchData];
}

#pragma mark - getters / setterrs

- (void)setTableViewData:(NSArray *)tableViewData {
    if (tableViewData != _tableViewData) {
        _tableViewData = tableViewData;
        [self.tableView reloadData];
        [self.collectionView reloadData];
    }
}

- (UIImage *)placeholderImage {
    if (_placeholderImage == nil) {
        _placeholderImage = [[UIColor lightGrayColor] imageWithSize:[self defaultImageSize]];
    }
    return _placeholderImage;
}

#pragma mark - helper methods

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

#pragma mark - tableview delegate methods

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

#pragma mark - UIViewControllerTransitioningDelegate methods

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    
    return nil; // [[SwipeInteractionController alloc]initWithViewController:self];
}

#pragma mark - UIViewControllerAnimatedTransitioning delegate

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return MENU_ANIMATION_TIME;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *containerView = [transitionContext containerView];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    CGFloat underDampedRatio = 0.6;
    CGFloat overlayShadow = 8.0;
    CGFloat viewElevation = 12.0;
    NSTimeInterval transitionDuration = [self transitionDuration:transitionContext];
    
    // present menu
    if ([toViewController isKindOfClass:[MenuViewController class]]) {
        
        [containerView addSubview:toViewController.view];
        
        UIView *blackOverlayView = [[UIView alloc]initWithFrame:toViewController.view.frame];
        blackOverlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:overlayShadow];
        [transitionContext.containerView addSubview:blackOverlayView];
        
        _snapshot = [fromViewController.view snapshotViewAfterScreenUpdates:YES];
        [self.snapshot elevate:viewElevation];
        [containerView addSubview:self.snapshot];
        
        UIViewPropertyAnimator *animation = [[UIViewPropertyAnimator alloc]initWithDuration:transitionDuration dampingRatio:underDampedRatio animations:^{
            blackOverlayView.alpha = 0;
            self.snapshot.frame = CGRectOffset(self.snapshot.frame, MENU_WIDTH, 0);
        }];
        
        [animation addCompletion:^(UIViewAnimatingPosition finalPosition) {
            [blackOverlayView removeFromSuperview];
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
        
        [animation startAnimation];
    }
    // dismiss menu
    else {
        [containerView addSubview:fromViewController.view];
        
        UIView *blackOverlayView = [[UIView alloc]initWithFrame:fromViewController.view.frame];
        blackOverlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        [containerView addSubview:blackOverlayView];
        
        [containerView addSubview:self.snapshot];
        
        UIViewPropertyAnimator *animation = [[UIViewPropertyAnimator alloc]initWithDuration:transitionDuration dampingRatio:underDampedRatio animations:^{
            blackOverlayView.alpha = overlayShadow;
            self.snapshot.frame = self.snapshot.bounds;
        }];
        
        [animation addCompletion:^(UIViewAnimatingPosition finalPosition) {
            [self.snapshot removeFromSuperview];
            [blackOverlayView removeFromSuperview];
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
        [animation startAnimation];
    }
}


#pragma mark - MenuViewControllerDelegate methods

- (void)menuViewController:(nonnull MenuViewController *)menu dismissedWithSelectedInfo:(nullable NSDictionary *)info {
    
    NSNumber *style = [info objectForKey:@"style"];
    
    if (style) {
        LayoutStyle layoutStyle = (LayoutStyle)style.integerValue;
        if (self.style != layoutStyle) {
            // update layout if style changed
            _style = layoutStyle;
            [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [self createLayoutWithStyle:layoutStyle];
        }
        // update data also
        [self fetchData];
    }
}

@end
