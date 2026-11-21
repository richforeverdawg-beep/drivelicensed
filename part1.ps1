#requires -Version 5.1
$ErrorActionPreference = 'Stop'
$ROOT = $PSScriptRoot
if (-not $ROOT) { $ROOT = (Get-Location).Path }
$DIST = Join-Path $ROOT 'dist'
$DATA = Join-Path $ROOT 'documents'
$SITE = 'https://drivelicensed.com'
$BRAND = 'DriveLicensed'
$MAIL = 'drivelicensed@proton.me'
$TG = 'https://t.me/drivelicensed'
$TODAY = (Get-Date).ToString('yyyy-MM-dd')
$KEY = 'a7f3c9d1e5b2480fa6c3d9e1b7f4026c'
$ENC = New-Object System.Text.UTF8Encoding($false)
$script:Issues = New-Object System.Collections.ArrayList
$script:Pages = New-Object System.Collections.ArrayList

function Add-Issue([string]$m) { [void]$script:Issues.Add($m) }
function E([string]$s) { if ($null -eq $s) { return '' }; $t = $s.Replace('&','&amp;').Replace('<','&lt;').Replace('>','&gt;').Replace('"','&quot;').Replace("'",'&#39;'); return $t.Replace('&amp;ndash;','&ndash;') }
function D([string]$s) { if ($null -eq $s) { return '' }; $s.Replace('-','&ndash;') }
function Seed([string]$s) { $h = 11; foreach ($ch in $s.ToCharArray()) { $h = ($h * 31 + [int]$ch) % 100003 }; return [int]$h }
function Pick($a, [int]$s, [int]$o) { return $a[($s + $o) % $a.Count] }
function W([string]$rel, [string]$txt) {
  $fp = Join-Path $DIST $rel
  $dir = Split-Path $fp -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  [IO.File]::WriteAllText($fp, $txt, $ENC)
}
function Fill([string]$t, $c) {
  $t = $t.Replace('{DOC}', $c.Sing).Replace('{DOCS}', $c.Plural).Replace('{DOCT}', $c.DTitle)
  $t = $t.Replace('{ADJ}', $c.Adj).Replace('{ADJL}', $c.Adj.ToLower()).Replace('{CTRY}', $c.Ctry)
  $t = $t.Replace('{AUTH}', $c.Auth).Replace('{PRICE}', (D $c.Price)).Replace('{CUR}', $c.Cur).Replace('{NAME}', $c.Name)
  $t = $t.Replace('{Q}', $c.Query).Replace('{DEF}', $c.Def)
  return $t
}
function Norm-D([string]$d) {
  if ($d.Length -lt 110) { $d = $d + ' Observed price bands, issuing authorities and the checks that catch bad stock.' }
  while ($d.Length -gt 168 -and $d.Contains(' ')) { $d = $d.Substring(0, $d.LastIndexOf(' ')).TrimEnd(' ', ',', '.', ';') }
  if ($d.Length -gt 168) { $d = $d.Substring(0, 168) }
  if ($d.Length -lt 110) { $d = $d + ' Independent guide, no seller affiliation.' }
  return $d
}
function Strip([string]$h) { return ([regex]::Replace($h, '<[^>]+>', ' ')) }

function Crumb($items) {
  $h = '<nav class="crumbs" aria-label="Breadcrumb"><ol>'
  for ($i = 0; $i -lt $items.Count; $i++) {
    if ($items[$i].U) { $h += '<li><a href="' + $items[$i].U + '">' + (E $items[$i].H) + '</a></li>' }
    else { $h += '<li aria-current="page">' + (E $items[$i].H) + '</li>' }
  }
  return $h + '</ol></nav>'
}
function CrumbJson($items) {
  $parts = @()
  for ($i = 0; $i -lt $items.Count; $i++) {
    $pos = $i + 1
    $u = $SITE + $items[$i].U
    if (-not $items[$i].U) { $u = $SITE + '/' }
    $parts += '{"@type":"ListItem","position":' + $pos + ',"name":"' + (E $items[$i].H) + '","item":"' + $u + '"}'
  }
  return '{"@context":"https://schema.org","@type":"BreadcrumbList","itemListElement":[' + ($parts -join ',') + ']}'
}

