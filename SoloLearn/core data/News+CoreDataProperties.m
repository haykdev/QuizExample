//
//  News+CoreDataProperties.m
//  SoloLearn
//
//  Created by Karine Matinyan on 10/9/17.
//  Copyright © 2017 hayk_harutyunyan. All rights reserved.
//
//

#import "News+CoreDataProperties.h"

@implementation News (CoreDataProperties)

+ (NSFetchRequest<News *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"News"];
}

@dynamic category;
@dynamic headline;
@dynamic imageUrl;
@dynamic itemId;
@dynamic publicationDate;
@dynamic isFavorite;

@end
