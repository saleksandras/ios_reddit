//
//  TableViewCell.h
//  Wix
//
//  Created by Aleksandras Smirnovas on 14/04/2017.
//  Copyright © 2017 miror.lt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;

@end
