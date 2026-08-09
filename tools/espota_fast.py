"""Run PlatformIO's ESP32 OTA uploader from the project configuration."""

from pathlib import Path


original_uploader = (
    Path.home()
    / ".platformio"
    / "packages"
    / "framework-arduinoespressif32"
    / "tools"
    / "espota.py"
)

source = original_uploader.read_text(encoding="utf-8")
globals_dict = {
    "__file__": str(original_uploader),
    "__name__": "__main__",
    "__package__": None,
}
exec(compile(source, str(original_uploader), "exec"), globals_dict)
