//
//  UIImage+HEIC.m
//  Test
//
//  Created by Tim Johnsen on 10/13/17.
//  Copyright © 2017 Tim Johnsen. All rights reserved.
//

#import "UIImage+HEIC.h"
#import <AVFoundation/AVMediaFormat.h>

#define SIMULATE_HEIC_UNAVAILABLE 0

NSData *_Nullable tj_UIImageHEICRepresentation(UIImage *const image, const CGFloat compressionQuality)
{
    NSData *imageData = nil;
#if !SIMULATE_HEIC_UNAVAILABLE
    if (@available(iOS 11.0, *)) {
        if (image) {
            NSMutableData *destinationData = [NSMutableData new];
            CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)destinationData, (__bridge CFStringRef)AVFileTypeHEIC, 1, NULL);
            if (destination) {
                NSDictionary *options = @{(__bridge NSString *)kCGImageDestinationLossyCompressionQuality: @(compressionQuality)};
                CGImageDestinationAddImage(destination, image.CGImage, (__bridge CFDictionaryRef)options);
                CGImageDestinationFinalize(destination);
                imageData = destinationData;
                CFRelease(destination);
            }
        }
    }
#endif
    return imageData;
}

@implementation UIGraphicsImageRenderer (TJHEICAdditions)

- (nullable NSData *)tj_HEICDataWithCompressionQuality:(const CGFloat)compressionQuality
                                               actions:(NS_NOESCAPE UIGraphicsImageDrawingActions)actions
{
    return [self tj_HEICDataWithCompressionQuality:compressionQuality
                                           actions:actions
                                          fallback:nil];
}

- (nullable NSData *)tj_HEICDataWithCompressionQuality:(const CGFloat)compressionQuality
           fallingBackToJPEGDataWithCompressionQuality:(const CGFloat)jpegCompressionQuality
                                               actions:(NS_NOESCAPE UIGraphicsImageDrawingActions)actions
{
    return [self tj_HEICDataWithCompressionQuality:compressionQuality
                                           actions:actions
                                          fallback:^NSData *(UIImage *image) {
                                              return UIImageJPEGRepresentation(image, jpegCompressionQuality);
                                          }];
}

- (nullable NSData *)tj_HEICDataFallingBackToPNGDataWithCompressionQuality:(const CGFloat)compressionQuality
                                                                   actions:(NS_NOESCAPE UIGraphicsImageDrawingActions)actions
{
    return [self tj_HEICDataWithCompressionQuality:compressionQuality
                                           actions:actions
                                          fallback:^NSData *(UIImage *image) {
                                              return UIImagePNGRepresentation(image);
                                          }];
}

- (nullable NSData *)tj_HEICDataWithCompressionQuality:(const CGFloat)compressionQuality
                                               actions:(NS_NOESCAPE UIGraphicsImageDrawingActions)actions
                                              fallback:(NSData *(^)(UIImage *))fallback
{
    UIImage *const image = [self imageWithActions:actions];
    NSData *data = tj_UIImageHEICRepresentation(image, compressionQuality);
    if (data.length == 0 && fallback) {
        data = fallback(image);
    }
    return data;
}

@end

@implementation UIDevice (TJHEICAdditions)

+ (BOOL)isHEICWritingSupported
{
    static BOOL isHEICSupported = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 11.0, *)) {
            NSMutableData *data = [NSMutableData data];
            CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)data, (__bridge CFStringRef)AVFileTypeHEIC, 1, nil);
            if (destination) {
                isHEICSupported = YES;
                CFRelease(destination);
            }
        }
    });
    return isHEICSupported;
}

@end
