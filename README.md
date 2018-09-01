# React Native Text Detector [Tesseract]

[![npm](https://img.shields.io/npm/dm/react-native-text-detector.svg)](https://www.npmjs.com/package/react-native-text-detector)

## See it in action

Checkout this blog for [HeartBeat by Fritz.ai](https://heartbeat.fritz.ai/building-text-detection-apps-for-ios-and-android-using-react-native-42fe3c7e339) for example of this package.

## Getting started

`$ npm install react-native-text-detector#tesseract --save` or `yarn add react-native-text-detector#tesseract`

### Manual installation

#### iOS

##### Attach Tesseract Languages you want to use in your app

Import your tessdata folder (you can download one for your language from [Google's Repo](https://code.google.com/p/tesseract-ocr/downloads/list) OR if that gives an error use [THIS REPO](https://github.com/tesseract-ocr/tessdata/tree/bf82613055ebc6e63d9e3b438a5c234bfd638c93) as referenced on [stack overflow as solution](https://stackoverflow.com/questions/41131083/tesseract-traineddata-not-working-in-swift-3-0-project-using-version-4-0/41168236#41168236) into the root of your project AS A REFERENCED FOLDER (see below). It contains the Tesseract trained data files. You can add your own trained data files here too.

NOTE: This library currently requires the tessdata folder to be linked as a referenced folder instead of a symbolic group. If Tesseract can't find a language file in your own project, it's probably because you created the tessdata folder as a symbolic group instead of a referenced folder. It should look like this if you did it correctly:

![alt text](https://cloud.githubusercontent.com/assets/817753/4598582/aeba675c-50ba-11e4-8d14-c7af9336b965.png "guide")

Note how the tessdata folder has a blue icon, indicating it was imported as a referenced folder instead of a symbolic group.

##### Also add `-lstdc++` if not already present

##### Using Pods (Recommended)

1. Add following in `ios/Podfile`

```ruby
    pod 'RNTextDetector', path: '../node_modules/react-native-text-detector/ios'
```

2. Run following from project's root directory

```bash
    cd ios && pod install
```

3. Use `<your_project>.xcworkspace` to run your app

##### Direct Linking

1.  In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2.  Go to `node_modules` ➜ `react-native-text-detector` and add `RNTextDetector.xcodeproj`
3.  In XCode, in the project navigator, select your project. Add `libRNTextDetector.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4.  Run your project (`Cmd+R`)<

#### Android

##### Attach Tesseract Languages you want to use in your app

1.  Open up `android/app/src/main/java/[...]/MainActivity.java`

- Add `import com.fetchsky.RNTextDetector.RNTextDetectorPackage;` to the imports at the top of the file
- Add `new RNTextDetectorPackage()` to the list returned by the `getPackages()` method

2.  Append the following lines to `android/settings.gradle`:
    ```
    include ':react-native-text-detector'
    project(':react-native-text-detector').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-text-detector/android')
    ```
3.  Insert the following lines inside the dependencies block in `android/app/build.gradle`:

    ```groovy
    ...
    dependencies {
        implementation project(':react-native-text-detector')
    }
    ```

4.  [v3.04 Trained data](https://github.com/tesseract-ocr/tessdata/tree/3.04.00) files for a language must be extracted in android/app/src/main/assets/tessdata.

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

  detectText = async () => {
    try {
      const options = {
        quality: 0.8,
        base64: true,
        skipProcessing: true,
      };
      const { uri } = await this.camera.takePictureAsync(options);
      const visionResp = await RNTextDetector.detect({
          imagePath: uri, // this can be remote url as well, package will handle such url internally
          language: "eng",
          pageIteratorLevel: "textLine",
          pageSegmentation: "SparseTextOSD" // optional
          charWhitelist: "01234567" // optional
          charBlacklist: "01234567" // optional
          imageTransformationMode: 2, // optional | 0 => none | 1 => g8_grayScale | 2 => g8_blackAndWhite
      });
      console.log('visionResp', visionResp);
    } catch (e) {
      console.warn(e);
    }
  };

  ...
}
```
