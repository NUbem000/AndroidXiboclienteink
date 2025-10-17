#include <jni.h>
#include <android/log.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <string.h>
#include <errno.h>

#define LOG_TAG "EinkController"
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGW(...) __android_log_print(ANDROID_LOG_WARN, LOG_TAG, __VA_ARGS__)

// E-ink device paths
#define EINK_DEVICE "/dev/eink-panel"
#define EINK_DEVICE_ALT "/dev/epd"

// E-ink refresh modes (device-specific, may need adjustment)
#define EINK_INIT_MODE 0
#define EINK_DU_MODE 1          // Direct Update (fast, for text)
#define EINK_GC16_MODE 2        // Grayscale Clearing (16 levels)
#define EINK_GL16_MODE 3        // Grayscale (16 levels)
#define EINK_A2_MODE 4          // Animation mode (fast)
#define EINK_FULL_REFRESH 5     // Full refresh (anti-ghosting)
#define EINK_PARTIAL_REFRESH 6  // Partial refresh

class EinkController {
private:
    int fd;
    bool isInitialized;
    int currentMode;
    int refreshCount;

public:
    EinkController() : fd(-1), isInitialized(false), currentMode(EINK_GC16_MODE), refreshCount(0) {}

    ~EinkController() {
        closeDevice();
    }

    bool openDevice() {
        if (fd >= 0) {
            return true; // Already open
        }

        // Try primary device path
        fd = open(EINK_DEVICE, O_RDWR);
        if (fd < 0) {
            LOGD("Failed to open %s: %s", EINK_DEVICE, strerror(errno));

            // Try alternative device path
            fd = open(EINK_DEVICE_ALT, O_RDWR);
            if (fd < 0) {
                LOGE("Failed to open %s: %s", EINK_DEVICE_ALT, strerror(errno));
                return false;
            }
            LOGI("Opened alternative device: %s", EINK_DEVICE_ALT);
        } else {
            LOGI("Opened device: %s", EINK_DEVICE);
        }

        isInitialized = true;
        return true;
    }

    void closeDevice() {
        if (fd >= 0) {
            close(fd);
            fd = -1;
            isInitialized = false;
            LOGD("Device closed");
        }
    }

    bool setRefreshMode(int mode) {
        if (!ensureDeviceOpen()) {
            return false;
        }

        // This is device-specific. Adjust ioctl command for your device
        // For now, we just log it
        currentMode = mode;
        LOGD("Refresh mode set to: %d", mode);
        return true;
    }

    bool fullRefresh() {
        if (!ensureDeviceOpen()) {
            return false;
        }

        LOGD("Performing full refresh");

        // Device-specific ioctl for full refresh
        // This is a placeholder - adjust for your actual device
        // int result = ioctl(fd, EINK_FULL_REFRESH_IOCTL, NULL);

        // For now, just sync to ensure all writes are flushed
        fsync(fd);

        refreshCount = 0;
        return true;
    }

    bool partialRefresh() {
        if (!ensureDeviceOpen()) {
            return false;
        }

        LOGD("Performing partial refresh");

        // Device-specific ioctl for partial refresh
        // int result = ioctl(fd, EINK_PARTIAL_REFRESH_IOCTL, NULL);

        fsync(fd);

        refreshCount++;

        // Auto full refresh every 10 partial refreshes to prevent ghosting
        if (refreshCount >= 10) {
            LOGI("Auto-triggering full refresh after %d partial refreshes", refreshCount);
            return fullRefresh();
        }

        return true;
    }

    bool clearScreen() {
        if (!ensureDeviceOpen()) {
            return false;
        }

        LOGD("Clearing screen");

        // Device-specific clear command
        // For now, trigger a full refresh
        return fullRefresh();
    }

    int getRefreshCount() {
        return refreshCount;
    }

    bool isDeviceAvailable() {
        if (fd >= 0) {
            return true;
        }
        return openDevice();
    }

private:
    bool ensureDeviceOpen() {
        if (fd < 0) {
            LOGW("Device not open, attempting to open...");
            return openDevice();
        }
        return true;
    }
};

// Global instance
static EinkController* g_controller = nullptr;

extern "C" {

JNIEXPORT jboolean JNICALL
Java_com_xibo_eink_eink_EinkDisplayManager_nativeInit(JNIEnv* env, jobject thiz) {
    if (g_controller == nullptr) {
        g_controller = new EinkController();
    }
    return g_controller->openDevice();
}

JNIEXPORT void JNICALL
Java_com_xibo_eink_eink_EinkDisplayManager_nativeRelease(JNIEnv* env, jobject thiz) {
    if (g_controller != nullptr) {
        delete g_controller;
        g_controller = nullptr;
    }
}

JNIEXPORT jboolean JNICALL
Java_com_xibo_eink_eink_EinkDisplayManager_nativeFullRefresh(JNIEnv* env, jobject thiz) {
    if (g_controller == nullptr) {
        LOGE("Controller not initialized");
        return JNI_FALSE;
    }
    return g_controller->fullRefresh() ? JNI_TRUE : JNI_FALSE;
}

JNIEXPORT jboolean JNICALL
Java_com_xibo_eink_eink_EinkDisplayManager_nativePartialRefresh(JNIEnv* env, jobject thiz) {
    if (g_controller == nullptr) {
        LOGE("Controller not initialized");
        return JNI_FALSE;
    }
    return g_controller->partialRefresh() ? JNI_TRUE : JNI_FALSE;
}

JNIEXPORT jboolean JNICALL
Java_com_xibo_eink_eink_EinkDisplayManager_nativeSetRefreshMode(JNIEnv* env, jobject thiz, jint mode) {
    if (g_controller == nullptr) {
        LOGE("Controller not initialized");
        return JNI_FALSE;
    }
    return g_controller->setRefreshMode(mode) ? JNI_TRUE : JNI_FALSE;
}

JNIEXPORT jboolean JNICALL
Java_com_xibo_eink_eink_EinkDisplayManager_nativeClearScreen(JNIEnv* env, jobject thiz) {
    if (g_controller == nullptr) {
        LOGE("Controller not initialized");
        return JNI_FALSE;
    }
    return g_controller->clearScreen() ? JNI_TRUE : JNI_FALSE;
}

JNIEXPORT jint JNICALL
Java_com_xibo_eink_eink_EinkDisplayManager_nativeGetRefreshCount(JNIEnv* env, jobject thiz) {
    if (g_controller == nullptr) {
        return 0;
    }
    return g_controller->getRefreshCount();
}

JNIEXPORT jboolean JNICALL
Java_com_xibo_eink_eink_EinkDisplayManager_nativeIsDeviceAvailable(JNIEnv* env, jobject thiz) {
    if (g_controller == nullptr) {
        g_controller = new EinkController();
    }
    return g_controller->isDeviceAvailable() ? JNI_TRUE : JNI_FALSE;
}

} // extern "C"
