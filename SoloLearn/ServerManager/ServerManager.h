//
//  ServerManager.h
//  SoloLearn
//
//  Created by Hayk Harutyunyan on 10/7/17.
//  Copyright © 2017 hayk_harutyunyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerManager : NSObject
+(ServerManager *)sharedManager;

- (void)getNewsItemsForPage:(NSInteger)page
                  onSuccess:(void(^)(NSArray *articles)) success
                  onFailure:(void(^)(NSError *error)) failure;
@end
