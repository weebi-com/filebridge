# filebridge


- saving and loading file

- linux requires jni
- there may already be an issue https://github.com/dart-lang/native/issues?q=is%3Aissue+is%3Aopen+label%3Apackage%3Ajni

To fix:
- Fork https://github.com/dart-lang/native
- Navigate to pkgs/jni/src/CMakeLists.txt
- Make JNI optional (change REQUIRED to optional and wrap in if(JNI_FOUND))
- Publish our fork or use it via git dependency
``` yaml
dependency_overrides:
  jni:
    git:
      url: https://github.com/YOUR_USERNAME/native
      path: pkgs/jni
      ref: your-branch-name
```