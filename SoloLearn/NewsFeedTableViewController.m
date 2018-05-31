//
//  NesFeedTableViewController.m
//  SoloLearn
//
//  Created by Hayk Harutyunyan on 10/7/17.
//  Copyright © 2017 hayk_harutyunyan. All rights reserved.
//

#import "NewsFeedTableViewController.h"
#import "AsyncCellNode.h"
#import "ArticlePreviewViewController.h"
#import "ServerManager.h"
#import "News+CoreDataClass.h"
#import <MagicalRecord/MagicalRecord.h>
#import "PinedArticlesView.h"
#import <AFNetworking.h>

@interface NewsFeedTableViewController () <ASTableDataSource,
                                            ASTableDelegate,
                                            ArticlePiningDelegate,
                                            ASCollectionDataSource,
                                            ASCollectionDelegate>
@property (nonatomic) ASTableNode *tableNode;
@property (nonatomic) NSMutableArray <News *> *articles;
@property (nonatomic) NSInteger pageNumber;
@property (nonatomic) NSTimer *timer;

@end

@implementation NewsFeedTableViewController

- (instancetype)init {
    _tableNode = [[ASTableNode alloc] initWithStyle:UITableViewStylePlain];
    self.articles = [NSMutableArray new];
    if (!(self = [super init])) {
        return nil;
    }
    [self wireDelegation];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageNumber = 1;
    
    self.navigationItem.title = @"News Feed";
    self.tableNode.leadingScreensForBatching = 1.0;
    PinedArticlesView *header = [[PinedArticlesView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
    header.delegate = self;
    self.tableNode.view.tableHeaderView = header;
    [self.view addSubnode:self.tableNode];
    [self applyStyle];
    __weak NewsFeedTableViewController *weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:30 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if ([[AFNetworkReachabilityManager sharedManager] isReachable]) {
            NSDate *firstArticleDate = weakSelf.articles.count ? weakSelf.articles.firstObject.publicationDate : [NSDate date];
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"publicationDate > %@",firstArticleDate];

            [[ServerManager sharedManager] getNewsItemsForPage:1
                                                     onSuccess:^(NSArray *articles) {
                                                         NSArray *arr = [News MR_findAllSortedBy:@"publicationDate" ascending:NO withPredicate:pred] ;
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             [weakSelf insertNewRowsInTableNodeAtStart:[arr subarrayWithRange:NSMakeRange(0, arr.count)]];
                                                         });
                                                     } onFailure:^(NSError *error) {
                                                         
                                                     }];
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tableNode.frame = self.view.bounds;
}

- (void)wireDelegation {
    self.tableNode.dataSource = self;
    self.tableNode.delegate = self;
}

- (void)applyStyle {
    self.view.backgroundColor = [UIColor blackColor];
    self.tableNode.view.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - ASDataSource

- (NSInteger)tableNode:(ASTableNode *)tableNode numberOfRowsInSection:(NSInteger)section {
    return self.articles.count;
}

- (ASCellNodeBlock)tableNode:(ASTableView *)tableView nodeBlockForRowAtIndexPath:(NSIndexPath *)indexPath {
    id article = self.articles[indexPath.row];
    
    return ^{
        AsyncCellNode *cardNode = [[AsyncCellNode alloc] initWithModel:article];

        return cardNode;
    };
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"News";
}

#pragma mark - ASDelegate

- (ASSizeRange)tableView:(ASTableView *)tableNode
constrainedSizeForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGSize min = CGSizeMake(width, 30);
    CGSize max = CGSizeMake(width, INFINITY);
    return ASSizeRangeMake(min, max);
}

- (BOOL)shouldBatchFetchForTableNode:(ASTableNode *)tableNode {
    return YES;
}

- (void)tableNode:(ASTableNode *)tableNode willBeginBatchFetchWithContext:(ASBatchContext *)context {
    if (!context) {
        return;
    }
    NSDate *lastArticleDate = self.articles.count ? self.articles.lastObject.publicationDate : [NSDate date];
    [self retrieveNextPageWithCompletion:^(NSArray *articles) {
        [self insertNewRowsInTableNode:articles];
        [context completeBatchFetching:YES];
    } forDate:lastArticleDate];
}

