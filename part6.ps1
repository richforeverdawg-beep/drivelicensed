
function BuildBlog() {
  $posts = @()
  foreach ($line in (Get-Content (Join-Path $DATA 'blog.txt') -Encoding UTF8)) {
    if (-not $line.Trim()) { continue }
    $f = $line.Split('|')
    $posts += ,$f
  }
  $h = '<p class="lede">Longer pieces on the mechanics: security features, payment structure, and why deals fail. Reference reading, not news.</p><ul class="post-list">'
  foreach ($f in $posts) { $h += '<li><h3><a href="/blog/' + $f[0] + '">' + (E $f[1]) + '</a></h3><p>' + (E $f[2]) + '</p></li>' }
  $h += '</ul>'
  Simple '/blog' 'Blog: Document Security and Buying Mechanics' 'Longer reference pieces on document security features, payment structure, replica versus original, and why Telegram deals fail.' 'Blog' $h 'COL'
  foreach ($f in $posts) {
    $url = '/blog/' + $f[0]
    $bh = ''
    for ($i = 3; $i -le 10; $i++) { if ($i -lt $f.Count -and $f[$i]) { $bh += '<p>' + (E $f[$i]) + '</p>' } }
    $faqJson = @()
    $fh = '<h2>Quick answers</h2>'
    for ($i = 11; $i -lt $f.Count - 1; $i += 2) {
      if ($f[$i]) { $fh += '<details class="faq"><summary>' + (E $f[$i]) + '</summary><div><p>' + (E $f[$i+1]) + '</p></div></details>'; $faqJson += '{"@type":"Question","name":"' + (E $f[$i]) + '","acceptedAnswer":{"@type":"Answer","text":"' + (E $f[$i+1]) + '"}}' }
    }
    $bh += $fh
    $bh += '<div class="cta"><h2>Put it to use</h2><p>Pick a document and a country, then run the checks in order.</p><a class="btn" href="/buy/passport-on-telegram">Passport guide</a><a class="btn alt" href="/buy/driver-license-on-telegram">Licence guide</a></div>'
    $bh += Revision 'Article reviewed.'
    $jl = CrumbJson @(@{H='Home';U='/'}, @{H='Blog';U='/blog'}, @{H=$f[1];U=$url})
    $art = '{"@context":"https://schema.org","@type":"Article","headline":"' + (E $f[1]) + '","description":"' + (E $f[2]) + '","url":"' + $SITE + $url + '","dateModified":"' + $TODAY + '","author":{"@type":"Organization","name":"' + $BRAND + '"},"isPartOf":{"@type":"WebSite","url":"' + $SITE + '/"}}'
    $json = '[' + $jl + ',' + $art + ',{"@context":"https://schema.org","@type":"FAQPage","mainEntity":[' + ($faqJson -join ',') + ']}]'
    $body = '<nav class="crumbs" aria-label="Breadcrumb"><ol><li><a href="/">Home</a></li><li><a href="/blog">Blog</a></li><li aria-current="page">' + (E $f[1]) + '</li></ol></nav><h1>' + (E $f[1]) + '</h1><p class="lede">' + (E $f[2]) + '</p>' + $bh
    Emit @{ Url = $url; Title = $f[1]; Desc = (Norm-D $f[2]); Body = $body; Json = $json; Tier = 'BLOG'; Target = '' }
  }
}

# ---------- run ----------
if (Test-Path $DIST) { Remove-Item $DIST -Recurse -Force }
New-Item -ItemType Directory -Path $DIST -Force | Out-Null
Copy-Item (Join-Path $ROOT 'style.css') (Join-Path $DIST 'style.css') -Force

BuildSupport
BuildBlog
foreach ($o in $CTRY) { BuildHub $o; BuildT2 $o }
foreach ($d in $DOCS) { BuildT1 $d $false; BuildT1 $d $true }
foreach ($o in $CTRY) { foreach ($d in $DOCS) { BuildT3 $d $o } }
foreach ($o in $CTRY) { BuildT3B (DocBy 'driver-license') $o }

