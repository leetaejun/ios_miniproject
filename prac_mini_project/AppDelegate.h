//
//  AppDelegate.h
//  prac_mini_project
//
//  Created by leetaejun on 2016. 4. 1..
//  Copyright © 2016년 leetaejun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "db/DBManager.h"
#import "MainViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainViewController *mainViewController;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) DBManager *dbManager;


@end

