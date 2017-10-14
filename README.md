# UIImageHEIC

Apple introduced widespread HEIC support with iOS 11, but the APIs for it are somewhat low level. This tiny project adds a familiar interface for encoding `UIImage`s into HEIC data similar to what we're doing with JPEG or PNG data.

## Installation

Add the UIImage+HEIC.h and UIImage+HEIC.m source files to your project. At the moment you must be using Xcode 9 / building with the iOS 11 SDK to use this.

## Usage

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
