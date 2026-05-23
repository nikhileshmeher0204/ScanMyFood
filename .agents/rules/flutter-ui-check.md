---
trigger: manual
---

# Flutter UI Verification Rule

When any file in `lib/ui/` or `lib/widgets/` is modified, or after any `flutter run` or hot reload command, the agent MUST:

1.  **Ensure the app is running** on the connected Android emulator.
2.  **Capture the Screenshot** using the most reliable command (pre-configured for this environment):
    ```bash
    C:/Users/nikhi/AppData/Local/Android/Sdk/platform-tools/adb.exe exec-out screencap -p > ./screenshots/ui_verify.png
    ```
    _(Note: This uses direct binary streaming which is faster and avoids path issues on the device.)_
3.  **Prepare for Review**:
    - Copy the screenshot to the current conversation's `artifacts/` directory.
    - Embed the image in an `implementation_plan.md` or `walkthrough.md` using the absolute artifact path.
4.  **Upload Visual Artifact**: Explicitly mention the verification status and provide the image for user review before completing the task.
