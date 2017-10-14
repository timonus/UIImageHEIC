//
//  UIImage+HEIC.h
//  Test
//
//  Created by Tim Johnsen on 10/13/17.
//  Copyright © 2017 Tim Johnsen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Returns and NSData HEIC representation of the image if possible, otherwise returns nil.
NSData *_Nullable tj_UIImageHEICRepresentation(UIImage *const image, const CGFloat compressionQuality);

NS_ASSUME_NONNULL_END
