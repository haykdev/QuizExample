//
//  News+CoreDataProperties.h
//  SoloLearn
//
//  Created by Karine Matinyan on 10/9/17.
//  Copyright © 2017 hayk_harutyunyan. All rights reserved.
//
//

#import "News+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface News (CoreDataProperties)

+ (NSFetchRequest<News *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *category;
@property (nullable, nonatomic, copy) NSString *headline;
@property (nullable, nonatomic, copy) NSString *imageUrl;
@property (nullable, nonatomic, copy) NSString *itemId;
@property (nullable, nonatomic, copy) NSDate *publicationDate;
@property (nullable, nonatomic, copy) NSNumber *isFavorite;

@end

NS_ASSUME_NONNULL_END
