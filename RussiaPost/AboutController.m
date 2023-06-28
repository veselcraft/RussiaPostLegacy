//
//  AboutController.m
//  RussiaPost
//
//  Created by miles on 28.06.23.
//  Copyright (c) 2023 Miles Prower. All rights reserved.
//

#import "AboutController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface AboutController () {
    int count;
}

@end

@implementation AboutController

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
	// Do any additional setup after loading the view.
}

- (IBAction)SecretButtonPressed:(id)sender {
    if (count == nil) {
        count = 0;
    }
    count++;
    if (count % 5 == 0)
    {
        NSString *urlToRzhaka = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"sveta_kakala.mp4"];
        
        MPMoviePlayerViewController *mp = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:urlToRzhaka]];
        [mp.moviePlayer prepareToPlay];
        mp.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
        mp.view.frame = self.view.bounds;
        [[self navigationController] presentMoviePlayerViewControllerAnimated:mp];
        [mp.moviePlayer play];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
