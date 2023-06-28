//
//  BarcodeController.m
//  RussiaPost
//
//  Created by miles on 27.06.23.
//  Copyright (c) 2023 Miles Prower. All rights reserved.
//

#import "BarcodeController.h"
#import "Base64.h"

@interface BarcodeController ()
@property (weak, nonatomic) IBOutlet UIImageView *BarcodeImage;

@end

@implementation BarcodeController

@synthesize base64barcode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSData* data = [Base64 decode:base64barcode];
    self.BarcodeImage.image = [UIImage imageWithData:data];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
