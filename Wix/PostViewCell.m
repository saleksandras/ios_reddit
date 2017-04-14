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
    self.thumbImageView.hidden = false;
    self.thumbImageView.image = nil;
}

@end
