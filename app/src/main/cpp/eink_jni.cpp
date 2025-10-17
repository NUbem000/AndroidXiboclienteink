#include <jni.h>

// JNI_OnLoad - called when the library is loaded
JNIEXPORT jint JNI_OnLoad(JavaVM* vm, void* reserved) {
    return JNI_VERSION_1_6;
}

// JNI_OnUnload - called when the library is unloaded
JNIEXPORT void JNI_OnUnload(JavaVM* vm, void* reserved) {
    // Cleanup if needed
}
