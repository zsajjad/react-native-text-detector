# React Native Text Detector

[![npm](https://img.shields.io/npm/dm/react-native-text-detector.svg)](https://www.npmjs.com/package/react-native-text-detector)

## Disclaimer 

This branch is not for use in production. Its just for comparison between different libraries. APIs for this branch might change very frequently.

## See it in action
Checkout this blog for [HeartBeat by Fritz.ai](https://heartbeat.fritz.ai/building-text-detection-apps-for-ios-and-android-using-react-native-42fe3c7e339) for example of this package.

## Getting started

`$ npm install react-native-text-detector --save` or `yarn add react-native-text-detector`

### Manual installation

Follow steps for integration from both of [Firebase](https://github.com/zsajjad/react-native-text-detector/tree/firebase) and [Tesseract](https://github.com/zsajjad/react-native-text-detector/tree/tesseract) branches.

## Usage

```javascript
/**
 *
 * This Example uses react-native-camera for getting image
 *
 */

import RNTextDetector from "react-native-text-detector";

export class TextDetectionComponent extends PureComponent {
  ...

  RNTextDetector.tesseract({
    imagePath,
    language: 'eng',
    pageIteratorLevel: 'textLine',
    pageSegmentation: 'SparseTextOSD',
    imageTransformationMode: 2, // 0. For none 1. For Greyscale 2. for Black & White.
  });

  RNTextDetector.firebase({
    imagePath,
  });

  ...
}
```
