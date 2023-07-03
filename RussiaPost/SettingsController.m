//
//  SettingsController.m
//  RussiaPost
//
//  Created by miles on 28.06.23.
//  Copyright (c) 2023 Miles Prower. All rights reserved.
//

#import "SettingsController.h"
#import "APICommunicator.h"

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 1) {
        UILocalNotification *notif = [[UILocalNotification alloc] init];
        notif.fireDate = [NSDate dateWithTimeIntervalSinceNow:2];
        notif.alertBody = @"Сертификаты необходимы в случае, если с приложением возникают проблемы. Например, выводится ошибка о якобы несуществующем трек-номере.";
        notif.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:notif];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://cydia.invoxiplaygames.uk/certificates/"]];
    }
}


@end
