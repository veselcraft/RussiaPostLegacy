//
//  TrackingsController.m
//  RussiaPost
//
//  Created by miles on 27.06.23.
//  Copyright (c) 2023 Miles Prower. All rights reserved.
//

#import "TrackingsController.h"
#import "APICommunicator.h"
#import "PackageController.h"
#import "PackageCell.h"

@interface TrackingsController () {
    NSString *packageNumber;
    NSArray *packages;
}

@end

@implementation TrackingsController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    [self updateLocally];
    
    [self.refreshControl addTarget:self
                            action:@selector(updateFull)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateLocally
{
    packages = [NSUserDefaults.standardUserDefaults arrayForKey:@"packages"];
    packages = [[NSSet setWithArray:packages] allObjects]; // Вроде убирает дубликаты
    [self.tableView reloadData];
}

- (void)updateFull
{
    [self updateLocally];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *packagesToPush = [NSMutableArray new];
        int failed = 0;
    
        for (int i = 0; i < packages.count; i++) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationItem setPrompt:[NSString stringWithFormat:@"В процессе обновления (%d из %d)", i, packages.count]];
            });
        
            NSDictionary* response = [APICommunicator getPackageInfo:[[packages objectAtIndex:i] objectForKey:@"trackingCode"]];
            if(response) {
                [packagesToPush addObject:@{@"trackingCode": [[[(NSArray*)[response objectForKey:@"detailedTrackings"] objectAtIndex:0]
                                                     objectForKey:@"trackingItem"]
                                                     objectForKey:@"barcode"],
                                            @"title": [[[(NSArray*)[response objectForKey:@"detailedTrackings"] objectAtIndex:0]
                                                        objectForKey:@"trackingItem"]
                                                        objectForKey:@"title"],
                                            @"status": [[[(NSArray*)[response objectForKey:@"detailedTrackings"] objectAtIndex:0]
                                                         objectForKey:@"trackingItem"]
                                                         objectForKey:@"commonStatus"],
                                            @"machineStatus": [[[(NSArray*)[response objectForKey:@"detailedTrackings"] objectAtIndex:0]
                                                             objectForKey:@"trackingItem"]
                                                            objectForKey:@"globalStatus"]}];
            } else {
                failed++;
                [packagesToPush addObject:[packages objectAtIndex:i]];
            }
        }
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSUserDefaults.standardUserDefaults setValue:packagesToPush forKey:@"packages"];
    packages = packagesToPush;
            [self.navigationItem setPrompt:nil];
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
            
            if (failed > 0)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Часть посылок не удалось обновить"
                                                                message:[NSString stringWithFormat:@"Не обновлено штук: %d", failed]
                                                               delegate:self
                                                      cancelButtonTitle:@"Отмена"
                                                      otherButtonTitles:@"Найти", nil];
                [alert show];
            }
        });
    });
}

- (IBAction)addTracking:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Отследить отправление"
                                                    message:@"Введите трек-номер посылки"
                                                   delegate:self
                                          cancelButtonTitle:@"Отмена"
                                          otherButtonTitles:@"Найти", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 1;
    [alert textFieldAtIndex:0].delegate = self;
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeASCIICapable;
    [alert show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return packages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PackageCell";
    PackageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.PackageNumber.text = [[packages objectAtIndex:indexPath.row] objectForKey:@"trackingCode"];
    cell.PackageTitle.text = [[packages objectAtIndex:indexPath.row] objectForKey:@"title"];
    cell.PackageLastState.text = [[packages objectAtIndex:indexPath.row] objectForKey:@"status"];
    
    bool arrived = [[[packages objectAtIndex:indexPath.row] objectForKey:@"machineStatus"] isEqualToString:@"ARRIVED"];
    if (arrived) {
        [cell.PackageLastState setTextColor:[UIColor redColor]];
    } else {
        [cell.PackageLastState setTextColor:[UIColor lightGrayColor]];
    }
    
    return cell;
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == 1) {
        if (buttonIndex == 1)
        {
            NSString* trackingCode = [alertView textFieldAtIndex:0].text;
            if (trackingCode.length > 12) {
                NSDictionary* response = [APICommunicator getPackageInfo:trackingCode];
                if(response) {
                    packageNumber = trackingCode;
                    
                    NSMutableArray *packagesLocal = [[NSUserDefaults.standardUserDefaults arrayForKey:@"packages"] mutableCopy];
                    [packagesLocal addObject:@{@"trackingCode": trackingCode,
                                           @"title": [[[(NSArray*)[response objectForKey:@"detailedTrackings"] objectAtIndex:0] objectForKey:@"trackingItem"] objectForKey:@"title"],
                                           @"status": [[[(NSArray*)[response objectForKey:@"detailedTrackings"] objectAtIndex:0] objectForKey:@"trackingItem"] objectForKey:@"commonStatus"],
                                           @"machineStatus": [[[(NSArray*)[response objectForKey:@"detailedTrackings"] objectAtIndex:0]
                                                                   objectForKey:@"trackingItem"]
                                                                  objectForKey:@"globalStatus"]}];
                    
                    [NSUserDefaults.standardUserDefaults setValue:packagesLocal forKey:@"packages"];
                    [self updateLocally];
                    
                    [self performSegueWithIdentifier:@"goToPackage" sender:self];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                                    message:@"Трек-номер не найден"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Закрыть"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                                message:@"Некорректный трек-номер"
                                                               delegate:self
                                                      cancelButtonTitle:@"Закрыть"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([NSUserDefaults.standardUserDefaults boolForKey:@"autoRefreshOnStartup"])
    {
        [self.refreshControl beginRefreshing];
        CGPoint newOffset = CGPointMake(0, -[self.tableView contentInset].top);
        [self.tableView setContentOffset:newOffset animated:YES];
        [self updateFull];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    packageNumber = [[packages objectAtIndex:indexPath.row] objectForKey:@"trackingCode"];
    [self performSegueWithIdentifier:@"goToPackage" sender:self];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *packagesToPush = [packages mutableCopy];
        
        [packagesToPush removeObject:[packagesToPush objectAtIndex:indexPath.row]];
        packages = packagesToPush;
        [NSUserDefaults.standardUserDefaults setValue:packagesToPush forKey:@"packages"];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"goToPackage"]) {
        PackageController *controller = [segue destinationViewController];
        controller.packageNumber = packageNumber;
    }
}

@end