- (void)tableNode:(ASTableNode *)tableNode didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ArticlePreviewViewController *vc = [[ArticlePreviewViewController alloc] initWithInfo:self.articles[indexPath.row]];
    vc.image = ((AsyncCellNode *)[tableNode nodeForRowAtIndexPath:indexPath]).image;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - ArticlePiningDelegate

- (void)didPinedArticle:(News *)article {
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        News *news = [News MR_findFirstByAttribute:@"itemId" withValue:article.itemId inContext:localContext];
        news.isFavorite = @(YES);
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [((PinedArticlesView *)self.tableNode.view.tableHeaderView).collectionNode reloadData];
        [((PinedArticlesView *)self.tableNode.view.tableHeaderView) hidePlaceholder];

    });
    
}

#pragma mark - ASCollectionDataSource

- (NSInteger)collectionNode:(ASCollectionNode *)collectionNode numberOfItemsInSection:(NSInteger)section {
    NSPredicate *predicatie = [NSPredicate predicateWithFormat:@"isFavorite == 1"];
    NSInteger itemsCount = [News MR_findAllWithPredicate:predicatie ].count;
    if (itemsCount) {
        [((PinedArticlesView *)self.tableNode.view.tableHeaderView) hidePlaceholder];
    }

    return itemsCount;
}

- (ASCellNodeBlock)collectionNode:(ASCollectionNode *)collectionNode nodeBlockForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSPredicate *predicatie = [NSPredicate predicateWithFormat:@"isFavorite == 1"];
    id article = [News MR_findAllWithPredicate:predicatie][indexPath.row];
    return ^{
        AsyncCellNode *cardNode = [[AsyncCellNode alloc] initWithModel:article];
        
        return cardNode;
    };
}


#pragma mark - ASCollectionDelegate

- (ASSizeRange)collectionNode:(ASCollectionNode *)collectionNode constrainedSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGSize min = CGSizeMake(width, 200);
    CGSize max = CGSizeMake(width, 200);
    return ASSizeRangeMake(min, max);
}

-(void)collectionNode:(ASCollectionNode *)collectionNode didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AsyncCellNode *cell = [collectionNode nodeForItemAtIndexPath:indexPath];
    
    ArticlePreviewViewController *vc = [[ArticlePreviewViewController alloc] initWithInfo:cell.model];
    vc.image = cell.image;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)retrieveNextPageWithCompletion:(void (^)(NSArray *))block forDate:(NSDate *)date {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"publicationDate < %@",date];
    if ([[AFNetworkReachabilityManager sharedManager] isReachable]) {
        [[ServerManager sharedManager] getNewsItemsForPage:self.pageNumber++
                                                 onSuccess:^(NSArray *articles) {
                                                     NSArray *arr = [News MR_findAllSortedBy:@"publicationDate" ascending:NO withPredicate:pred] ;
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         block([arr subarrayWithRange:NSMakeRange(0, arr.count > 10 ? 10 : arr.count)]);
                                                     });
                                                 } onFailure:^(NSError *error) {
                                                     
                                                 }];
    } else {
        if (self.articles.count > 0) {
            return;
        }
        
        NSArray *arr = [News MR_findAllSortedBy:@"publicationDate" ascending:NO withPredicate:pred
                        ];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(arr);
        });
    }
}

- (void)insertNewRowsInTableNode:(NSArray *)newArticles {
    NSInteger section = 0;
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    NSUInteger newTotalNumberOfPhotos = self.articles.count + newArticles.count;
    for (NSUInteger row = self.articles.count; row < newTotalNumberOfPhotos; row++) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
        [indexPaths addObject:path];
    }
    
    [self.articles addObjectsFromArray:newArticles];
    [self.tableNode insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)insertNewRowsInTableNodeAtStart:(NSArray *)newArticles {
    NSInteger section = 0;
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    for (NSUInteger row = 0; row < newArticles.count; row++) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
        [indexPaths addObject:path];
    }
    
    [self.articles insertObjects:newArticles atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newArticles.count)]];
    [self.tableNode insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

@end
