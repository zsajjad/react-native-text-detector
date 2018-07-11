
#import "RNTextDetector.h"

#import <React/RCTBridge.h>

// #import <FirebaseCore/FirebaseCore.h>
// #import <FirebaseMLVision/FIRVision.h>
// #import <FirebaseMLVision/FIRVisionTextDetector.h>
// #import <FirebaseMLVision/FIRVisionImage.h>
// #import <FirebaseMLVision/FIRVisionText.h>

@implementation RNTextDetector


- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

static NSString *const detectionNoResultsMessage = @"No results returned.";

RCT_REMAP_METHOD(detectFromUri, detectFromUri:(NSString *)imagePath resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    if (!imagePath) {
        resolve(@NO);
        return;
    }
    resolve(@YES);
//     NSURL *imageURL = [NSURL URLWithString:imagePath];
//     NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
//     FIRVision *vision = [FIRVision vision];
//     FIRVisionTextDetector *textDetector = [vision textDetector];
//     FIRVisionImage *image = [[FIRVisionImage alloc] initWithImage:[UIImage imageWithData:imageData]];

//     [textDetector detectInImage:image completion:^(NSArray<FIRVisionText *> * _Nullable features, NSError * _Nullable error) {
//         if (!features || features.count == 0) {
//             // [START_EXCLUDE]
//             NSString *errorString = error
//             ? error.localizedDescription
//             : detectionNoResultsMessage;
        
//             NSDictionary *pData = @{
//                 @"error": [NSMutableString stringWithFormat:@"On-Device text detection failed with error: %@", errorString]
//             };
//             resolve(pData);
//             // [END_EXCLUDE]
//             return;
//         }
        
//         if (error != nil) {
//             RCTLog(@"Hello World Resolving NO");
//             resolve(@NO);
//             return;
//         } else if (features != nil) {
//             RCTLog(@"I am logging now!!");

//             RCTLog(@"%@", features);
//             NSMutableArray *output = [NSMutableArray array];
//             for (id <FIRVisionText> feature in features) {
//                 NSString *value = feature.text;
//                 RCTLog(value);
//                 NSDictionary *pData = @{
//                 @"text": feature.text
//                 };
// //                     [pData setValue:feature.text forKey:@"text"];
// //                     [pData setValue:feature.cornerPoints forKey:@"bounding"];
//                 [output addObject:pData];
//             }
//             resolve(output);
//         }
//     }];
}



@end
  