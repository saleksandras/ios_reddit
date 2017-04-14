//
//  DetailsViewController.m
//  Wix
//
//  Created by Aleksandras Smirnovas on 14/04/2017.
//  Copyright © 2017 miror.lt. All rights reserved.
//

#import "DetailsViewController.h"
#import "SVProgressHUD.h"
#import "Favorites.h"

@interface DetailsViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, strong) Favorites *favorites;
@property (nonatomic, assign) bool isFavorite;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _favorites = [Favorites new];

    self.title = self.post[@"title"];
    
    [SVProgressHUD show];
    
    NSString *urlString = [@"https://www.reddit.com" stringByAppendingString:self.post[@"permalink"]];
    NSLog(@"url: %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    [urlRequest setTimeoutInterval:60 * 10]; //cache for 10min.
    self.webView.delegate = self;
    [self.webView loadRequest:[urlRequest copy]];
    
    self.isFavorite = false;
    NSDictionary *post = [Favorites favoriteWithPost:self.post];
    if ([self.favorites.items containsObject:post]) {
        self.isFavorite = true;
    }
    
    UIBarButtonItem *favButton = [[UIBarButtonItem alloc]
                                   initWithTitle:self.isFavorite ? @"★" : @"☆"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(favBtnClicked:)];
    self.navigationItem.rightBarButtonItem = favButton;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)favBtnClicked:(id)sender
{
    NSDictionary *post = [Favorites favoriteWithPost:self.post];
    NSMutableArray *items = [self.favorites.items mutableCopy];
    if (self.isFavorite) {
        [items removeObject:post];
        self.isFavorite = false;
    } else {
        [items addObject:post];
        self.isFavorite = true;
    }
    self.favorites.items = [items copy];
    
    //Update the fav button title (not the best way...)
    UIBarButtonItem *btn = self.navigationItem.rightBarButtonItem;
    btn.title = self.isFavorite ? @"★" : @"☆";
    self.navigationItem.rightBarButtonItem = btn;
}

#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Error loading Redis post"
                                 message:error.localizedDescription
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
    
    //Adding "Retry" button here would be a geat idea
}

@end
