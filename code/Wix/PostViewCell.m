//
//  TableViewCell.m
//  Wix
//
//  Created by Aleksandras Smirnovas on 14/04/2017.
//  Copyright © 2017 miror.lt. All rights reserved.
//

#import "PostViewCell.h"

@implementation PostViewCell

-(void)prepareForReuse
{
    [super prepareForReuse];
    self.thumbWidthConstraint.constant = 50.f;
    self.thumbImageView.image = nil;
}

-(void)hideImage
{
    //This application is modifying the autolayout engine from a background thread after the engine was accessed from the main thread. This can lead to engine corruption and weird crashes.
    dispatch_async(dispatch_get_main_queue(), ^{
        self.thumbWidthConstraint.constant = 0;
    });
}

@end