function Shell($o) {
  $ld = '<script type="application/ld+json">' + $o.Json + '</script>'
  $nav = @('/' , '/countries' , '/how-to-buy' , '/faq' , '/blog' , '/about')
  $lbl = @('Home' , 'Countries' , 'How to buy' , 'FAQ' , 'Blog' , 'About')
  $n = '<nav class="nav" aria-label="Primary">'
  for ($i = 0; $i -lt $nav.Count; $i++) {
    if ($o.Url -eq $nav[$i]) { $n += '<a href="' + $nav[$i] + '" aria-current="page">' + $lbl[$i] + '</a>' }
    else { $n += '<a href="' + $nav[$i] + '">' + $lbl[$i] + '</a>' }
  }
  $n += '</nav>'
  $f = '<footer class="ftr"><div class="wrap"><div class="cols">'
  $f += '<div><h2>Documents</h2><ul><li><a href="/buy/passport-on-telegram">Passport</a></li><li><a href="/buy/driver-license-on-telegram">Driver license</a></li><li><a href="/buy/id-card-on-telegram">ID card</a></li><li><a href="/buy/green-card-on-telegram">Green card</a></li><li><a href="/buy/visa-on-telegram">Visa</a></li><li><a href="/buy/residence-permit-on-telegram">Residence permit</a></li></ul></div>'
  $f += '<div><h2>Top countries</h2><ul><li><a href="/countries/usa">USA</a></li><li><a href="/countries/uk">UK</a></li><li><a href="/countries/canada">Canada</a></li><li><a href="/countries/australia">Australia</a></li><li><a href="/countries/germany">Germany</a></li><li><a href="/countries/france">France</a></li><li><a href="/countries">All 30 countries</a></li></ul></div>'
  $f += '<div><h2>Reference</h2><ul><li><a href="/how-to-buy">How to buy</a></li><li><a href="/faq">FAQ</a></li><li><a href="/blog">Blog</a></li><li><a href="/sitemap">Sitemap</a></li></ul></div>'
  $f += '<div><h2>Site</h2><ul><li><a href="/about">About</a></li><li><a href="/contact">Contact</a></li><li><a href="/privacy">Privacy</a></li><li><a href="/terms">Terms</a></li><li><a href="/disclosure">Disclosure</a></li></ul></div>'
  $f += '</div><p class="base">' + $BRAND + ' is an independent guide. Not a seller, no affiliation with any issuing authority. Prices are observed ranges. Last full build ' + $TODAY + '. <a href="mailto:' + $MAIL + '">' + $MAIL + '</a></p></div></footer>'
  $h = '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">'
  $h += '<title>' + (E $o.Title) + '</title><meta name="description" content="' + (E $o.Desc) + '">'
  $h += '<link rel="canonical" href="' + $SITE + $o.Url + '">'
  $h += '<meta property="og:type" content="website"><meta property="og:site_name" content="' + $BRAND + '">'
  $h += '<meta property="og:title" content="' + (E $o.Title) + '"><meta property="og:description" content="' + (E $o.Desc) + '">'
  $h += '<meta property="og:url" content="' + $SITE + $o.Url + '"><meta name="twitter:card" content="summary">'
  $h += '<link rel="stylesheet" href="/style.css">' + $ld + '</head><body>'
  $h += '<a class="skip" href="#main">Skip to content</a>'
  $h += '<header class="hdr"><div class="wrap"><a class="brand" href="/">Drive<span>Licensed</span></a>' + $n + '</div></header>'
  $h += '<main id="main"><div class="wrap">' + $o.Body + '</div></main>' + $f + '</body></html>'
  return $h
}

function Emit($o) {
  $rel = $o.Url.TrimStart('/')
  if ($rel -eq '') { $rel = 'index.html' } else { $rel = $rel + '/index.html' }
  W $rel (Shell $o)
  [void]$script:Pages.Add($o)
}