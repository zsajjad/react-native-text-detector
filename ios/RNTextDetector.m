
#import "RNTextDetector.h"

#import <React/RCTBridge.h>
#import <React/RCTLog.h>

#import <FirebaseCore/FirebaseCore.h>
#import <FirebaseMLVision/FirebaseMLVision.h>

@implementation RNTextDetector


- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

static NSString *const detectionNoResultsMessage = @"Something went wrong";


NSMutableArray* prepareOutput(FIRVisionText *result) {
    NSMutableArray *output = [NSMutableArray array];
    for (FIRVisionTextBlock *block in result.blocks) {
        
        NSMutableArray *blockElements = [NSMutableArray array];
        for (FIRVisionTextLine *line in block.lines) {
            NSMutableArray *lineElements = [NSMutableArray array];
            for (FIRVisionTextElement *element in line.elements) {
                NSMutableDictionary *e = [NSMutableDictionary dictionary];
                e[@"text"] = element.text;
                e[@"cornerPoints"] = element.cornerPoints;
                e[@"confidence"] = element.confidence;
                e[@"bounding"] = @{
                                   @"top": @(element.frame.origin.y),
                                   @"left": @(element.frame.origin.x),
                                   @"width": @(element.frame.size.width),
                                   @"height": @(element.frame.size.height)
                                   };
                [lineElements addObject:e];
            }
            
            NSMutableDictionary *l = [NSMutableDictionary dictionary];
            l[@"text"] = line.text;
            l[@"cornerPoints"] = line.cornerPoints;
            l[@"confidence"] = line.confidence;
            l[@"elements"] = lineElements;
            l[@"bounding"] = @{
                               @"top": @(line.frame.origin.y),
                               @"left": @(line.frame.origin.x),
                               @"width": @(line.frame.size.width),
                               @"height": @(line.frame.size.height)
                               };
            [blockElements addObject:l];
        }
        
        NSMutableDictionary *b = [NSMutableDictionary dictionary];
        b[@"text"] = block.text;
        b[@"cornerPoints"] = block.cornerPoints;
        b[@"confidence"] = block.confidence;
        b[@"bounding"] = @{
                           @"top": @(block.frame.origin.y),
                           @"left": @(block.frame.origin.x),
                           @"width": @(block.frame.size.width),
                           @"height": @(block.frame.size.height)
                           };
        b[@"lines"] = blockElements;
        [output addObject:b];
    }
    return output;
}

RCT_REMAP_METHOD(detectFromUri, detectFromUri:(NSString *)imagePath resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    if (!imagePath) {
        RCTLog(@"No image path found");
        resolve(@NO);
        return;
    }
    
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
        
        [textRecognizer processImage:handler completion:^(FIRVisionText *_Nullable result, NSError *_Nullable error) {
            @try {
                if (error != nil || result == nil) {
                    NSString *errorString = error ? error.localizedDescription : detectionNoResultsMessage;
                    @throw [NSException exceptionWithName:@"failure" reason:errorString userInfo:nil];
                    return;
                }
                NSMutableArray *output = prepareOutput(result);
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

RCT_REMAP_METHOD(detectFromFile, detectFromFile:(NSString *)imagePath resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    if (!imagePath) {
        resolve(@NO);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
        UIImage *image = [UIImage imageWithData:imageData];
        
        if (!image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                resolve(@NO);
            });
            return;
        }
        
        FIRVision *vision = [FIRVision vision];
        FIRVisionTextRecognizer *textRecognizer = [vision onDeviceTextRecognizer];
        FIRVisionImage *handler = [[FIRVisionImage alloc] initWithImage:image];
        
        [textRecognizer processImage:handler completion:^(FIRVisionText *_Nullable result, NSError *_Nullable error) {
            @try {
                if (error != nil || result == nil) {
                    NSString *errorString = error ? error.localizedDescription : detectionNoResultsMessage;
                    @throw [NSException exceptionWithName:@"failure" reason:errorString userInfo:nil];
                    return;
                }
            
                NSMutableArray *output = prepareOutput(result);
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
