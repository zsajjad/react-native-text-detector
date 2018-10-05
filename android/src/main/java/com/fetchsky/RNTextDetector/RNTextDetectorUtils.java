package com.fetchsky.RNTextDetector;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.google.firebase.ml.vision.text.FirebaseVisionText;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.concurrent.TimeUnit;

class RNTextDetectorUtils {
    public static Bitmap getBitmapFromURL(String src) {
        try {
            URL url = new URL(src);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setDoInput(true);
            connection.connect();
            InputStream input = connection.getInputStream();
            Bitmap myBitmap = BitmapFactory.decodeStream(input);
            return myBitmap;
        } catch (IOException e) {
            // Log exception
            return null;
        }
    }

    /**
     * Converts firebaseVisionText into a map
     *
     * @param firebaseVisionText
     * @return
     */
    public static WritableArray prepareFirebaseOutput(FirebaseVisionText firebaseVisionText, double timeConsumed) {
        WritableArray data = Arguments.createArray();

        for (FirebaseVisionText.TextBlock block: firebaseVisionText.getTextBlocks()) {
            WritableArray blockElements = Arguments.createArray();

            for (FirebaseVisionText.Line line: block.getLines()) {
                WritableArray lineElements = Arguments.createArray();
                for (FirebaseVisionText.Element element: line.getElements()) {
                    WritableMap e = Arguments.createMap();

                    WritableMap eCoordinates = Arguments.createMap();
                    eCoordinates.putInt("top", element.getBoundingBox().top);
                    eCoordinates.putInt("left", element.getBoundingBox().left);
                    eCoordinates.putInt("width", element.getBoundingBox().width());
                    eCoordinates.putInt("height", element.getBoundingBox().height());

                    e.putString("text", element.getText());
//                    e.putDouble("confidence", element.getConfidence());
                    e.putMap("bounding", eCoordinates);
                    lineElements.pushMap(e);
                }

                WritableMap l = Arguments.createMap();

                WritableMap lCoordinates = Arguments.createMap();
                lCoordinates.putInt("top", line.getBoundingBox().top);
                lCoordinates.putInt("left", line.getBoundingBox().left);
                lCoordinates.putInt("width", line.getBoundingBox().width());
                lCoordinates.putInt("height", line.getBoundingBox().height());

                l.putString("text", line.getText());
//                l.putDouble("confidence", line.getConfidence());
                l.putMap("bounding", lCoordinates);
                l.putArray("elements", lineElements);

                blockElements.pushMap(l);
            }
            WritableMap info = Arguments.createMap();
            WritableMap coordinates = Arguments.createMap();

            coordinates.putInt("top", block.getBoundingBox().top);
            coordinates.putInt("left", block.getBoundingBox().left);
            coordinates.putInt("width", block.getBoundingBox().width());
            coordinates.putInt("height", block.getBoundingBox().height());

            info.putMap("bounding", coordinates);
            info.putString("text", block.getText());
            info.putArray("lines", blockElements);
            info.putDouble("timeConsumed", timeConsumed);

//            info.putDouble("confidence", block.getConfidence());
            data.pushMap(info);
        }

        return data;
    }

    public static double getConsumedTime(long start, long end) {
        return TimeUnit.MILLISECONDS.convert(end - start, TimeUnit.NANOSECONDS) / 1000.0;
    }

}
