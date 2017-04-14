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

@interface TopController () <UIScrollViewDelegate>

@property (nonatomic, assign) bool isLoading;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSString *before;
@property (nonatomic, strong) NSString *after;
@property (nonatomic, strong) NSDictionary *selectedPost;


@end

@implementation TopController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //HUD only showed first time
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    // A little trick for removing the cell separators
    self.tableView.tableFooterView = [UIView new];
    
    self.title = @"Top";
    
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    //TODO: remove invisible item from the items array
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items ? self.items.count : 0;
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
    
    NSDictionary *post = self.items[indexPath.row][@"data"];
    
    cell.titleLabel.text = post[@"title"];
    if ([post objectForKey:@"thumbnail"]) {
        [[Api sharedInstance] imageWithURL:post[@"thumbnail"]
                                   success:^(UIImage *image) {
                                       cell.thumbImageView.image = image;
                                   } failure:^(NSError *error) {
                                       cell.thumbImageView.hidden = true;
                                       cell.thumbImageView.image = nil;
                                   }];
    } else {
        cell.thumbImageView.hidden = true;
        //[cell.thumbImageView removeFromSuperview];
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

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView_
{
    CGFloat actualPosition = scrollView_.contentOffset.y;
    CGFloat contentHeight = scrollView_.contentSize.height - (100.f);
    if (actualPosition >= contentHeight) {
        NSLog(@"scrollViewDidScroll Loaddata");
        [self loadData];
    }
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
    //Don't load data it already loading
    if (self.isLoading) {
        return;
    }
    self.isLoading = true;
    [[Api sharedInstance] getRedisTopWithAfter:self.after
                                        before:self.before
                                       success:^(NSDictionary *json) {
                                           self.isLoading = false;
                                           _items = json[@"data"][@"children"];
                                           _after = json[@"data"][@"after"];
                                           //TODO: it should be dissmissed only once
                                           [SVProgressHUD dismiss];
                                           [self.tableView reloadData];
                                       } failure:^(NSError *error) {
                                           self.isLoading = false;
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
