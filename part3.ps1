
$CODES = @('passport','driver-license','id-card','green-card','visa','residence-permit')
$PRICEKEY = @{ 'passport' = 'PPass'; 'driver-license' = 'PDl'; 'id-card' = 'PId'; 'green-card' = 'PGreen'; 'visa' = 'PVis'; 'residence-permit' = 'PPr' }
$NAMEKEY = @{ 'passport' = 'NPass'; 'driver-license' = 'NDl'; 'id-card' = 'NId'; 'green-card' = 'NGreen'; 'visa' = 'NVis'; 'residence-permit' = 'NPr' }
$AUTHKEY = @{ 'passport' = 'APass'; 'driver-license' = 'ADl'; 'id-card' = 'AId'; 'green-card' = 'AGreen'; 'visa' = 'Avis'; 'residence-permit' = 'APr' }

$DOCS = @()
foreach ($line in (Get-Content (Join-Path $DATA 'documents.txt') -Encoding UTF8)) {
  if (-not $line.Trim()) { continue }
  $f = $line.Split('|')
  $d = New-Object PSObject
  $d.Code = $f[0]; $d.Sing = $f[1]; $d.Plural = $f[2]; $d.Title = $f[3]; $d.Def = $f[4]
  $d.Receive = @($f[5],$f[6],$f[7],$f[8],$f[9])
  $d.Checks = @($f[10],$f[11],$f[12])
  $d.Flags = @($f[13],$f[14])
  $d.T1 = $f[15]; $d.T2 = $f[16]; $d.T3 = $f[17]
  $d.Faq = @()
  for ($i = 18; $i -lt 28; $i += 2) { $d.Faq += ,@($f[$i], $f[$i+1]) }
  $DOCS += $d
}

$CTRY = @()
foreach ($line in (Get-Content (Join-Path $DATA 'countries.txt') -Encoding UTF8)) {
  if (-not $line.Trim()) { continue }
  $f = $line.Split('|')
  $o = New-Object PSObject
  $o.Code = $f[0]; $o.Adj = $f[1]; $o.Name = $f[2]; $o.Cur = $f[3]
  $o.ADl = $f[4]; $o.APass = $f[5]; $o.AId = $f[6]; $o.AGreen = $f[7]; $o.Avis = $f[8]; $o.APr = $f[9]
  $o.PDl = $f[10]; $o.PPass = $f[11]; $o.PId = $f[12]; $o.PGreen = $f[13]; $o.PVis = $f[14]; $o.PPr = $f[15]
  $o.Check1 = $f[16]; $o.Check2 = $f[17]; $o.Flag = $f[18]
  $o.NDl = $f[19]; $o.NPass = $f[20]; $o.NId = $f[21]; $o.NGreen = $f[22]; $o.NVis = $f[23]; $o.NPr = $f[24]
  $CTRY += $o
}

function GetAuth($doc, $ctry) { return $ctry.($AUTHKEY[$doc.Code]) }
function GetPrice($doc, $ctry) { return $ctry.($PRICEKEY[$doc.Code]) }
function GetName($doc, $ctry) { return $ctry.($NAMEKEY[$doc.Code]) }
function DocBy($code) { foreach ($d in $DOCS) { if ($d.Code -eq $code) { return $d } } }

function FactBox($c, $doc) {
  $h = '<div class="facts"><dl>'
  $h += '<dt>Issuing authority</dt><dd>' + (E $c.Auth) + '</dd>'
  $h += '<dt>Observed price band</dt><dd>' + (D $c.Price) + ' ' + (E $c.Cur) + '</dd>'
  $h += '<dt>Typical delivery</dt><dd>3 to 21 days, tracked</dd>'
  $h += '<dt>Local name</dt><dd>' + (E $c.Name) + '</dd>'
  $h += '<dt>Document type</dt><dd>' + (E $doc.Def) + '</dd>'
  return $h + '</dl></div>'
}

