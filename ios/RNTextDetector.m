#include <time.h>

#import "RNTextDetector.h"

#import <React/RCTBridge.h>
#import <React/RCTLog.h>

#import <TesseractOCR/TesseractOCR.h>

#import <FirebaseCore/FirebaseCore.h>
#import <FirebaseMLVision/FirebaseMLVision.h>

#import "RNTextDetectorUtils.h"

@implementation RNTextDetector


- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

static NSString *detectionNoResultsMessage = @"Something went wrong";

static NSString *language = @"language";
static NSString *path = @"imagePath";
static NSString *iterator = @"pageIteratorLevel";
static NSString *segementation = @"pageSegmentation";
static NSString *imageTransformation = @"imageTransformation";

G8PageSegmentationMode getPageSegmentationMode(NSString *value) {
    // TODO: return based on value coming from JS Thread.
    return G8PageSegmentationModeSparseTextOSD;
}

G8PageIteratorLevel getPageIteratorLevel(NSString *value) {
    // TODO: return based on value coming from JS Thread.
    return G8PageIteratorLevelTextline;
}

UIImage* preprocessedImageForTesseract(UIImage *sourceImage, int option) {
    switch (option) {
        case 1:
            return [sourceImage g8_grayScale];
        case 2:
            return [sourceImage g8_blackAndWhite];
        default:
            return sourceImage;
    }
}

RCT_REMAP_METHOD(tesseract, tesseract:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    if (![options valueForKey:path]) {
        resolve(@NO);
        return;
    }
    NSString *imagePath = [options valueForKey:path];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData;
        if ([imagePath rangeOfString:@"http"].location == NSNotFound) {
            imageData = [NSData dataWithContentsOfFile:imagePath];
        } else {
            imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imagePath]];
        }
        UIImage *image = [UIImage imageWithData:imageData];
        
        if (!image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                resolve(@NO);
            });
            return;
        }
        clock_t start, end;
        @try {
            G8Tesseract *tesseract = [[G8Tesseract alloc] initWithLanguage:[options valueForKey:language]];
            tesseract.delegate = self;
            start = clock();
            [tesseract setImage:preprocessedImageForTesseract(image, [options valueForKey:imageTransformation] || 0)];
            [tesseract recognize];
            [tesseract setMaximumRecognitionTime:100];
            end = clock();
            if ([options valueForKey:segementation]) {
                [tesseract setPageSegmentationMode:getPageSegmentationMode([options valueForKey:segementation])];
            }
            
            NSMutableArray *output = [NSMutableArray array];
            NSArray *elements = [tesseract recognizedBlocksByIteratorLevel:getPageIteratorLevel([options valueForKey:iterator])];
            for (G8RecognizedBlock *e in elements) {
                [output addObject:@{
                                    @"text": [e.text stringByReplacingOccurrencesOfString:@"\n" withString:@""],
                                    @"bounding": rectToDictionary(getScaledBoundingFromImage(e.boundingBox, image)),
                                    @"confidence": @(e.confidence),
                                    @"timeConsumed": @((double)(end - start) / CLOCKS_PER_SEC),
                                    }];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                resolve(output);
            });
        }
        @catch (NSException *e) {
            NSString *errorString = e ? e.reason : detectionNoResultsMessage;
            dispatch_async(dispatch_get_main_queue(), ^{
                resolve(@{
                          @"error": [NSMutableString stringWithFormat:@"On-Device text detection failed with error: %@", errorString],
                          });
            });
        }
    });
    
}

RCT_REMAP_METHOD(firebase, firebase:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    if (![options valueForKey:path]) {
        resolve(@NO);
        return;
    }
    NSString *imagePath = [options valueForKey:path];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imagePath]];
        UIImage *image = [UIImage imageWithData:imageData];
        
        if (!image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                RCTLog(@"No image found %@", imagePath);
                resolve(@NO);
            });
            return;
        }
        
        FIRVision *vision = [FIRVision vision];
        FIRVisionTextRecognizer *textRecognizer = [vision onDeviceTextRecognizer];
        FIRVisionImage *handler = [[FIRVisionImage alloc] initWithImage:image];
        clock_t start = clock();
        [textRecognizer processImage:handler completion:^(FIRVisionText *_Nullable result, NSError *_Nullable error) {
            @try {
                if (error != nil || result == nil) {
                    NSString *errorString = error ? error.localizedDescription : detectionNoResultsMessage;
                    @throw [NSException exceptionWithName:@"failure" reason:errorString userInfo:nil];
                    return;
                }
                clock_t end = clock();
                NSMutableArray *output = prepareFirebaseOutput(result, (double)(end - start) / CLOCKS_PER_SEC);
                dispatch_async(dispatch_get_main_queue(), ^{
                    resolve(output);
                });
            }
            @catch (NSException *e) {
                NSString *errorString = e ? e.reason : detectionNoResultsMessage;
                NSDictionary *pData = @{
                                        @"error": [NSMutableString stringWithFormat:@"On-Device text detection failed with error: %@", errorString],
                                        };
                dispatch_async(dispatch_get_main_queue(), ^{
                    resolve(pData);
                });
            }
            
        }];
        
    });
    
}

@end
