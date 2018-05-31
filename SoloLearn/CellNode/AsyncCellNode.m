//
//  AsyncCellNode.m
//  SoloLearn
//
//  Created by Hayk Harutyunyan on 10/7/17.
//  Copyright © 2017 hayk_harutyunyan. All rights reserved.
//

#import "AsyncCellNode.h"

@interface AsyncCellNode()
@property (nonatomic) ASNetworkImageNode *imageNode;
@property (nonatomic) ASTextNode *title;
@property (nonatomic) ASTextNode *publicationDate;
@property (nonatomic) NSMutableArray<ASTextNode *> *tags;

@property (nonatomic, readwrite) News *model;
@property (nonatomic) NSDictionary *dictionary;
@end


@implementation AsyncCellNode
- (instancetype)initWithModel:(News *)model {
    self = [super init];
    if (self) {
        self.model = model;
        
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
        
        [dateFormater setDateFormat:@"yyyy/MM/dd"];
        NSString* date = [dateFormater stringFromDate:model.publicationDate];

        [self initializeWithImageURL:model.imageUrl title:model.headline category:model.category publicationDate:date];
    }
    return self;
}

- (void)initializeWithImageURL:(NSString *)imageURL title:(NSString *)title category:(NSString *)category publicationDate:(NSString *)publicationDate{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor whiteColor];
    self.imageNode = [ASNetworkImageNode new];
    self.imageNode.URL = [NSURL URLWithString:imageURL];
    self.title = [[ASTextNode alloc] init];
    self.tags = [[NSMutableArray alloc] init];
    self.publicationDate = [[ASTextNode alloc] init];
    
    NSRange wordRange = NSMakeRange(0, 5);
    NSArray *words = [[NSString stringWithFormat:@"%@ %@", category, title] componentsSeparatedByString:@" "];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"length > 3"];
    words = [words filteredArrayUsingPredicate:predicate];
    if (words.count > 6) {
        words = [words subarrayWithRange:wordRange];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    NSDictionary *textAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : [UIColor blackColor], NSParagraphStyleAttributeName : paragraphStyle};
    for (int i = 0; i < words.count; i++) {
        ASTextNode *tag = [ASTextNode new];
        tag.attributedText = [[NSAttributedString alloc] initWithString:words[i] attributes:textAttributes];
        tag.backgroundColor = [UIColor lightGrayColor];
        tag.willDisplayNodeContentWithRenderingContext = ^(CGContextRef  _Nonnull context, id  _Nullable drawParameters) {
            CGRect bounds = CGContextGetClipBoundingBox(context);
            UIImage *overlay = [UIImage as_resizableRoundedImageWithCornerRadius:6 cornerColor:[UIColor whiteColor] fillColor:[UIColor clearColor]];
            [overlay drawInRect:bounds];
            [[UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:6] addClip];
        };
        [self.tags addObject:tag];

    }
    self.title.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ - %@", category, title] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14], NSForegroundColorAttributeName : [UIColor blackColor]}];
    
    
    paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
    [paragraphStyle setAlignment:NSTextAlignmentRight];
    self.publicationDate.attributedText = [[NSAttributedString alloc] initWithString:publicationDate attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : [UIColor grayColor], NSParagraphStyleAttributeName : paragraphStyle}];
    self.automaticallyManagesSubnodes = YES;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    
    self.title.style.maxWidth = ASDimensionMake([UIScreen mainScreen].bounds.size.width - 226);
    self.imageNode.style.preferredSize = CGSizeMake(200, 150);
    self.imageNode.style.spacingBefore = 8;
    self.imageNode.style.spacingAfter = 8;
    self.title.style.spacingAfter = 8;
    
    float sumOfTagsWidthOnFirstLine = 0;
    float sumOfTagsWidthOnSecondLine = 0;

    int tagsCountOnFirstLine = 0;
    int tagsCountOnSecondLine = 0;
    for (ASTextNode *tag in self.tags) {
        tag.style.preferredSize = CGSizeMake(tag.attributedText.size.width + 10, 16);
        tag.style.spacingAfter = 4;
        tag.style.alignSelf = ASStackLayoutAlignSelfCenter;
        tag.maximumNumberOfLines = 1;
        sumOfTagsWidthOnFirstLine += tag.attributedText.size.width + 10 + 4;
        if (sumOfTagsWidthOnFirstLine <= constrainedSize.max.width - self.imageNode.style.preferredSize.width - 24) {
            tagsCountOnFirstLine++;
        } else {
            sumOfTagsWidthOnSecondLine += tag.attributedText.size.width + 10 + 4;
            if (sumOfTagsWidthOnSecondLine <= constrainedSize.max.width - self.imageNode.style.preferredSize.width - 24) {
                tagsCountOnSecondLine++;
            }
        }
        
    }
    
    
    ASStackLayoutSpec *tagsSpec;
    if (self.tags.count > tagsCountOnFirstLine) {
        ASStackLayoutSpec *tagsSpec1 = [ASStackLayoutSpec horizontalStackLayoutSpec];
        [tagsSpec1 setChildren:[self.tags subarrayWithRange:NSMakeRange(0, tagsCountOnFirstLine)]];
        ASStackLayoutSpec *tagsSpec2 = [ASStackLayoutSpec horizontalStackLayoutSpec];
        [tagsSpec2 setChildren:[self.tags subarrayWithRange:NSMakeRange(tagsCountOnFirstLine, tagsCountOnSecondLine)]];
        
        tagsSpec1.style.spacingAfter = 8;
        tagsSpec = [ASStackLayoutSpec verticalStackLayoutSpec];
        [tagsSpec setChildren:@[tagsSpec1, tagsSpec2]];
    } else {
        tagsSpec = [ASStackLayoutSpec horizontalStackLayoutSpec];
        [tagsSpec setChildren:self.tags];
    }
    
    ASStackLayoutSpec *vertical = [ASStackLayoutSpec verticalStackLayoutSpec];
        [vertical setChildren:@[self.title, tagsSpec, self.publicationDate]];

    ASStackLayoutSpec *commonSpec = [ASStackLayoutSpec horizontalStackLayoutSpec];
    [commonSpec setChildren:@[self.imageNode, vertical]];
    

    tagsSpec.style.spacingAfter = 8;
    commonSpec.style.spacingBefore = 16;

    ASStackLayoutSpec *mainStack = [ASStackLayoutSpec verticalStackLayoutSpec];
    [mainStack setChild:commonSpec];
    
    
    return mainStack;
}


- (UIImage *)image {
    return self.imageNode.image;
}
@end
