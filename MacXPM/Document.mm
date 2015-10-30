//
//  Document.m
//  MacXPM
//
//  Created by Kevin Wojniak on 10/29/15.
//  Copyright © 2015 Kevin Wojniak. All rights reserved.
//

#import "Document.h"
#include <Magick++.h>

static NSImage* imageFromData(NSData *inputData) {
    try {
        const Magick::Blob inputBlob(inputData.bytes, inputData.length);
        Magick::Image img(inputBlob);
        Magick::Blob outputBlob;
        img.magick("RGBA");
        img.write(&outputBlob);
        if (outputBlob.length() == 0) {
            return nil;
        }
        NSData *outputData = [NSData dataWithBytes:outputBlob.data() length:outputBlob.length()];
        if (!outputData) {
            return nil;
        }
        NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:nullptr
                                                                        pixelsWide:img.size().width()
                                                                        pixelsHigh:img.size().height()
                                                                     bitsPerSample:8
                                                                   samplesPerPixel:4
                                                                          hasAlpha:YES
                                                                          isPlanar:NO
                                                                    colorSpaceName:NSCalibratedRGBColorSpace
                                                                       bytesPerRow:img.size().width() * 4
                                                                      bitsPerPixel:32];
        memcpy(rep.bitmapData, outputBlob.data(), outputBlob.length());
        NSImage *nsimg = [[NSImage alloc] init];
        [nsimg addRepresentation:rep];
        return nsimg;
    } catch (const std::exception& error) {
        NSLog(@"Exception: %s", error.what());
        return nil;
    } catch (...) {
        return nil;
    }
}

@interface Document ()

@property (assign) IBOutlet NSImageView *imageView;
@property (retain) NSImage *image;

@end

@implementation Document

+ (void)load {
    (void)setenv("MAGICK_HOME", [[NSBundle mainBundle] resourcePath].UTF8String, 1);
    Magick::InitializeMagick(nullptr);
}

- (NSString *)windowNibName {
    return @"Document";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController {
    [super windowControllerDidLoadNib:windowController];
    self.imageView.image = self.image;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    NSImage *img = imageFromData(data);
    if (!img) {
        return NO;
    }
    self.image = img;
    return YES;
}

@end
