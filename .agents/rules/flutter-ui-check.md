# Flutter UI Verification Rule

> ⛔ **SEE ALSO**: `flutter-hot-reload.md` — the MANDATORY rule for applying code changes. Never use `flutter run` or rebuild. Always use MCP hot reload.

When any Flutter file in `lib/views/` or `lib/widgets/` is modified, the agent MUST:

1. **Hot Reload via MCP** (see `flutter-hot-reload.md` for the exact steps — this is non-negotiable)
2. **Check for Errors**: Use `get_runtime_errors` from `dart-mcp-server` to guarantee no exceptions or layout overflows were introduced.
3. **Capture UI Screenshot**: Run:
   ```bash
   cmd.exe /c "C:/Users/nikhi/AppData/Local/Android/Sdk/platform-tools/adb.exe exec-out screencap -p > ./screenshots/ui_verify.png"
   ```
4. **Visual Inspection**: Open and inspect `./screenshots/ui_verify.png` to confirm the styling and UX align with instructions before responding to the user.
