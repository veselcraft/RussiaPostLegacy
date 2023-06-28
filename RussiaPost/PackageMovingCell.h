//
//  PackageMovingCell.h
//  RussiaPost
//
//  Created by miles on 27.06.23.
//  Copyright (c) 2023 Miles Prower. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PackageMovingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *Status;
@property (weak, nonatomic) IBOutlet UILabel *DateAndPlace;
@property (weak, nonatomic) IBOutlet UIImageView *RouteImage;

@end
