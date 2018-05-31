//
//  PinedArticlesView.h
//  SoloLearn
//
//  Created by Hayk Harutyunyan on 10/9/17.
//  Copyright © 2017 hayk_harutyunyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>

@interface PinedArticlesView : UIView
@property (nonatomic) ASCollectionNode *collectionNode;
@property (nonatomic, weak) id <ASCollectionDelegate, ASCollectionDataSource> delegate;

- (void)hidePlaceholder;
@end
