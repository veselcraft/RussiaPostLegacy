//
//  PackageController.m
//  RussiaPost
//
//  Created by miles on 27.06.23.
//  Copyright (c) 2023 Miles Prower. All rights reserved.
//

#import "PackageController.h"
#import "APICommunicator.h"

#import "PackageTitleCell.h"
#import "PackageMovingCell.h"
#import "PackageInfoCell.h"

#import "BarcodeController.h"

@interface PackageController () {
    NSArray *packageMoving;
    NSString *packageTitle;
    NSDictionary *packageInfo;
    NSString *packageDescription;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *BarcodeButton;

@end

@implementation PackageController

@synthesize packageNumber;

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

    [self setTitle:packageNumber];
    
    [self refresh];
    
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh
{
    [self.refreshControl beginRefreshing];
    NSDictionary *response = [APICommunicator getPackageInfo:packageNumber];
    packageInfo = [[(NSArray*)[response objectForKey:@"detailedTrackings"] objectAtIndex:0] objectForKey:@"trackingItem"];
    
    packageTitle = [packageInfo objectForKey:@"title"];
    packageMoving = [packageInfo objectForKey:@"trackingHistoryItemList"];
    
    if (![[packageInfo objectForKey:@"barcodeImage"] isMemberOfClass:[NSNull class]])
    {
        self.BarcodeButton.enabled = true;
    }
    
    NSString *additionalPackageInfo = [packageInfo objectForKey:@"mailCtgText"];
    NSString *weight = @"";
    if ([[packageInfo objectForKey:@"weight"] isKindOfClass:[NSNull class]]) {
        weight = @"";
    } else if ([[packageInfo objectForKey:@"weight"] integerValue] < 950) {
        weight = [NSString stringWithFormat:@"· %@ г.", [packageInfo objectForKey:@"weight"]];
    } else if ([[packageInfo objectForKey:@"weight"] integerValue] > 950) {
        int w = [[packageInfo objectForKey:@"weight"] integerValue] * 1000;
        weight = [NSString stringWithFormat:@"· %d кг.", w];
    }
    
    NSString *packageType = [NSString stringWithFormat:@"%@ %@ %@", @"Посылка", additionalPackageInfo, weight];
    NSString *packageArriving = [NSString stringWithFormat:@"%@, %@", [packageInfo objectForKey:@"indexTo"], [packageInfo objectForKey:@"destinationCityName"]];
    
    packageDescription = [NSString stringWithFormat:@"%@\nОт кого: %@\nКому: %@\nКуда: %@", packageType, [packageInfo objectForKey:@"sender"], [packageInfo objectForKey:@"recipient"], packageArriving];
    [self.refreshControl endRefreshing];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 || section == 2) {
        return 1;
    } else {
        return packageMoving.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"PackageTitleCell";
        PackageTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        cell.Title.text = packageTitle;
        
        return cell;
    } else if (indexPath.section == 1) {
        static NSString *CellIdentifier = @"PackageMovingCell";
        PackageMovingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        NSDictionary* CurrentPackagePlace = [packageMoving objectAtIndex:indexPath.row];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ru"]];
        NSDate *date = [formatter dateFromString:[CurrentPackagePlace objectForKey:@"date"]];
        
        NSDateFormatter *humanReadable = [[NSDateFormatter alloc] init];
        [humanReadable setDateFormat:@"yyyy"];
        if ([[humanReadable stringFromDate:date] isEqualToString:[humanReadable stringFromDate:[NSDate new]]])
        {
            [humanReadable setDateFormat:@"d MMMM, HH:mm"];
        } else {
            [humanReadable setDateFormat:@"d MMMM yyyy г., HH:mm"];
        }
        
        cell.Status.text = [CurrentPackagePlace objectForKey:@"humanStatus"];
        cell.DateAndPlace.text = [NSString stringWithFormat:@"%@ · %@", [humanReadable stringFromDate:date], [CurrentPackagePlace objectForKey:@"description"]];
        
        if (indexPath.row == 0) {
            if ([[packageInfo objectForKey:@"globalStatus"] isEqualToString:@"ARRIVED"]) {
                cell.RouteImage.image = [UIImage imageNamed:@"PathInOffice"];
            } else if ([[packageInfo objectForKey:@"globalStatus"] isEqualToString:@"ARCHIVED"]) {
                cell.RouteImage.image = [UIImage imageNamed:@"PathReceived"];
            } else {
                cell.RouteImage.image = [UIImage imageNamed:@"PathStart"];
            }
        } else if (indexPath.row == packageMoving.count-1) {
            cell.RouteImage.image = [UIImage imageNamed:@"PathEnd"];
        } else {
            cell.RouteImage.image = [UIImage imageNamed:@"PathMiddle"];
        }
        
        return cell;
    } else {
        static NSString *CellIdentifier = @"PackageInfoCell";
        PackageInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        cell.TextView.text = packageDescription;
        cell.TextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        
        return cell;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Название отправления";
            break;
            
        case 1:
            return @"История перемещений";
            break;
            
        case 2:
            return @"Об отправлении";
            break;
            
        default:
            return nil;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PackageInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PackageInfoCell"];
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody]};
    // Hardcoded bc Obj-C sucks balls
    CGRect textSize = [packageDescription
                   boundingRectWithSize:CGSizeMake(cell.TextView.frame.size.width, MAXFLOAT)
                   options:NSStringDrawingUsesLineFragmentOrigin
                   attributes: attributes
                   context:nil];
    switch (indexPath.section) {
        case 1:
            return 55.0;
            break;
            
        case 2:
            return textSize.size.height + 18;
            break;
            
        default:
            return 44.0;
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"goToBarcode"]) {
        BarcodeController *controller = [segue destinationViewController];
        controller.base64barcode = [packageInfo objectForKey:@"barcodeImage"];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
