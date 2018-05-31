//
//  ArticlePreviewViewController.h
//  SoloLearn
//
//  Created by Hayk Harutyunyan on 10/7/17.
//  Copyright © 2017 hayk_harutyunyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "News+CoreDataClass.h"


@protocol ArticlePiningDelegate<NSObject>

- (void)didPinedArticle:(News *)article;

@end


@interface ArticlePreviewViewController : UIViewController
- (instancetype)initWithInfo:(News *)info;

@property (nonatomic) UIImage *image;
@property (nonatomic, weak) id <ArticlePiningDelegate> delegate;
@end
