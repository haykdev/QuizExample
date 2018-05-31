//
//  AsyncCellNode.h
//  SoloLearn
//
//  Created by Hayk Harutyunyan on 10/7/17.
//  Copyright © 2017 hayk_harutyunyan. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "News+CoreDataClass.h"

@interface AsyncCellNode : ASCellNode
- (instancetype)initWithModel:(News *)model;

@property (nonatomic, readonly) News *model;
@property (nonatomic, readonly) UIImage *image;
@end
