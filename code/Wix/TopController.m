//
//  ViewController.m
//  Wix
//
//  Created by Aleksandras Smirnovas on 14/04/2017.
//  Copyright © 2017 miror.lt. All rights reserved.
//

#import "TopController.h"
#import "PostViewCell.h"
#import "Api.h"
#import "DetailsViewController.h"
#import "SVProgressHUD.h"

@interface TopController () <UIScrollViewDelegate, UISearchBarDelegate, UISearchResultsUpdating>

@property (nonatomic, assign) Boolean isLoading;
@property (nonatomic, assign) Boolean isAllDataLoaded;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSArray *filteredItems;
@property (nonatomic, strong) NSString *searchString;
@property (nonatomic, strong) NSString *before;
@property (nonatomic, strong) NSString *after;
@property (nonatomic, strong) NSDictionary *selectedPost;
@property (nonatomic, strong) UISearchController *searchController;


@end

@implementation TopController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //HUD only showed first time
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    // A little trick for removing the cell separators
    self.tableView.tableFooterView = [UIView new];
    
    //http://stackoverflow.com/questions/34585625/how-add-search-option-for-a-tableview-in-ios-9-using-uisearchcontroller-objecti
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    self.title = @"Top";
    _items = @[];
    _isAllDataLoaded = false;
    _isLoading = false;
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //TODO: remove invisible item from the items array
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredItems ? self.filteredItems.count : self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"itemCell";
    PostViewCell *cell = (PostViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                                         forIndexPath:indexPath];
    if (!cell) {
        cell = [[PostViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *post;
    
    //search if available
    if (self.filteredItems) {
        post = self.filteredItems[indexPath.row][@"data"];
        //Mark the search string if available
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:post[@"title"]];
        NSRange range = [title.mutableString rangeOfString:self.searchString];
        [title addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:range];
        cell.titleLabel.attributedText = [title copy];
    } else {
        post = self.items[indexPath.row][@"data"];
        cell.titleLabel.text = post[@"title"];
    }

    if ([post objectForKey:@"thumbnail"] &&
        ![post[@"thumbnail"] isEqualToString:@"self"] &&
        ![post[@"thumbnail"] isEqualToString:@"default"]) {
        [[Api sharedInstance] imageWithURL:post[@"thumbnail"]
                                   success:^(UIImage *image) {
                                       cell.thumbImageView.image = image;
                                   } failure:^(NSError *error) {
                                       [cell hideImage];
                                   }];
    } else {
        [cell hideImage];
    }    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    _selectedPost = self.items[indexPath.row];
    [self performSegueWithIdentifier:@"detailsSegue" sender:nil];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height ;
    if (endScrolling >= scrollView.contentSize.height){
        [self loadData];
    }
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    if (searchString.length >= 3) {
        self.searchString = searchString;
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"data.title CONTAINS %@", searchString];
        self.filteredItems = [self.items filteredArrayUsingPredicate:filter];
    }
    [self.tableView reloadData];
}


#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.filteredItems = nil;
    self.searchString = nil;
    [self.tableView reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"detailsSegue"]) {
        DetailsViewController *controller = (DetailsViewController *)segue.destinationViewController;
        controller.post = self.selectedPost[@"data"];
    }
}

#pragma mark - Data

- (void)loadData
{
    //Don't load data if it's already loading
    if (self.isLoading) {
        return;
    }
    if (self.isAllDataLoaded) {
        return;
    }
    self.isLoading = true;
    //Show activity indicator while loading is in progress
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    spinner.frame = CGRectMake(0, 0, self.view.frame.size.width, 60.f);
    self.tableView.tableFooterView = spinner;
    [[Api sharedInstance] getRedditTopWithAfter:self.after
                                         before:self.before
                                        success:^(NSDictionary *json) {
                                            NSArray *newItems = json[@"data"][@"children"];
                                            if (newItems.count < 25) {
                                                self.isAllDataLoaded = true;
                                            }
                                           _items = [self.items arrayByAddingObjectsFromArray:newItems];
                                           _after = json[@"data"][@"after"];
                                           //TODO: It would be great to dynamicaly insert new rows withoud reloading the table

//                                           NSInteger lastRowIndex = self.items.count - 1;
//                                           NSMutableArray *indexes = [[NSMutableArray alloc] init];
//                                           for(int i = 0; i < newItems.count; i++) {
//                                               [indexes addObject:[NSIndexPath indexPathForRow:i+lastRowIndex
//                                                                                     inSection:0]
//                                                ];
//                                           }
//                                           [self.tableView beginUpdates];
//                                           [self.tableView insertRowsAtIndexPaths:[indexes copy]
//                                                                 withRowAnimation:UITableViewRowAnimationBottom];
//                                           [self.tableView endUpdates];
                                           self.isLoading = false;
                                            self.tableView.tableFooterView = nil;
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [self.tableView reloadData];                                               
                                               //TODO: HUD should be dissmissed only once
                                               [SVProgressHUD dismiss];
                                           });

                                        } failure:^(NSError *error) {
                                           self.isLoading = false;
                                            self.tableView.tableFooterView = nil;
                                            [SVProgressHUD dismiss];
                                           UIAlertController * alert = [UIAlertController
                                                                        alertControllerWithTitle:@"Error"
                                                                        message:error.localizedDescription
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                                           
                                           UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"OK"
                                                                                              style:UIAlertActionStyleDefault
                                                                                            handler:nil];
                                           [alert addAction:okButton];
                                           [self presentViewController:alert animated:YES completion:nil];
                                        }];
}

@end
