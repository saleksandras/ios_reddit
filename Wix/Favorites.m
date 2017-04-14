//
//  Favorites.m
//  Wix
//
//  Created by Aleksandras Smirnovas on 14/04/2017.
//  Copyright © 2017 miror.lt. All rights reserved.
//

#import "Favorites.h"

@implementation Favorites

@dynamic items;


+ (void) initialize
{
    [super initialize];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{ @"Favorites.items": @[] }];
}

+ (NSDictionary *)favoriteWithPost:(NSDictionary *)post
{
    NSMutableDictionary *favorite = [@{
                           @"title": post[@"title"],
                           @"permalink": post[@"permalink"],
                           } mutableCopy];
    if ([post objectForKey:@"thumbnail"]) {
        favorite[@"thumbnail"] = post[@"thumbnail"];
    }
    return [favorite copy];
}

@end


