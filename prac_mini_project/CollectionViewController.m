//
//  CollectionViewController.m
//  prac_mini_project
//
//  Created by leetaejun on 2016. 4. 5..
//  Copyright © 2016년 leetaejun. All rights reserved.
//

#import "AppDelegate.h"
#import "CollectionViewController.h"
#import "CollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define iPHONE5_RATIO (568.0 / 320.0)
#define CELL_WIDTH_SIZE 155.0
#define CELL_HEIGHT_SIZE 320.0

@interface CollectionViewController ()
{
    float ratio_width;
    float ratio_height;
}

@property (nonatomic, strong) NSMutableArray *boards;
@property (nonatomic, strong) NSNumber *offset;
@property (nonatomic, assign) BOOL didLoading;

@end

@implementation CollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 아이폰 5를 기준으로 화면 비율이 더 크다면 셀의 크기를 조금 보정해준다.
    CGRect screen = [[UIScreen mainScreen] bounds];
    float screenRatio = screen.size.height / screen.size.width;
    if (iPHONE5_RATIO < screenRatio) {
        float realRatio = screenRatio - iPHONE5_RATIO;
        ratio_width = (1.0 + realRatio) * CELL_WIDTH_SIZE;
        ratio_height = (1.0 + realRatio) * CELL_HEIGHT_SIZE;
    }
    
    // 변수 초기화
    self.boards = nil;
    self.offset = [[NSNumber alloc] initWithInt:0];
    
    // 타이틀 설정
    self.navigationItem.title = @"Collection";
    
    // delegate, dataSource 설정
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    // collectionView에 nib를 통해 reuseIdentifier 설정
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CollectionViewCell"];
    
    // 데이터 로드
    [self loadDatas];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.boards.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
    
    cell.titleLabel.text = self.boards[indexPath.row][1];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:self.boards[indexPath.row][2]] placeholderImage:[UIImage imageNamed:@"ic_placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error == nil) {
            [cell.imageView setImage:image];
        }
        else {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
    cell.contentsLabel.text = self.boards[indexPath.row][3];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return CGSizeMake(ratio_width, ratio_height);
}

/*!
 @brief     전체 데이터를 가져오기 위한 메소드
 @param
 @return
 @remark
 @author    이태준
 **/
- (void)loadDatas {
    NSString *query = @"select * from boards";
    
    if (self.boards != nil) {
        self.boards = nil;
    }
    
    self.boards = [[NSMutableArray alloc] initWithArray:[((AppDelegate *)[UIApplication sharedApplication].delegate).dbManager loadDataFromDB:query]];
    
    if (self.boards.count > 0) {
        [self.collectionView reloadData];
    }
}

@end
