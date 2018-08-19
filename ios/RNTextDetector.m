
#import "RNTextDetector.h"

#import <React/RCTBridge.h>

#import <CoreML/CoreML.h>
#import <Vision/Vision.h>
#import <TesseractOCR/TesseractOCR.h>

@implementation RNTextDetector


- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

static NSString *const detectionNoResultsMessage = @"Something went wrong";

RCT_REMAP_METHOD(detectFromUri, detectFromUri:(NSString *)imagePath resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    if (!imagePath) {
        resolve(@NO);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        VNDetectTextRectanglesRequest *textReq = [VNDetectTextRectanglesRequest new];
        NSDictionary *d = [[NSDictionary alloc] init];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imagePath]];
        UIImage *image = [UIImage imageWithData:imageData];
        
        if (!image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                resolve(@NO);
            });
            return;
        }
        
        VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithData:imageData options:d];
        
        NSError *error;
        [handler performRequests:@[textReq] error:&error];
        if (error || !textReq.results || textReq.results.count == 0) {
            NSString *errorString = error ? error.localizedDescription : detectionNoResultsMessage;
            NSDictionary *pData = @{
                                    @"error": [NSMutableString stringWithFormat:@"On-Device text detection failed with error: %@", errorString],
                                    };
            // Running on background thread, don't call UIKit
            dispatch_async(dispatch_get_main_queue(), ^{
                resolve(pData);
            });
            return;
        }
        
        
        G8Tesseract *tesseract = [[G8Tesseract alloc] initWithLanguage:@"eng"];
        tesseract.delegate = self;
        [tesseract setImage:image];
        CGRect boundingBox;
        CGSize size;
        CGPoint origin;
        NSMutableArray *output = [NSMutableArray array];
        
        for(VNTextObservation *observation in textReq.results){
            if(observation){
                NSMutableDictionary *block = [NSMutableDictionary dictionary];
                NSMutableDictionary *bounding = [NSMutableDictionary dictionary];
                
                boundingBox = observation.boundingBox;
                size = CGSizeMake(boundingBox.size.width * image.size.width, boundingBox.size.height * image.size.height);
                origin = CGPointMake(boundingBox.origin.x * image.size.width, (1-boundingBox.origin.y)*image.size.height - size.height);
                
                tesseract.rect = CGRectMake(origin.x, origin.y, size.width, size.height);
                [tesseract recognize];
                
                bounding[@"top"] = @(origin.y);
                bounding[@"left"] = @(origin.x);
                bounding[@"width"] = @(size.width);
                bounding[@"height"] = @(size.height);
                block[@"text"] = [tesseract.recognizedText stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                block[@"bounding"] = bounding;
                [output addObject:block];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            resolve(output);
        });
    });
    
}

@end
