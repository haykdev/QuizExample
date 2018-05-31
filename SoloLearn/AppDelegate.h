//
//  AppDelegate.h
//  SoloLearn
//
//  Created by Hayk Harutyunyan on 10/5/17.
//  Copyright © 2017 hayk_harutyunyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

