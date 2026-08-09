"""Run PlatformIO's ESP32 OTA uploader with a full-size TCP payload."""

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
old_chunk = "chunk = f.read(1024)"
new_chunk = "chunk = f.read(1460)"

if source.count(old_chunk) != 1:
    raise RuntimeError(
        f"Unsupported espota.py version: expected one '{old_chunk}' in {original_uploader}"
    )

source = source.replace(old_chunk, new_chunk)
globals_dict = {
    "__file__": str(original_uploader),
    "__name__": "__main__",
    "__package__": None,
}
exec(compile(source, str(original_uploader), "exec"), globals_dict)
