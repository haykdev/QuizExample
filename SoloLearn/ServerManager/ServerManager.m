//
//  ServerManager.m
//  SoloLearn
//
//  Created by Hayk Harutyunyan on 10/7/17.
//  Copyright © 2017 hayk_harutyunyan. All rights reserved.
//

#import "ServerManager.h"
#import <AFNetworking/AFNetworking.h>
#import <MagicalRecord/MagicalRecord.h>
#import "News+CoreDataClass.h"

#define AuthManager_TokenKey @"AuthManager_TokenKey"

@interface ServerManager ()
@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;
@property (strong, nonatomic) NSMutableDictionary *params;
@property (strong, nonatomic) NSArray *resultArray;
@property (strong, nonatomic) NSDictionary *resultDictionary;
@end

@implementation ServerManager
+(ServerManager *)sharedManager {
    static ServerManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ServerManager alloc] init];
    });
    manager.params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"3c20277b-491a-4266-809c-e7e59902802e",@"api-key", nil];
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSURL *url = [NSURL URLWithString:@"https://content.guardianapis.com/"];
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
        self.sessionManager.securityPolicy.allowInvalidCertificates = TRUE;
        AFSecurityPolicy* policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        [policy setValidatesDomainName:NO];
        [policy setAllowInvalidCertificates:YES];
        [self.sessionManager setSecurityPolicy:policy];
        
    }
    return self;
}

- (void)getNewsItemsForPage:(NSInteger)page
                  onSuccess:(void(^)(NSArray *resultArray)) success
                  onFailure:(void(^)(NSError *error)) failure {
    [self.params setValue:@(page) forKey:@"page"];
    [self.params setValue:@"article" forKey:@"type"];
    [self.params setValue:@"headline,thumbnail" forKey:@"show-fields"];

    [self.sessionManager
     GET:@"search"
     parameters:self.params
     progress:nil
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         self.resultDictionary = [responseObject objectForKey:@"response"];
         if (self.resultDictionary) {
             self.resultArray = [self.resultDictionary objectForKey:@"results"];
             [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
                 [News MR_importFromArray:self.resultArray inContext:localContext];
             }];
             

         }
         success(self.resultArray);
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         failure(error);
     }];
}
@end
