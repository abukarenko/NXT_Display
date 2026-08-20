param(
  [Parameter(Mandatory = $true)]
  [string]$EspAddress,
  [Parameter(Mandatory = $true)]
  [string]$FilePath,
  [Parameter(Mandatory = $true)]
  [string]$Password,
  [string]$User = 'admin',
  [int]$ChunkSize = 2MB
)

$ErrorActionPreference = 'Stop'
$source = Get-Item -LiteralPath $FilePath
if ($ChunkSize -lt 64KB -or $ChunkSize -gt 4MB) {
  throw 'ChunkSize must be between 64 KB and 4 MB.'
}

$handler = [Net.Http.HttpClientHandler]::new()
$client = [Net.Http.HttpClient]::new($handler)
$client.Timeout = [TimeSpan]::FromMinutes(2)
$client.DefaultRequestHeaders.ConnectionClose = $true
$client.DefaultRequestHeaders.ExpectContinue = $false
$credentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${User}:${Password}"))
$client.DefaultRequestHeaders.Authorization = [Net.Http.Headers.AuthenticationHeaderValue]::new('Basic', $credentials)
$stream = [IO.File]::OpenRead($source.FullName)

try {
  $offset = 0L
  while ($offset -lt $source.Length) {
    $count = [int][Math]::Min($ChunkSize, $source.Length - $offset)
    $buffer = [byte[]]::new($count)
    $read = 0
    while ($read -lt $count) {
      $part = $stream.Read($buffer, $read, $count - $read)
      if ($part -le 0) { throw 'Unexpected end of source archive.' }
      $read += $part
    }

    $fileContent = [Net.Http.ByteArrayContent]::new($buffer)
    $fileContent.Headers.ContentType = [Net.Http.Headers.MediaTypeHeaderValue]::new('application/zip')
    $form = [Net.Http.MultipartFormDataContent]::new()
    $form.Add($fileContent, 'file', 'designer.part')
    $uri = "http://${EspAddress}/upload/designer?offset=${offset}&total=$($source.Length)"
    $response = $client.PostAsync($uri, $form).GetAwaiter().GetResult()
    $body = $response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
    if (-not $response.IsSuccessStatusCode) {
      throw "ESP upload failed at offset ${offset}: HTTP $([int]$response.StatusCode) $body"
    }
    $offset += $count
    $percent = [Math]::Floor($offset * 100 / $source.Length)
    Write-Progress -Activity 'Uploading ESP-Display Designer to ESP SD' -Status "$offset / $($source.Length) bytes" -PercentComplete $percent
    Write-Host "Uploaded $offset / $($source.Length) bytes"
    $form.Dispose()
    Start-Sleep -Milliseconds 250
  }
  Write-Progress -Activity 'Uploading ESP-Display Designer to ESP SD' -Completed
  Write-Host 'Designer archive upload complete.'
} finally {
  $stream.Dispose()
  $client.Dispose()
  $handler.Dispose()
}
