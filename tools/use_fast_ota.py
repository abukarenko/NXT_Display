Import("env")

import re
from pathlib import Path


secrets_file = Path(env.subst("$PROJECT_DIR/include/ota_secrets.h"))
if secrets_file.exists():
    secrets_text = secrets_file.read_text(encoding="utf-8")
    password_match = re.search(
        r'^\s*#define\s+OTA_PASSWORD\s+"([^"]*)"',
        secrets_text,
        re.MULTILINE,
    )
    if password_match and password_match.group(1):
        env.Append(UPLOADERFLAGS=[f"--auth={password_match.group(1)}"])

env.Replace(UPLOADER=env.subst("$PROJECT_DIR/tools/espota_fast.py"))
