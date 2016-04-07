//
//  MainViewController.m
//  prac_mini_project
//
//  Created by leetaejun on 2016. 4. 1..
//  Copyright © 2016년 leetaejun. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "ListViewController.h"
#import "CollectionViewController.h"

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.delegate = self;
    
    self.navigationItem.title = @"Main";
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:htmlString baseURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([request.URL.absoluteString hasPrefix:@"giosis://save"]) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        
        for (NSString *param in [request.URL.query componentsSeparatedByString:@"&"]) {
            
            NSArray *elts = [param componentsSeparatedByString:@"="];
            if([elts count] < 2) {
                continue;
            }
            
            [params setObject:[elts lastObject] forKey:[elts firstObject]];
        }
        
        [self saveToSqliteFromJavaScript:params];
        
        return NO;
    }
    
    if ([request.URL.absoluteString hasPrefix:@"giosis://goList"]) {
        [self goListViewController];
    }
    
    
    return YES;
}

/*!
 @brief     자바스크립트 이벤트 호출 시, SQLite에 데이터를 넣기 위한 메소드
 @param
  - parameters : title, url, contents를 키 값으로 가지고 있는 Dictionary입니다.
 @return
 @remark
 @author    이태준
 **/
- (void)saveToSqliteFromJavaScript:(NSDictionary *) parameters {
    [self insertDataWithTitle:parameters[@"title"] url:parameters[@"url"] contents:parameters[@"contents"]];
}

/*!
 @brief     SQLite에 title, url, contents를 넣기 위한 메소드
 @param
  - title       : 제목
  - url         : 이미지 URL
  - contents    : 내용
 @return
 @remark
 @author    이태준
 **/
- (void)insertDataWithTitle:(NSString *) title url:(NSString *)url contents:(NSString *)contents {
    NSString *query = [NSString stringWithFormat:@"insert into boards (title, url, contents) values ('%@', '%@', '%@');", title, url, contents];
    
    [((AppDelegate *)[UIApplication sharedApplication].delegate).dbManager executeQuery:query];
}


- (void)goListViewController {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"테이블뷰와 콜렉션뷰"
                                                                   message:@"하나를 골라주세요!"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* tableViewAction = [UIAlertAction actionWithTitle:@"테이블 뷰" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              ListViewController *listVC = [[ListViewController alloc] initWithNibName:@"ListViewController" bundle:nil];
                                                              [self.navigationController pushViewController:listVC animated:YES];
                                                          }];
    
    
    UIAlertAction* collectionViewAction = [UIAlertAction actionWithTitle:@"콜렉션 뷰" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              CollectionViewController *collectionVC = [[CollectionViewController alloc] initWithNibName:@"CollectionViewController" bundle:nil];
                                                              [self.navigationController pushViewController:collectionVC animated:YES];
                                                          }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * action) {}];
    [alert addAction:tableViewAction];
    [alert addAction:collectionViewAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
