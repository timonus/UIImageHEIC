//
//  UIImage+HEIC.m
//  Test
//
//  Created by Tim Johnsen on 10/13/17.
//  Copyright © 2017 Tim Johnsen. All rights reserved.
//

#import "UIImage+HEIC.h"
#import <AVFoundation/AVMediaFormat.h>
#import <pthread.h>

#define SIMULATE_HEIC_UNAVAILABLE 0

NSData *_Nullable tj_UIImageHEICRepresentation(UIImage *const image, const CGFloat compressionQuality)
{
    NSData *imageData = nil;
#if !SIMULATE_HEIC_UNAVAILABLE
#if defined(__IPHONE_17_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_17_0
    if (compressionQuality >= 1.0) {
        if (@available(iOS 17.0, *)) {
            return UIImageHEICRepresentation(image);
        }
    }
#endif
#if !defined(__IPHONE_11) || __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_11
    if (@available(iOS 11.0, *))
#endif
    {
        if (image) {
            NSMutableData *destinationData = [NSMutableData new];
            CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)destinationData, (__bridge CFStringRef)AVFileTypeHEIC, 1, NULL);
            if (destination) {
                NSDictionary *options = @{(__bridge NSString *)kCGImageDestinationLossyCompressionQuality: @(compressionQuality)};
                
                // iOS devices seem to corrupt image data when concurrently creating HEIC images.
                // Locking to ensure HEIC creation doesn't occur concurrently.
                pthread_mutex_t *lock = tj_HEICEncodingLock();
                pthread_mutex_lock(lock);
                
                CGImageDestinationAddImage(destination, image.CGImage, (__bridge CFDictionaryRef)options);
                CGImageDestinationFinalize(destination);
                
                pthread_mutex_unlock(lock);
                
                imageData = destinationData;
                CFRelease(destination);
            }
        }
    }
#endif
    return imageData;
}

#if defined(__has_attribute) && __has_attribute(objc_direct_members)
__attribute__((objc_direct_members))
#endif
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

#if defined(__has_attribute) && __has_attribute(objc_direct_members)
__attribute__((objc_direct_members))
#endif
@implementation UIDevice (TJHEICAdditions)

+ (BOOL)isHEICWritingSupported
{
    static BOOL isHEICSupported = NO;
#if !SIMULATE_HEIC_UNAVAILABLE
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if !defined(__IPHONE_11) || __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_11
        if (@available(iOS 11.0, *))
#endif
        {
            // https://developer.apple.com/forums/thread/129662
            isHEICSupported = [(__bridge_transfer NSArray<NSString *> *)CGImageDestinationCopyTypeIdentifiers() containsObject:AVFileTypeHEIC];
        }
    });
#endif
    return isHEICSupported;
}

@end

BOOL tj_CGImageSourceUTIIsHEIC(const CGImageSourceRef imageSource)
{
    BOOL isHEIC = NO;
#if !defined(__IPHONE_11) || __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_11
    if (@available(iOS 11.0, *))
#endif
    {
        if (imageSource) {
            NSString *const uti = (__bridge_transfer NSString *)CGImageSourceGetType(imageSource);
            isHEIC = [uti isEqualToString:AVFileTypeHEIC];
        }
    }
    return isHEIC;
}

BOOL tj_isImageAtPathHEIC(NSString *const path)
{
    BOOL isHEIC = NO;
    const CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:path isDirectory:NO], nil);
    if (imageSource) {
        isHEIC = tj_CGImageSourceUTIIsHEIC(imageSource);
        CFRelease(imageSource);
    }
    return isHEIC;
}

pthread_mutex_t *tj_HEICEncodingLock(void)
{
    static pthread_mutex_t lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pthread_mutex_init(&lock, nil);
    });
    return &lock;
}
