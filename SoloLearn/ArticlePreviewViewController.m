//
//  ArticlePreviewViewController.m
//  SoloLearn
//
//  Created by Hayk Harutyunyan on 10/7/17.
//  Copyright © 2017 hayk_harutyunyan. All rights reserved.
//

#import "ArticlePreviewViewController.h"

@interface ArticlePreviewViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *publishedDate;

@property (nonatomic) NSString *imageURL;
@property (nonatomic) NSString *category;
@property (nonatomic) NSString *headline;
@property (nonatomic) NSString *publication;

@property (nonatomic) News *article;

@end

@implementation ArticlePreviewViewController

- (instancetype)initWithInfo:(News *)info {
    self = [super init];
    if (self) {
        self.article = info;
        self.imageURL = info.imageUrl;
        self.headline = info.headline;
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
        [dateFormater setDateFormat:@"yyyy/MM/dd"];
        self.publication = [dateFormater stringFromDate:info.publicationDate];
        self.category = info.category;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView.image = self.image ? self.image :  [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageURL]]];
    
    self.titleLabel.text = self.category;
    self.descriptionLabel.text = self.headline;
    self.publishedDate.text = self.publication;
}

- (IBAction)pinAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didPinedArticle:)]) {
        [self.delegate didPinedArticle:self.article];
    }
    [self.navigationController popViewControllerAnimated:YES];
}


@end
