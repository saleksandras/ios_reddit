//
//  FavoritesController.m
//  Wix
//
//  Created by Aleksandras Smirnovas on 14/04/2017.
//  Copyright © 2017 miror.lt. All rights reserved.
//

#import "FavoritesController.h"
#import "PostViewCell.h"
#import "Favorites.h"
#import "Api.h"
#import "DetailsViewController.h"

@interface FavoritesController ()

@property (nonatomic, strong) Favorites *favorites;
@property (nonatomic, strong) NSDictionary *selectedPost;

@end

@implementation FavoritesController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Favorites";
    
    // A little trick for removing the cell separators
    self.tableView.tableFooterView = [UIView new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _favorites = [Favorites new];
    if (self.favorites.items.count == 0) {
        // UIAlertController is a bad UX, but it's better that empty screen
        // Better solution would to use some empty state image, but I don't have much time for this.
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Favorites"
                                     message:@"Add some by clicking top right icon in details view"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.favorites.items.count;
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
    
    NSDictionary *post = self.favorites.items[indexPath.row];
    
    cell.titleLabel.text = post[@"title"];
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
    _selectedPost = self.favorites.items[indexPath.row];
    [self performSegueWithIdentifier:@"detailsSegue" sender:nil];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"detailsSegue"]) {
        DetailsViewController *controller = (DetailsViewController *)segue.destinationViewController;
        controller.post = self.selectedPost;
    }
}

@end
