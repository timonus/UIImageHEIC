# UIImageHEIC

Apple introduced widespread HEIC support with iOS 11, but the APIs for it are somewhat low level. This tiny project adds a familiar interface for encoding `UIImage`s into HEIC data similar to what we're used to doing with JPEG or PNG data.

## Installation

Add the UIImage+HEIC.h and UIImage+HEIC.m source files to your project. At the moment you must be using Xcode 9 / building with the iOS 11 SDK to use this.

## Usage

### Converting `UIImage`s to HEIC

This adds a function named `tj_UIImageHEICRepresentation` that behaves just like `UIImageJPEGRepresentation`. The method returns `nil` in the event that HEIC encoding isn't possible on the current device.

So, where you used to have

```
UIImage *image = /**/;
NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
```

You could now have

```
UIImage *image = /**/;
NSData *imageData = tj_UIImageHEICRepresentation(image, 0.8);
if (imageData.length == 0) {
    imageData = UIImageJPEGRepresentation(image, 0.8);
}
```

### `UIGraphicsImageRenderer` Extensions

This project also adds a category to `UIGraphicsImageRenderer` for HEIC exporting support with fallbacks to PNG or JPEG. It's used just like you use `UIGraphicsImageRenderer`'s existing PNG and JPEG exporting methods.

Before

```
UIGraphicsImageRenderer *renderer = /**/;
NSData *data = [renderer PNGDataWithActions:/**/];
```

After with no fallback

```
UIGraphicsImageRenderer *renderer = /**/;
NSData *data = [renderer tj_HEICDataWithCompressionQuality:1.0 actions:/**/];
```

After falling back to PNG

```
UIGraphicsImageRenderer *renderer = /**/;
NSData *data = [renderer tj_HEICDataFallingBackToPNGDataWithCompressionQuality:1.0 actions:/**/];
```

After falling back to JPEG

```
UIGraphicsImageRenderer *renderer = /**/;
NSData *data = [renderer tj_HEICDataWithCompressionQuality:1.0 fallingBackToJPEGDataWithCompressionQuality:1.0 actions:/**/];
```

### Checking HEIC images

You can check if the image at a particular path is a HEIC image using `tj_isImageAtPathHEIC` on devices that support HEIC reading.

```
BOOL isHEICImage = tj_isImageAtPathHEIC(/*path to an image*/);
```

For lower level access you can also use `tj_CGImageSourceUTIIsHEIC`, which allows you to check using an image source made from data or a URL, and is also helpful if you want to immediately use the image source to perform a transformation in the event it is HEIC.

```
BOOL isHEICImageSource = tj_CGImageSourceUTIIsHEIC(/*image source*);
```
