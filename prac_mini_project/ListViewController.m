//
//  ListViewController.m
//  prac_mini_project
//
//  Created by leetaejun on 2016. 4. 1..
//  Copyright © 2016년 leetaejun. All rights reserved.
//

#import "AppDelegate.h"
#import "ListViewController.h"
#import "ListTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ListViewController()

@property (nonatomic, strong) NSMutableArray *boards;
@property (nonatomic, strong) NSNumber *offset;
@property (nonatomic, assign) BOOL didLoading;

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 변수 초기화
    self.boards = nil;
    self.offset = [[NSNumber alloc] initWithInt:0];
    
    // 타이틀 설정
    self.navigationItem.title = @"Table";
    
    // delegate, dataSource 설정
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // 최초 데이터 30개 로드
    [self setDidLoading:YES];
    [self loadDatasWithLimit:@30 FromOffset:self.offset];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.boards.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListTableViewCell"];
    
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"ListTableViewCell" owner:self options:nil][0];
    }
    
    cell.titleLabel.text = self.boards[indexPath.row][1];
    [cell.urlImageView sd_setImageWithURL:[NSURL URLWithString:self.boards[indexPath.row][2]] placeholderImage:[UIImage imageNamed:@"ic_placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error == nil) {
            [cell.urlImageView setImage:image];
        }
        else {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
    cell.contentsLabel.text = self.boards[indexPath.row][3];
    
    return cell;

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete && self.boards[indexPath.row]) {
        [self deleteData:indexPath];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (endScrolling >= scrollView.contentSize.height) {
        [self loadDatasWithLimit:@30 FromOffset:self.offset];
        [self changeLoading:NO];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
        if (!self.didLoading) {
            [self changeLoading:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

/*!
 @brief     Loading이 시작되고 종료될 때, flag 설정과 UIView hiddin 프로퍼티 및 애니메이션을 설정해주는 메소드
 @param
  - isLoading   : Loading 중인가에 대한 BOOL 값
 @return
 @remark
 @author    이태준
 **/
- (void)changeLoading:(BOOL)isLoading {
    [self setDidLoading:isLoading];
    self.loadingView.hidden = !isLoading;
    if (!isLoading) {
        [UIView animateWithDuration:1.0 animations:^{
            self.loadingView.alpha = 0.0;
        }];
    }
    else {
        [UIView animateWithDuration:1.0 animations:^{
            self.loadingView.alpha = 1.0;
        }];
    }
}

/*!
 @brief     페이지 단위로 데이터를 가져오기 위한 메소드
 @param
  - limit   : 가져올 갯수
  - offset  : 시작 주소
 @return
 @remark
 @author    이태준
 **/
- (void)loadDatasWithLimit:(NSNumber *)limit FromOffset:(NSNumber *)offset {
    NSString *query = [NSString stringWithFormat:@"select * from boards limit %d offset %d;", [limit intValue], ([offset intValue] * [limit intValue])];
    
    //
    if (self.boards == nil) {
        self.boards = [[NSMutableArray alloc] init];
    }
    //
    
    [self.boards addObjectsFromArray:[((AppDelegate *)[UIApplication sharedApplication].delegate).dbManager loadDataFromDB:query]];
    
    self.offset = [NSNumber numberWithInt:[self.offset intValue] + 1];
    
    if (self.boards.count > 0) {
        [self.tableView reloadData];
    }
}

/*!
 @brief     데이터 삭제를 위한 메소드
 @param
  - indexPath   : 해당하는 테이블의 indexPath
 @return
 @remark
 @author    이태준
 **/
- (void)deleteData:(NSIndexPath *)indexPath {
    NSString *query = [NSString stringWithFormat:@"delete from boards where board_id = %@", self.boards[indexPath.row][0]];
    [((AppDelegate *)[UIApplication sharedApplication].delegate).dbManager executeQuery:query];
    
    [self.boards removeObjectAtIndex:indexPath.row];
}

/*
 * 전체 데이터를 불러오는 메소드
 - (void)loadDatas {
 NSString *query = @"select * from boards";
 
 if (self.boards != nil) {
 self.boards = nil;
 }
 
 self.boards = [[NSMutableArray alloc] initWithArray:[((AppDelegate *)[UIApplication sharedApplication].delegate).dbManager loadDataFromDB:query]];
 
 if (self.boards.count > 0) {
 [self.tableView reloadData];
 }
 }
 */

@end
