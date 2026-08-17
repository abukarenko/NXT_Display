# Local microSD image

This folder is the editable desktop copy of the display microSD card.

Copy the contents of this `sd` folder to the root of the physical card:

```text
sd/icons    -> /icons
sd/images   -> /images
sd/scripts  -> /scripts
sd/startup.example.txt -> /startup.txt (rename after copying)
```

Firmware commands use absolute SD paths, for example:

```text
SC|/scripts/demo.nxt
JPG|1|20|20|/icons/play.jpg|1
```

Script files are plain text. One GUI command per line. Empty lines and lines
starting with `#` are ignored.

`/startup.txt` may contain up to three Wi-Fi profiles (`SSID`/`PASS`,
`SSID1`/`PASS1`, and `SSID2`/`PASS2`) followed by a `SCREEN =` section.
Because it contains passwords, the real `sd/startup.txt` is ignored by Git.
