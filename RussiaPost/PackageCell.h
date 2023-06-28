//
//  PackageCell.h
//  RussiaPost
//
//  Created by miles on 27.06.23.
//  Copyright (c) 2023 Miles Prower. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PackageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *PackageNumber;
@property (weak, nonatomic) IBOutlet UILabel *PackageTitle;
@property (weak, nonatomic) IBOutlet UILabel *PackageLastState;

@end
