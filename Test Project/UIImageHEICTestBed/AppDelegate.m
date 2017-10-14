//
//  AppDelegate.m
//  UIImageHEICTestBed
//
//  Created by Tim Johnsen on 10/13/17.
//  Copyright © 2017 Tim Johnsen. All rights reserved.
//

#import "AppDelegate.h"
#import "UIImage+HEIC.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://lorempixel.com/500/500/"]]];
    
    {
        NSData *highQualityJPEGData = UIImageJPEGRepresentation(image, 1.0);
        NSData *highQualityHEICData = UIImageHEICRepresentation(image, 1.0);
        NSUInteger highQualityJPEGDataLength = highQualityJPEGData.length;
        NSUInteger highQualityHEICDataLength = highQualityHEICData.length;
        
        NSLog(@"At 100%% quality:");
        NSLog(@"JPEG: %lu bytes", (unsigned long)highQualityJPEGDataLength);
        NSLog(@"HEIC: %lu bytes", (unsigned long)highQualityHEICDataLength);
        NSLog(@"HEIC is %0.2f%% the size of JPEG", 100.0 * (double)highQualityHEICDataLength / (double)highQualityJPEGDataLength);
    }
    
    {
        NSData *lowQualityJPEGData = UIImageJPEGRepresentation(image, 0.5);
        NSData *lowQualityHEICData = UIImageHEICRepresentation(image, 0.5);
        NSUInteger lowQualityJPEGDataLength = lowQualityJPEGData.length;
        NSUInteger lowQualityHEICDataLength = lowQualityHEICData.length;
        
        NSLog(@"At 50%% quality:");
        NSLog(@"JPEG: %lu bytes", (unsigned long)lowQualityJPEGDataLength);
        NSLog(@"HEIC: %lu bytes", (unsigned long)lowQualityHEICDataLength);
        NSLog(@"HEIC is %0.2f%% the size of JPEG", 100.0 * (double)lowQualityHEICDataLength / (double)lowQualityJPEGDataLength);
    }
    
    return YES;
}

@end
