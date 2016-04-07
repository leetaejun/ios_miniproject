//
//  CollectionViewController.h
//  prac_mini_project
//
//  Created by leetaejun on 2016. 4. 5..
//  Copyright © 2016년 leetaejun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
