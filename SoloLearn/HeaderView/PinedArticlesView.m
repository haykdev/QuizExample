//
//  PinedArticlesView.m
//  SoloLearn
//
//  Created by Hayk Harutyunyan on 10/9/17.
//  Copyright © 2017 hayk_harutyunyan. All rights reserved.
//

#import "PinedArticlesView.h"

@interface PinedArticlesView ()
@property (nonatomic) ASTextNode *textNode;
@end

@implementation PinedArticlesView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (void)initialize {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = CGSizeMake(self.bounds.size.width, 150);
    self.collectionNode = [[ASCollectionNode alloc] initWithCollectionViewLayout:flowLayout];
    
    self.collectionNode.delegate = self.delegate;
    self.collectionNode.dataSource = self.delegate;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    
    NSDictionary *textAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:40 weight:UIFontWeightSemibold], NSForegroundColorAttributeName : [UIColor lightGrayColor]};

    
    self.textNode = [[ASTextNode alloc] init];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"Pined news" attributes:textAttributes];
    [text addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, text.length)];

    self.textNode.attributedText = text;
    self.textNode.style.alignSelf = ASStackLayoutAlignSelfCenter;

    self.textNode.frame = CGRectMake(0, (self.bounds.size.height - 50)/2, self.bounds.size.width, 50);
    [self addSubnode:self.collectionNode];
    [self.collectionNode addSubnode:self.textNode];
    
    flowLayout.minimumInteritemSpacing = 1;
    flowLayout.minimumLineSpacing = 1;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.collectionNode.frame = self.bounds;
}

- (void)hidePlaceholder {
    if (self.textNode.supernode) {
        [self.textNode removeFromSupernode];
    }
}

- (void)setDelegate:(id<ASCollectionDelegate,ASCollectionDataSource>)delegate {
    _delegate = delegate;
    self.collectionNode.delegate = delegate;
    self.collectionNode.dataSource = delegate;
}

@end
