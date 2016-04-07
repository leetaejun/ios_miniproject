//
//  ListViewController.h
//  prac_mini_project
//
//  Created by leetaejun on 2016. 4. 1..
//  Copyright © 2016년 leetaejun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;


@end
