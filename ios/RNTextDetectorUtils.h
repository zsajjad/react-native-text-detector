//
//  RNTextDetectorUtils.h
//  Pods
//
//  Created by Zain Sajjad on 22/09/2018.
//

#ifndef RNTextDetectorUtils_h
#define RNTextDetectorUtils_h


#endif /* RNTextDetectorUtils_h */


CGRect getScaledBoundingFromImage(CGRect boundingBox, UIImage *image) {
    CGSize size = CGSizeMake(
                             boundingBox.size.width * image.size.width,
                             boundingBox.size.height * image.size.height
                             );
    
    return CGRectMake(
                      boundingBox.origin.x * image.size.width,
                      (1 - boundingBox.origin.y) * image.size.height - size.height,
                      size.width,
                      size.height
                      );
}

CGRect getScaledBoundingFromRect(CGRect minor, CGRect major) {
    return CGRectMake(minor.origin.x * major.origin.x,
                      minor.origin.y * major.origin.y,
                      minor.size.width * major.size.width,
                      minor.size.height * major.size.height);
}


NSDictionary* rectToDictionary(CGRect rect) {
    return @{
             @"top": @(rect.origin.y),
             @"left": @(rect.origin.x),
             @"width": @(rect.size.width),
             @"height": @(rect.size.height)
             };
}


NSMutableArray* prepareFirebaseOutput(FIRVisionText *result, double timeConsumed) {
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
        b[@"timeConsumed"] = @(timeConsumed);
        [output addObject:b];
    }
    return output;
}
