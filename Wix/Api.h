//
//  Api.h
//  Wix
//
//  Created by Aleksandras Smirnovas on 14/04/2017.
//  Copyright © 2017 miror.lt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Api : NSObject

typedef void (^CRJSONResponseBlock)(NSDictionary* json);
typedef void (^CRImageBlock)(UIImage* image);
typedef void (^CRFailureBlock)(NSError *error);

+ (id)sharedInstance;

-(void)getRedisTopWithAfter:(NSString *)after
                     before:(NSString *)before
                    success:(CRJSONResponseBlock) successBlock
                    failure:(CRFailureBlock) failureBlock;

- (NSURLSessionTask *)imageWithURL:(NSString *)url
                           success:(CRImageBlock)successBlock
                           failure:(CRFailureBlock)failureBlock;

@end