# robots, indexnow key, 404
$rob = "User-agent: *`nAllow: /`n`nUser-agent: GPTBot`nAllow: /`n`nUser-agent: Google-Extended`nAllow: /`n`nUser-agent: Bingbot`nAllow: /`n`nSitemap: $SITE/sitemap.xml`n"
W 'robots.txt' $rob
W ($KEY + '.txt') $KEY
$nf = '<h1>Page not found</h1><p class="lede">That URL does not exist. The document and country indexes are both complete, so start there.</p><div class="grid"><a class="card" href="/countries"><h3>Countries</h3><p>Thirty markets, six documents each</p></a><a class="card" href="/buy/passport-on-telegram"><h3>Passport guide</h3><p>Start with the most complex document</p></a></div>'
$body404 = '<h1>404 &ndash; Page not found</h1>' + $nf
$json404 = '[{"@context":"https://schema.org","@type":"WebPage","name":"Page not found"}]'
W '404.html' (Shell @{ Url = '/404'; Title = '404: Page Not Found on DriveLicensed'; Desc = (Norm-D 'That page does not exist. Use the country index or the passport guide to find what you need.'); Body = $body404; Json = $json404 })

# sitemap
$sm = '<?xml version="1.0" encoding="UTF-8"?>' + "`n" + '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' + "`n"
foreach ($pg in $script:Pages) { $sm += '  <url><loc>' + $SITE + $pg.Url + '</loc><lastmod>' + $TODAY + '</lastmod></url>' + "`n" }
$sm += '</urlset>' + "`n"
W 'sitemap.xml' $sm

# ---------- audit ----------
$TARGET = @{ 'T1' = 1400; 'T2' = 900; 'T3' = 700; 'T3B' = 400; 'HUB' = 150; 'BLOG' = 450; 'PAGE' = 60; 'COL' = 50; 'HOME' = 200 }
foreach ($pg in $script:Pages) {
  $u = $pg.Url
  if ($pg.Title.Length -lt 20 -or $pg.Title.Length -gt 66) { Add-Issue "title length $($pg.Title.Length) on $u" }
  if ($pg.Desc.Length -lt 110 -or $pg.Desc.Length -gt 168) { Add-Issue "description length $($pg.Desc.Length) on $u" }
  $h1c = ([regex]::Matches($pg.Body, '<h1[ >]')).Count
  if ($h1c -ne 1) { Add-Issue "H1 count $h1c on $u" }
  if ($pg.Body -notmatch 'class="crumbs"') { Add-Issue "no breadcrumb on $u" }
  $txt = Strip $pg.Body
  $moji = ([string][char]0x00C3) + "|" + ([string][char]0x00E2) + "|" + ([string][char]0x20AC) + "|" + ([string][char]0x00C2); if ($txt -match $moji) { Add-Issue "mojibake on $u" }
  if ($pg.Body -match '\{[A-Z_]+\}') { Add-Issue "unreplaced token on $u" }
  if ($pg.Target) {
    if ($txt.ToLower() -notmatch [regex]::Escape($pg.Target)) { Add-Issue "target query missing from body on $u" }
    if ($pg.Body.ToLower() -notmatch ('<h2[^>]*>[^<]*' + [regex]::Escape($pg.Target))) { Add-Issue "target query missing from H2 on $u" }
  }
  $wc = ($txt -split '\s+').Count
  if ($TARGET.ContainsKey($pg.Tier) -and $wc -lt $TARGET[$pg.Tier]) { Add-Issue "word count $wc below $($TARGET[$pg.Tier]) on $u" }
  foreach ($m in [regex]::Matches($pg.Body, 'href="(/[^"#?]*)"')) {
    $href = $m.Groups[1].Value.TrimEnd('/')
    if ($href -eq '') { continue }
    if (-not (Test-Path (Join-Path $DIST ($href.TrimStart('/') + '\index.html')))) { Add-Issue "broken internal link $href on $u" }
  }
}
foreach ($f in @('style.css','robots.txt','sitemap.xml','404.html')) { if (-not (Test-Path (Join-Path $DIST $f))) { Add-Issue "missing file $f" } }
$dupes = $script:Pages | Group-Object Title | Where-Object { $_.Count -gt 1 }
foreach ($d in $dupes) { Add-Issue "duplicate title: $($d.Name)" }
$dupes = $script:Pages | Group-Object Desc | Where-Object { $_.Count -gt 1 }
foreach ($d in $dupes) { Add-Issue "duplicate description: $($d.Name)" }

if ($script:Issues.Count -gt 0) {
  Write-Host ""
  Write-Host "$($script:Issues.Count) issues:" -ForegroundColor Yellow
  foreach ($i in $script:Issues) { Write-Host "  $i" -ForegroundColor Yellow }
  Write-Host ""
  exit 1
}
Write-Host ""
Write-Host "Pages built: $($script:Pages.Count)" -ForegroundColor Green
Write-Host "Issues: 0" -ForegroundColor Green
Write-Host "Done. dist is ready." -ForegroundColor Green