
package com.fetchsky.RNTextDetector;

import android.annotation.SuppressLint;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Rect;
import android.os.AsyncTask;
import android.os.Environment;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.annotations.VisibleForTesting;
import com.googlecode.tesseract.android.ResultIterator;
import com.googlecode.tesseract.android.TessBaseAPI;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class RNTextDetectorModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;
    private TessBaseAPI tessBaseApi;

    @VisibleForTesting
    private static final String REACT_CLASS = "RNTextDetector";

    private static String DATA_PATH = Environment.getExternalStorageDirectory().toString() + File.separator;
    private static final String TESSDATA = "tessdata";

    private static final String PATH_KEY = "imagePath";
    private static final String LANGUAGE_KEY = "language";
    private static final String WHITELIST_KEY = "charWhitelist";
    private static final String BLACKLIST_KEY = "charBlacklist";
    private static final String ITERATOR_KEY = "pageIteratorLevel";
    private static final String SEGMENTATION_KEY = "pageSegmentation";


    public RNTextDetectorModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        if (!this.DATA_PATH.contains(reactContext.getPackageName())) {
            this.DATA_PATH += reactContext.getPackageName() + File.separator;
        }
    }

    private int getIteratorLevel(String value) {
        return TessBaseAPI.PageIteratorLevel.RIL_TEXTLINE;
    }

    private int getPageSegmentationMode(String value) {
        return TessBaseAPI.PageSegMode.PSM_AUTO_OSD;
    }

    @SuppressLint("StaticFieldLeak")
    @ReactMethod
    public void detect(final ReadableMap options, final Promise promise) {
        try {
            prepareTesseract();
            BitmapFactory.Options bitmapOptions = new BitmapFactory.Options();
            final Bitmap bitmap;

            if (options.getString(PATH_KEY).contains("http")) {
                bitmap = RNTextDetectorUtils.getBitmapFromURL(options.getString(PATH_KEY));
            } else {
                bitmap = BitmapFactory.decodeFile(options.getString(PATH_KEY), bitmapOptions);
            }

            new AsyncTask<Void, Void, WritableArray>() {
                protected WritableArray doInBackground(Void... params) {
                    tessBaseApi = new TessBaseAPI();
                    tessBaseApi.init(DATA_PATH, options.getString(LANGUAGE_KEY));

                    if (options.hasKey(SEGMENTATION_KEY)) {
                        tessBaseApi.setPageSegMode(getPageSegmentationMode(options.getString(SEGMENTATION_KEY)));

                    }

                    //Whitelist - List of characters you want to detect
                    if (options.hasKey(WHITELIST_KEY) &&
                            options.getString(WHITELIST_KEY) != null
                            && !options.getString(WHITELIST_KEY).isEmpty()) {
                        tessBaseApi.setVariable(TessBaseAPI.VAR_CHAR_WHITELIST, options.getString(WHITELIST_KEY));
                    }

                    if (options.hasKey(BLACKLIST_KEY) &&
                            options.getString(BLACKLIST_KEY) != null
                            && !options.getString(BLACKLIST_KEY).isEmpty()) {
                        tessBaseApi.setVariable(TessBaseAPI.VAR_CHAR_BLACKLIST, options.getString(BLACKLIST_KEY));
                    }

                    tessBaseApi.setImage(bitmap);

                    WritableArray output = Arguments.createArray();
                    WritableMap tempMap;
                    WritableMap bounding;

                    String extractedText = tessBaseApi.getUTF8Text();
                    int iteratorLevel = getIteratorLevel(options.getString(ITERATOR_KEY));
                    final ResultIterator iterator = tessBaseApi.getResultIterator();
                    iterator.begin();
                    do {
                        tempMap = Arguments.createMap();
                        bounding = Arguments.createMap();

                        Rect rect = iterator.getBoundingRect(iteratorLevel);
                        bounding.putInt("top", rect.top);
                        bounding.putInt("left", rect.left);
                        bounding.putInt("width", rect.width());
                        bounding.putInt("height", rect.height());

                        tempMap.putString("text", iterator.getUTF8Text(iteratorLevel));
                        tempMap.putDouble("confidence", iterator.confidence(iteratorLevel));
                        tempMap.putMap("bounding", bounding);
                        output.pushMap(tempMap);
                    } while (iterator.next(iteratorLevel));
                    iterator.delete();

                    tessBaseApi.end();
                    return output;
                }
                protected void onPostExecute(WritableArray result) {
                    promise.resolve(result);
                }
            }.execute();
        } catch (Exception e) {
            promise.reject(e);
            e.printStackTrace();
        }
    }

    private void prepareDirectory(String path) {
        File dir = new File(path);
        if (!dir.exists()) {
            if (!dir.mkdirs()) {
                Log.e(REACT_CLASS, "ERROR: Creation of directory " + path
                        + " failed, check permission to write to external storage.");
            }
        } else {
            Log.i(REACT_CLASS, "Created directory " + path);
        }
    }

    private void prepareTesseract() {
        Log.d(REACT_CLASS, "Preparing tesseract enviroment");

        try {
            prepareDirectory(DATA_PATH + TESSDATA);
        } catch (Exception e) {
            e.printStackTrace();
        }

        copyTessDataFiles(TESSDATA);
    }


    private void copyTessDataFiles(String path) {
        try {
            String fileList[] = reactContext.getAssets().list(path);

            for (String fileName : fileList) {

                String pathToDataFile = DATA_PATH + path + "/" + fileName;
                if (!(new File(pathToDataFile)).exists()) {

                    InputStream in = reactContext.getAssets().open(path + "/" + fileName);

                    OutputStream out = new FileOutputStream(pathToDataFile);

                    byte[] buf = new byte[1024];
                    int len;

                    while ((len = in.read(buf)) > 0) {
                        out.write(buf, 0, len);
                    }
                    in.close();
                    out.close();

                    Log.d(REACT_CLASS, "Copied " + fileName + "to tessdata");
                }
            }
        } catch (IOException e) {
            Log.e(REACT_CLASS, "Unable to copy files to tessdata " + e.toString());
        }
    }


    @Override
    public String getName() {
        return "RNTextDetector";
    }
}