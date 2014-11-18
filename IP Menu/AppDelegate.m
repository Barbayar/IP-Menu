//
//  AppDelegate.m
//  IP Menu
//
//  Created by Barbayar Dashzeveg on 2014/11/18.
//  Copyright (c) 2014年 Barbayar Dashzeveg. All rights reserved.
//

#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>

#define _DATA_REFRESH_TIME_ 300

enum MENU_TAGS {_MENU_IP_, _MENU_LOCATION_, _MENU_HOSTNAME_, _MENU_ISP_, _MENU_RELOAD_};

@interface AppDelegate ()
@property (strong) NSStatusItem *statusBar;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSMenu *menu = [[NSMenu alloc] init];
    NSMenuItem *itemIp = [[NSMenuItem alloc] initWithTitle:@"-" action:NULL keyEquivalent:@""];
    itemIp.tag = _MENU_IP_;
    NSMenuItem *itemLocation = [[NSMenuItem alloc] initWithTitle:@"-" action:NULL keyEquivalent:@""];
    itemLocation.tag = _MENU_LOCATION_;
    NSMenuItem *itemHostname = [[NSMenuItem alloc] initWithTitle:@"-" action:NULL keyEquivalent:@""];
    itemHostname.tag = _MENU_HOSTNAME_;
    NSMenuItem *itemIsp = [[NSMenuItem alloc] initWithTitle:@"-" action:NULL keyEquivalent:@""];
    itemIsp.tag = _MENU_ISP_;
    NSMenuItem *itemReload = [[NSMenuItem alloc] initWithTitle:@"Reload" action:@selector(refreshData) keyEquivalent:@""];
    itemReload.tag = _MENU_RELOAD_;
    NSMenuItem *itemExit = [[NSMenuItem alloc] initWithTitle:@"Exit" action:@selector(exit) keyEquivalent:@""];

    [menu addItem:itemIp];
    [menu addItem:itemLocation];
    [menu addItem:itemHostname];
    [menu addItem:itemIsp];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItem:itemReload];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItem:itemExit];

    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusBar.highlightMode = YES;
    self.statusBar.menu = menu;

    [NSTimer scheduledTimerWithTimeInterval:_DATA_REFRESH_TIME_ target:self selector:@selector(refreshData) userInfo:nil repeats:YES];
    [self refreshData];
}

- (void)refreshData {
    if (!self.statusBar.isEnabled) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:@"http://wtfismyip.com/json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    self.statusBar.title = @"Loading...";
    self.statusBar.enabled = NO;
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[self.statusBar.menu itemWithTag:_MENU_IP_] setTitle:[responseObject valueForKey:@"YourFuckingIPAddress"]];
        [[self.statusBar.menu itemWithTag:_MENU_LOCATION_] setTitle:[responseObject valueForKey:@"YourFuckingLocation"]];
        [[self.statusBar.menu itemWithTag:_MENU_HOSTNAME_] setTitle:[responseObject valueForKey:@"YourFuckingHostname"]];
        [[self.statusBar.menu itemWithTag:_MENU_ISP_] setTitle:[responseObject valueForKey:@"YourFuckingISP"]];
        self.statusBar.title = [responseObject valueForKey:@"YourFuckingLocation"];
        self.statusBar.enabled = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[self.statusBar.menu itemWithTag:_MENU_IP_] setTitle:@"-"];
        [[self.statusBar.menu itemWithTag:_MENU_LOCATION_] setTitle:@"-"];
        [[self.statusBar.menu itemWithTag:_MENU_HOSTNAME_] setTitle:@"-"];
        [[self.statusBar.menu itemWithTag:_MENU_ISP_] setTitle:@"-"];
        self.statusBar.title = @"Failed";
        self.statusBar.enabled = YES;
    }];

    [operation start];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
}

- (void)exit {
    exit(0);
}

@end
