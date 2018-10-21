# react-native-text-detector

## Getting started

`$ npm install react-native-text-detector --save` or `yarn add react-native-text-detector`

### Manual installation

#### iOS

Please create project on firebase console, Download a GoogleService-Info.plist file from [Firebase console](https://console.firebase.google.com/?pli=1) and include it in your app.

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

1.  Open up `android/app/src/main/java/[...]/MainApplication.java`

- Add `import com.fetchsky.RNTextDetector.RNTextDetectorPackage;` to the imports at the top of the file
- Add `new RNTextDetectorPackage()` to the list returned by the `getPackages()` method

2.  Append the following lines to `android/settings.gradle`:
    ```
    include ':react-native-text-detector'
    project(':react-native-text-detector').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-text-detector/android')
    ```
3.  Insert the following lines inside the dependencies block in `android/app/build.gradle`:

    ```
    ...
    dependencies {
        implementation 'com.google.firebase:firebase-core:16.0.1'
        implementation 'com.google.firebase:firebase-ml-vision:17.0.0'

        implementation (project(':react-native-text-detector')) {
            exclude group: 'com.google.firebase'
        }
    }

    // Place this line at the end of file

    apply plugin: 'com.google.gms.google-services'

    // Work around for onesignal-gradle-plugin compatibility
    com.google.gms.googleservices.GoogleServicesPlugin.config.disableVersionCheck = true
    ```

4.  Insert the following lines inside the dependencies block in `android/build.gradle`:

    ```
    buildscript {
        repositories {
            google()
            ...
        }
        dependencies {
            classpath 'com.android.tools.build:gradle:3.0.1'
            classpath 'com.google.gms:google-services:4.0.1' // google-services plugin
        }
    }
    ```

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
      const visionResp = await RNTextDetector.detectFromUri(uri);
      console.log('visionResp', visionResp);
    } catch (e) {
      console.warn(e);
    }
  };

  ...
}
```
