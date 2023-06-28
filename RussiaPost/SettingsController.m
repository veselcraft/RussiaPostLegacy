//
//  SettingsController.m
//  RussiaPost
//
//  Created by miles on 28.06.23.
//  Copyright (c) 2023 Miles Prower. All rights reserved.
//

#import "SettingsController.h"

@interface SettingsController ()
@property (weak, nonatomic) IBOutlet UISwitch *UpdateDataOnStartupSwitch;

@end

@implementation SettingsController

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
    self.UpdateDataOnStartupSwitch.on = [NSUserDefaults.standardUserDefaults boolForKey:@"autoRefreshOnStartup"];
}

- (IBAction)UpdateDataOnStartupTrigger:(id)sender {
    bool isOn = [self.UpdateDataOnStartupSwitch isOn];
    [NSUserDefaults.standardUserDefaults setBool:isOn forKey:@"autoRefreshOnStartup"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
