//
//  MenuController.m
//  RussiaPost
//
//  Created by miles on 28.06.23.
//  Copyright (c) 2023 Miles Prower. All rights reserved.
//

#import "MenuController.h"

@interface MenuController ()

@end

@implementation MenuController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [self performSegueWithIdentifier:@"goToSettings" sender:nil];
            break;
            
        case 1:
            [self performSegueWithIdentifier:@"goToAbout" sender:nil];
            break;
    }
}

@end
