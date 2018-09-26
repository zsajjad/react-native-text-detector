
#import "RNTextDetector.h"

#import <React/RCTBridge.h>

#import <CoreML/CoreML.h>
#import <Vision/Vision.h>
#import <TesseractOCR/TesseractOCR.h>

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

RCT_REMAP_METHOD(detect, detect:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
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
        
        @try {
            G8Tesseract *tesseract = [[G8Tesseract alloc] initWithLanguage:[options valueForKey:language]];
            tesseract.delegate = self;
            [tesseract setImage:preprocessedImageForTesseract(image, [options valueForKey:@"imageTransformationMode"] || 0)];
            
            [tesseract recognize];
            if ([options valueForKey:segementation]) {
                [tesseract setPageSegmentationMode:getPageSegmentationMode([options valueForKey:segementation])];
            }
            
            NSMutableArray *output = [NSMutableArray array];
            NSArray *elements = [tesseract recognizedBlocksByIteratorLevel:getPageIteratorLevel([options valueForKey:iterator])];
            for (G8RecognizedBlock *e in elements) {
                [output addObject:@{
                                    @"text": [e.text stringByReplacingOccurrencesOfString:@"\n" withString:@""],
                                    @"bounding": rectToDictionary(getScaledBoundingFromImage(e.boundingBox, image)),
                                    @"confidence": @(e.confidence)
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

@end