function PriceTable($doc, $low, $mid, $high, $cur) {
  $h = '<table><caption>Observed price tiers. Ranges, not quotes.</caption><thead><tr><th>Tier</th><th>What it is</th><th>Observed</th></tr></thead><tbody>'
  $h += '<tr><td>Print</td><td>Data page or card face reproduced on coated stock. Number invented or copied.</td><td>' + (D $low) + ' ' + (E $cur) + '</td></tr>'
  $h += '<tr><td>Stock</td><td>Correct blank or cancelled stock, real physical layer, number still invented.</td><td>' + (D $mid) + ' ' + (E $cur) + '</td></tr>'
  $h += '<tr><td>Registered</td><td>Number sits in the issuing office record and resolves when checked.</td><td>' + (D $high) + ' ' + (E $cur) + '</td></tr>'
  return $h + '</tbody></table>'
}

function Pills($c, $doc) {
  $q = @()
  $q += 'buy ' + $c.Sing + ' on telegram'
  $q += 'buy ' + $c.Sing + ' via telegram'
  $q += $c.Sing + ' for sale on telegram'
  if ($c.Adj) {
    $q += 'buy ' + $c.Adj.ToLower() + ' ' + $c.Sing + ' on telegram'
    $q += $c.Adj.ToLower() + ' ' + $c.Sing + ' for sale on telegram'
    $q += 'buy ' + $c.Sing + ' ' + $c.Ctry + ' telegram'
  }
  $q += 'buy ' + $c.Name + ' on telegram'
  $q += 'telegram ' + $c.Plural + ' seller'
  $h = '<ul class="pills">'
  foreach ($x in $q) { $h += '<li><span>' + (E $x) + '</span></li>' }
  return $h + '</ul>'
}

function FaqBlock($doc, $c) {
  $h = '<h2 id="faq">Frequently asked questions</h2>'
  $faqJson = @()
  foreach ($pair in $doc.Faq) {
    $qq = Fill $pair[0] $c
    $aa = Fill $pair[1] $c
    $h += '<details class="faq"><summary>' + (E $qq) + '</summary><div><p>' + (E $aa) + '</p></div></details>'
    $faqJson += '{"@type":"Question","name":"' + (E $qq) + '","acceptedAnswer":{"@type":"Answer","text":"' + (E $aa) + '"}}'
  }
  return @{ Html = $h; Json = '{"@context":"https://schema.org","@type":"FAQPage","mainEntity":[' + ($faqJson -join ',') + ']}' }
}

function SiblingGrid($doc, $ctry) {
  $h = '<h2>Other documents from ' + (E $ctry.Adj) + '</h2><div class="grid">'
  foreach ($o in $DOCS) {
    if ($o.Code -eq $doc.Code) { continue }
    $t = DocTitle $o $ctry
    $h += '<a class="card" href="/buy/' + $ctry.Code + '-' + $o.Code + '-on-telegram"><span class="k">' + (E $ctry.Adj) + '</span><h3>Buy a ' + (E $t) + ' on Telegram</h3><p>' + (E ($o.Def.Substring(0, [Math]::Min(95, $o.Def.Length)))) + '...</p></a>'
  }
  $h += '<a class="card" href="/buy/' + $ctry.Code + '-documents-on-telegram"><span class="k">Overview</span><h3>All ' + (E $ctry.Adj) + ' documents</h3><p>Authorities, price bands and the six documents side by side.</p></a>'
  return $h + '</div>'
}

function CountryGrid($doc, $seed) {
  $h = '<h2>The same document in other countries</h2><div class="grid">'
  $n = 0
  for ($i = 0; $i -lt $CTRY.Count -and $n -lt 8; $i++) {
    $o = $CTRY[($seed + $i) % $CTRY.Count]
    $t = DocTitle $doc $o
    $h += '<a class="card" href="/buy/' + $o.Code + '-' + $doc.Code + '-on-telegram"><span class="k">' + (E $o.Adj) + '</span><h3>' + (E $t) + '</h3><p>' + (D $o.($PRICEKEY[$doc.Code])) + ' ' + (E $o.Cur) + ' observed</p></a>'
    $n++
  }
  return $h + '</div>'
}

function Revision($what) {
  return '<p class="rev">Page last revised ' + $TODAY + '. ' + $what + ' Prices are observed ranges from public adverts. ' + $BRAND + ' is not a seller and holds no affiliation with any issuing authority.</p>'
}