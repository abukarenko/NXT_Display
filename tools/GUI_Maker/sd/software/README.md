# ESP-Display Designer archive

Place the portable Windows package here with the exact name:

`ESP-Display-Designer-Windows.zip`

On the microSD card its path will be
`/software/ESP-Display-Designer-Windows.zip`.

The firmware's authenticated `POST /upload/designer` endpoint can also write
this archive directly to the card. Use `tools/upload-designer.ps1`; it sends
short checked chunks using HTTP Basic user `admin` and the OTA password.
