//
//  CollectionViewCell.h
//  prac_mini_project
//
//  Created by leetaejun on 2016. 4. 5..
//  Copyright © 2016년 leetaejun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentsLabel;

@end
