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
