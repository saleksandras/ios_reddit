//
//  Favorites.h
//  Wix
//
//  Created by Aleksandras Smirnovas on 14/04/2017.
//  Copyright © 2017 miror.lt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADVUserDefaults.h"

@interface Favorites : ADVUserDefaults

@property (nonatomic, strong) NSArray *items;

+ (NSDictionary *)favoriteWithPost:(NSDictionary *)post;

@end


