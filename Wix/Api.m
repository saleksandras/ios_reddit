//
//  Api.m
//  Wix
//
//  Created by Aleksandras Smirnovas on 14/04/2017.
//  Copyright © 2017 miror.lt. All rights reserved.
//

#import "Api.h"

@interface Api ()

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation Api

+ (Api *)sharedInstance
{
    static Api *__sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[Api alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.reddit.com"]];
    });
    
    return __sharedInstance;
}


- (id)initWithBaseURL:(NSURL *)url
{
    self = [super init];
    if(self)
    {
        _baseURL = url;
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    
    
    return self;
}


-(void)getRedisTopWithAfter:(NSString *)after
                     before:(NSString *)before
              success:(CRJSONResponseBlock) successBlock
              failure:(CRFailureBlock) failureBlock
{
    NSString *url = @"/top.json?limit=25";
    if (after) {
        url = [url stringByAppendingString:[NSString stringWithFormat:@"&after=%@", after]];
    }
    NSURLRequest *request = [self getCacheRequestWithUrl:url];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      if (error) {
                                          failureBlock(error);
                                          
                                      }
                                      // Success
                                      NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                                                   options:0
                                                                                                     error:nil];
                                      successBlock(jsonResponse);
                                  }];
    
    [task resume];
}

- (NSURLSessionTask *)imageWithURL:(NSString *)url
                           success:(CRImageBlock)successBlock
                           failure:(CRFailureBlock)failureBlock
{

    NSURL *imageUrl = [NSURL URLWithString:url];
    NSURLSessionTask *task = [self.session dataTaskWithURL:imageUrl
                                         completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                             if (error) {
                                                 failureBlock(error);
                                                 return;
                                             }
        if (response)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *image = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image) {
                        successBlock(image);
                    }
                });
            });
    }];
    
    [task resume];
    return task;
}


-(NSURLRequest*)getCacheRequestWithUrl:(NSString*)url
{
    NSString *stringUrl = [[self.baseURL absoluteString] stringByAppendingString:url];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:stringUrl]];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    [urlRequest setTimeoutInterval:60];
    return [urlRequest copy];
}
@end
