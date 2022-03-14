package com.youku.ribut.channel.sandbox;

import android.os.Build;
import android.text.TextUtils;

import com.youku.ribut.utils.AppInfoUtils;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * @author: shisan.lms
 * @date: 2021-06-28
 * Description:
 */
public class SandBoxUtils {

    private static final String[] TEXT_TYPE = {"xml", "json"};

    private static String ROOT_PATH = AppInfoUtils.getApplicationContext().getApplicationInfo().dataDir;

    public static List<File> getRootFiles() {
        return getFiles(new File(ROOT_PATH));
    }

    public static List<File> getDPMFiles() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            return getFiles(new File(AppInfoUtils.getApplicationContext().getApplicationInfo().deviceProtectedDataDir));
        }
        return null;
    }

    public static List<File> getFiles(File curFile) {
        List<File> descriptors = new ArrayList<>();
        if (curFile.isDirectory() && curFile.exists()) {

            File[] files = curFile.listFiles();
            if (files != null && files.length > 0) {
                if (files.length >= 2) {
                    descriptors.addAll(Arrays.asList(files));
                } else {
                    descriptors.add(files[0]);
                }
            }
            Collections.sort(descriptors, new Comparator<File>() {
                @Override
                public int compare(File file1, File file2) {
                    if ((file1.isFile() && file2.isFile()) || (file1.isDirectory() && file2.isDirectory())) {
                        return file1.getName().compareToIgnoreCase(file2.getName());
                    }
                    if (file1.isDirectory() && file2.isFile()) {
                        return 1;
                    }
                    if (file1.isFile() && file2.isDirectory()) {
                        return -1;
                    }
                    return 0;
                }
            });
        }
        return descriptors;
    }

    public static boolean isTextFile(String filename) {
        if (TextUtils.isEmpty(filename)) {
            return false;
        }
        for (String type : TEXT_TYPE) {
            if (filename.endsWith(type)) {
                return true;
            }
        }
        return false;

    }
}
