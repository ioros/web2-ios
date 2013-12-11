//
//  TPPlayerViewController.m
//  TilosPlayer
//
//  Created by Daniel Langh on 11/12/13.
//  Copyright (c) 2013 rumori. All rights reserved.
//

#import "TPPlayerViewController.h"

@interface TPPlayerViewController ()

@end

@implementation TPPlayerViewController


#pragma mark - actions

- (IBAction)close:(id)sender
{
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // http://archive.tilos.hu/online/2013/12/11/tilosradio-20131211-0000.mp3
}

#pragma mark -

@end
