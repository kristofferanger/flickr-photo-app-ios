//
//  ListViewController.m
//  FlickrFotoApp
//
//  Created by Kristoffer Anger on 2019-03-03.
//  Copyright © 2019 kriang. All rights reserved.
//

#import "ListViewController.h"
#import "APIHelpers.h"
#import "UIView+AutoLayoutSupport.h"
#import "UIColor+ThemeColors.h"
#import "URLImage.h"
#import "PhotoTableViewCell.h"
#import "PhotoDetailsViewController.h"

@interface ListViewController () <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchResultsUpdating>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSArray *tableViewData;
@property (strong, nonatomic) NSArray *filteredTableViewData;
@property (strong, nonatomic) UIImage *placeholderImage;
@end

@implementation ListViewController

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

    _tableView = [[UITableView alloc]initWithFrame:CGRectZero];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.estimatedRowHeight = [self defaultImageSize].height + 40;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.view addSubviewPinnedToEdges:self.tableView];
    
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
            self.tableViewData = [self filteredPhotoArray:photos];
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

- (void)setTableViewData:(NSArray *)tableViewData {
    if (tableViewData != _tableViewData) {
        _tableViewData = tableViewData;
        [self.tableView reloadData];
    }
}

- (UIImage *)placeholderImage {
    if (_placeholderImage == nil) {
        _placeholderImage = [[UIColor lightGrayColor] imageWithSize:[self defaultImageSize]];
    }
    return _placeholderImage;
}

#pragma mark - helper methods

- (CGSize)defaultImageSize {
    return CGSizeMake(self.view.bounds.size.width, 2*self.view.bounds.size.width/3);
}

- (NSArray *)filteredPhotoArray:(NSArray *)array {
    return [[[array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"!(%K IN %@)", @"title", @[@"", @" ", @"."]]]reverseObjectEnumerator] allObjects];
}

#pragma mark - tableview delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([self isFiltering]) {
        return self.filteredTableViewData.count;
    }
    else {
        return self.tableViewData.count;
    }
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
    
    // set text labels
    cell.titleLabel.text = [info objectForKey:@"title"];
    cell.detailsLabel.text = [NSString stringWithFormat:@"By %@", owner];
    
    // set image
    cell.photoView.image = self.placeholderImage;
    cell.imageDataTask = [URLImage imageURL:[NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@.jpg", farm, server, imageId, secret] withCompletion:^(UIImage *image, NSError *error) {
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

#pragma mark - UISearchController delegate/helper methods

- (BOOL)isFiltering {
    return self.searchController.isActive && self.searchController.searchBar.text.length>0;
}

- (void)updateSearchResultsForSearchController:(nonnull UISearchController *)searchController {
    self.filteredTableViewData = [self.tableViewData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"title", [searchController.searchBar text]]];
    [self.tableView reloadData];
}
@end
