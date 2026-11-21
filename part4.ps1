
function BuildT3($doc, $ctry) {
  $q = 'buy ' + $ctry.Adj.ToLower() + ' ' + (DocSing $doc $ctry) + ' on telegram'
  $auth = GetAuth $doc $ctry
  $price = GetPrice $doc $ctry
  $name = GetName $doc $ctry
  $c = Ctx $doc $ctry $auth $price $ctry.Cur $name $q
  $sd = Seed ($ctry.Code + '-' + $doc.Code)
  $url = '/buy/' + $ctry.Code + '-' + $doc.Code + '-on-telegram'
  $dt = DocTitle $doc $ctry
  $h = ''
  $h += '<p class="part">Part of <a href="/countries/' + $ctry.Code + '">' + (E $ctry.Adj) + ' documents</a> and the <a href="/countries">country index</a>.</p>'
  $h += '<h1>Buy a ' + (E $dt) + ' on Telegram</h1>'
  $h += '<p class="lede">' + (E (Fill (Pick $LEDE $sd 1) $c)) + '</p>'
  $h += FactBox $c $doc
  $h += '<h2>' + (E $q) + ' &ndash; the short version</h2>'
  $h += '<p>' + (E (Fill (Pick $SQ1 $sd 2) $c)) + '</p>'
  $h += '<p>' + (E (Fill (Pick $SQ2 $sd 3) $c)) + '</p>'
  $h += '<h2>Buy a ' + (E $dt) + ' via Telegram: how the transaction works</h2>'
  $h += '<p>' + (E (Fill (Pick $VIA1 $sd 4) $c)) + '</p>'
  $h += '<p>' + (E (Fill (Pick $VIA2 $sd 5) $c)) + '</p>'
  $h += '<h2>Who actually issues a ' + (E $dt) + '</h2>'
  $h += '<p>' + (E (Fill (Pick $WHO1 $sd 6) $c)) + '</p>'
  $h += '<p>' + (E (Fill (Pick $WHO2 $sd 7) $c)) + '</p>'
  $h += '<h2>Replica or registered original</h2>'
  $h += '<p>' + (E (Fill (Pick $REV1 $sd 8) $c)) + '</p>'
  $h += '<p>' + (E (Fill (Pick $REV2 $sd 9) $c)) + '</p>'
  $h += '<h2>What a fair price looks like</h2>'
  $h += '<p>' + (E (Fill (Pick $PRICE1 $sd 10) $c)) + '</p>'
  $h += '<p>' + (E (Fill (Pick $PRICE2 $sd 11) $c)) + '</p>'
  $h += PriceTable $doc $doc.T1 $doc.T2 $doc.T3 $ctry.Cur
  $h += '<p class="note">' + (E (Fill (Pick $NOTE $sd 12) $c)) + '</p>'
  $h += '<h2>The buying process, step by step</h2><p>' + (E (Fill (Pick $STEPINTRO $sd 13) $c)) + '</p><ol class="steps">'
  foreach ($s in $STEPS) { $h += '<li>' + (E (Fill $s $c)) + '</li>' }
  $h += '</ol>'
  $h += '<h2>Checks that catch bad stock</h2><p>' + (E (Fill (Pick $CHKINTRO $sd 14) $c)) + '</p><ul class="checks">'
  $h += '<li>' + (E $ctry.Check1) + '</li><li>' + (E $ctry.Check2) + '</li>'
  foreach ($s in $GCHK) { $h += '<li>' + (E (Fill $s $c)) + '</li>' }
  $h += '</ul>'
  $h += '<h2>Red flags that should end the conversation</h2><p>' + (E (Fill (Pick $FLGINTRO $sd 15) $c)) + '</p><ul class="flags">'
  $h += '<li>' + (E $ctry.Flag) + '</li>'
  foreach ($s in $GFLG) { $h += '<li>' + (E $s) + '</li>' }
  $h += '</ul>'
  $h += Pills $c $doc
  $fb = FaqBlock $doc $c
  $h += $fb.Html
  $h += '<div class="cta"><h2>Before you pay</h2><p>' + (E (Fill (Pick $CTA $sd 16) $c)) + '</p><a class="btn" href="' + $TG + '">Open Telegram</a><a class="btn alt" href="/how-to-buy">Read the full method</a></div>'
  $h += SiblingGrid $doc $ctry
  $h += CountryGrid $doc $sd
  $h += Revision 'Authority, price band and local checks reviewed.'
  $title = 'Buy a ' + $dt + ' on Telegram: Price & Checks'
  $desc = Norm-D ('What a ' + $ctry.Adj + ' ' + (DocSing $doc $ctry) + ' costs on Telegram, which office issues it, and the ' + $ctry.Adj + ' checks that catch bad stock. Observed band ' + $price + ' ' + $ctry.Cur + '.')
  $jl = CrumbJson @(@{H='Home';U='/'}, @{H='Countries';U='/countries'}, @{H=$ctry.Adj;U='/countries/' + $ctry.Code}, @{H=($ctry.Adj + ' ' + $dt);U=$url})
  $art = '{"@context":"https://schema.org","@type":"Article","headline":"' + (E $title) + '","description":"' + (E $desc) + '","url":"' + $SITE + $url + '","dateModified":"' + $TODAY + '","author":{"@type":"Organization","name":"' + $BRAND + '"},"publisher":{"@type":"Organization","name":"' + $BRAND + '"},"isPartOf":{"@type":"WebSite","url":"' + $SITE + '/"}}'
  $json = '[' + $jl + ',' + $art + ',' + $fb.Json + ']'
  $body = '<nav class="crumbs" aria-label="Breadcrumb"><ol><li><a href="/">Home</a></li><li><a href="/countries">Countries</a></li><li><a href="/countries/' + $ctry.Code + '">' + (E $ctry.Adj) + '</a></li><li aria-current="page">' + (E ($ctry.Adj + ' ' + $dt)) + '</li></ol></nav>' + $h
  Emit @{ Url = $url; Title = $title; Desc = $desc; Body = $body; Json = $json; Tier = 'T3'; Target = $q }
}

function BuildT3B($doc, $ctry) {
  $q = 'buy ' + $ctry.Adj.ToLower() + ' dl on telegram'
  $auth = GetAuth $doc $ctry
  $price = GetPrice $doc $ctry
  $name = GetName $doc $ctry
  $c = Ctx $doc $ctry $auth $price $ctry.Cur $name $q
  $sd = Seed ('dl-' + $ctry.Code)
  $url = '/buy/' + $ctry.Code + '-dl-on-telegram'
  $dt = DocTitle $doc $ctry
  $h = ''
  $h += '<p class="part">Part of <a href="/countries/' + $ctry.Code + '">' + (E $ctry.Adj) + ' documents</a>.</p>'
  $h += '<h1>Buy a ' + (E $ctry.Adj) + ' DL on Telegram</h1>'
  $h += '<p class="lede">' + (E (Fill (Pick $LEDE $sd 1) $c)) + '</p>'
  $h += FactBox $c $doc
  $h += '<h2>' + (E $q) + ' &ndash; what the abbreviation means</h2>'
  $h += '<p>DL is the shorthand for a ' + (E (DocSing $doc $ctry)) + '. In ' + (E $ctry.Name) + ' the local name is ' + (E $name) + ' and the issuing office is ' + (E $auth) + '. Sellers use the abbreviation in adverts to save space and it hides which document tier is on offer.</p>'
  $h += '<p>' + (E (Fill (Pick $SQ1 $sd 2) $c)) + '</p>'
  $h += '<h2>Buy a ' + (E $dt) + ' via Telegram</h2>'
  $h += '<p>' + (E (Fill (Pick $VIA1 $sd 4) $c)) + '</p>'
  $h += '<p>' + (E (Fill (Pick $VIA2 $sd 5) $c)) + '</p>'
  $h += PriceTable $doc $doc.T1 $doc.T2 $doc.T3 $ctry.Cur
  $h += '<p class="note">' + (E (Fill (Pick $NOTE $sd 12) $c)) + '</p>'
  $h += '<h2>Checks before you pay</h2><ul class="checks">'
  $h += '<li>' + (E $ctry.Check1) + '</li><li>' + (E $ctry.Check2) + '</li>'
  foreach ($s in $GCHK) { $h += '<li>' + (E (Fill $s $c)) + '</li>' }
  $h += '</ul>'
  $h += '<h2>Red flags</h2><ul class="flags"><li>' + (E $ctry.Flag) + '</li>'
  foreach ($s in $GFLG) { $h += '<li>' + (E $s) + '</li>' }
  $h += '</ul>'
  $h += Pills $c $doc
  $fb = FaqBlock $doc $c
  $h += $fb.Html
  $h += '<div class="cta"><h2>Next step</h2><p>' + (E (Fill (Pick $CTA $sd 16) $c)) + '</p><a class="btn" href="' + $TG + '">Open Telegram</a><a class="btn alt" href="/buy/' + $ctry.Code + '-driver-license-on-telegram">Full ' + (E $dt) + ' guide</a></div>'
  $h += SiblingGrid $doc $ctry
  $h += Revision 'Abbreviation page, condensed from the full guide.'
  $title = 'Buy a ' + $ctry.Adj + ' DL on Telegram: Price & Checks'
  $desc = Norm-D ('DL means ' + (DocSing $doc $ctry) + '. What the ' + $ctry.Adj + ' card costs on Telegram, who issues it and the checks that expose a print.')
  $jl = CrumbJson @(@{H='Home';U='/'}, @{H='Countries';U='/countries'}, @{H=$ctry.Adj;U='/countries/' + $ctry.Code}, @{H=($ctry.Adj + ' DL');U=$url})
  $art = '{"@context":"https://schema.org","@type":"Article","headline":"' + (E $title) + '","description":"' + (E $desc) + '","url":"' + $SITE + $url + '","dateModified":"' + $TODAY + '","author":{"@type":"Organization","name":"' + $BRAND + '"},"isPartOf":{"@type":"WebSite","url":"' + $SITE + '/"}}'
  $json = '[' + $jl + ',' + $art + ',' + $fb.Json + ']'
  $body = '<nav class="crumbs" aria-label="Breadcrumb"><ol><li><a href="/">Home</a></li><li><a href="/countries">Countries</a></li><li><a href="/countries/' + $ctry.Code + '">' + (E $ctry.Adj) + '</a></li><li aria-current="page">' + (E ($ctry.Adj + ' DL')) + '</li></ol></nav>' + $h
  Emit @{ Url = $url; Title = $title; Desc = $desc; Body = $body; Json = $json; Tier = 'T3B'; Target = $q }
}

function BuildT1($doc, [bool]$via) {
  if ($via) { $slug = $doc.Code + '-via-telegram' } else { $slug = $doc.Code + '-on-telegram' }
  $url = '/buy/' + $slug
  if ($via) { $q = 'buy ' + $doc.Sing + ' via telegram' } else { $q = 'buy ' + $doc.Sing + ' on telegram' }
  if ($via) { $alt = 'buy ' + $doc.Sing + ' on telegram' } else { $alt = 'buy ' + $doc.Sing + ' via telegram' }
  if ($via) { $altUrl = '/buy/' + $doc.Code + '-on-telegram' } else { $altUrl = '/buy/' + $doc.Code + '-via-telegram' }
  $c = Ctx $doc $null 'the national issuing authority' $doc.T2 'USD' 'the local name of the document' $q
  $sd = Seed $slug
  if ($via) { $h1 = 'Buy a ' + $doc.Title + ' via Telegram' } else { $h1 = 'Buy a ' + $doc.Title + ' on Telegram' }
  $h = ''
  $h += '<h1>' + (E $h1) + '</h1>'
  $h += '<p class="lede">' + (E (Fill (Pick $LEDE $sd 1) $c)) + '</p>'
  $h += '<div class="facts"><dl>'
  $h += '<dt>Issuing authority</dt><dd>Varies by country, always a government office. Named on every country page.</dd>'
  $h += '<dt>Observed price band</dt><dd>' + (D $doc.T1) + ' to ' + (D $doc.T3) + ' USD</dd>'
  $h += '<dt>Typical delivery</dt><dd>3 to 28 days, tracked</dd>'
  $h += '<dt>What it proves</dt><dd>' + (E $doc.Def) + '</dd></dl></div>'
  $h += '<h2>' + (E $q) + ' &ndash; the short version</h2>'
  $h += '<p>' + (E (Fill (Pick $SQ1 $sd 2) $c)) + '</p>'
  $h += '<p>' + (E (Fill (Pick $SQ2 $sd 3) $c)) + '</p>'
  $h += '<p>' + (E (Fill (Pick $SQ1 $sd 21) $c)) + '</p>'
  $h += '<h2>' + (E $alt) + ': how it works in practice</h2>'
  $h += '<p>' + (E (Fill (Pick $VIA1 $sd 4) $c)) + '</p>'
  $h += '<p>' + (E (Fill (Pick $VIA2 $sd 5) $c)) + '</p>'
  $h += '<p>' + (E (Fill (Pick $VIA1 $sd 22) $c)) + '</p>'
  $h += '<h2>What you should actually receive</h2><p>A complete ' + (E $doc.Sing) + ' is a set of things, not a single image. Insist on all five before any money moves.</p><ul class="checks">'
  foreach ($s in $doc.Receive) { $h += '<li>' + (E (Fill $s $c)) + '</li>' }
  $h += '</ul>'
  $h += '<h2>Who actually issues a ' + (E $doc.Sing) + '</h2>'
  $h += '<p>' + (E (Fill (Pick $WHO1 $sd 6) $c)) + '</p>'
  $h += '<p>' + (E (Fill (Pick $WHO2 $sd 7) $c)) + '</p>'
  $h += '<h2>Replica or registered original</h2>'
  $h += '<p>' + (E (Fill (Pick $REV1 $sd 8) $c)) + '</p>'
  $h += '<p>' + (E (Fill (Pick $REV2 $sd 9) $c)) + '</p>'
  $h += '<h2>What a fair price looks like</h2>'
  $h += '<p>' + (E (Fill (Pick $PRICE1 $sd 10) $c)) + '</p>'
  $h += '<p>' + (E (Fill (Pick $PRICE2 $sd 11) $c)) + '</p>'
  $h += PriceTable $doc $doc.T1 $doc.T2 $doc.T3 'USD'
  $h += '<p class="note">' + (E (Fill (Pick $NOTE $sd 12) $c)) + '</p>'
  $h += '<h2>The buying process, step by step</h2><p>' + (E (Fill (Pick $STEPINTRO $sd 13) $c)) + '</p><ol class="steps">'
  foreach ($s in $STEPS) { $h += '<li>' + (E (Fill $s $c)) + '</li>' }
  $h += '</ol>'
  $h += '<h2>Checks that catch bad stock</h2><p>' + (E (Fill (Pick $CHKINTRO $sd 14) $c)) + '</p><ul class="checks">'
  foreach ($s in $doc.Checks) { $h += '<li>' + (E (Fill $s $c)) + '</li>' }
  foreach ($s in $GCHK) { $h += '<li>' + (E (Fill $s $c)) + '</li>' }
  $h += '</ul>'
  $h += '<h2>Red flags that should end the conversation</h2><p>' + (E (Fill (Pick $FLGINTRO $sd 15) $c)) + '</p><ul class="flags">'
  foreach ($s in $doc.Flags) { $h += '<li>' + (E (Fill $s $c)) + '</li>' }
  foreach ($s in $GFLG) { $h += '<li>' + (E $s) + '</li>' }
  $h += '</ul>'
  $h += Pills $c $doc
  $fb = FaqBlock $doc $c
  $h += $fb.Html
  $h += '<div class="cta"><h2>Before you pay</h2><p>' + (E (Fill (Pick $CTA $sd 16) $c)) + '</p><a class="btn" href="' + $TG + '">Open Telegram</a><a class="btn alt" href="' + $altUrl + '">Read the alternate version</a></div>'
  $h += '<h2>Other documents</h2><div class="grid">'
  foreach ($o in $DOCS) { if ($o.Code -eq $doc.Code) { continue }; $h += '<a class="card" href="/buy/' + $o.Code + '-on-telegram"><h3>Buy a ' + (E $o.Title) + ' on Telegram</h3><p>' + (E ($o.Def.Substring(0, [Math]::Min(90, $o.Def.Length)))) + '...</p></a>' }
  $h += '</div>'
  $h += CountryGrid $doc $sd
  $h += Revision 'Global guide, reviewed across all 30 countries.'
  if ($via) { $title = 'Buy a ' + $doc.Title + ' via Telegram: Price Bands and Checks' } else { $title = 'Buy a ' + $doc.Title + ' on Telegram: Price Bands and Checks' }
  $desc = Norm-D ('What a ' + $doc.Sing + ' costs on Telegram, who issues it in each country, and the checks that expose a print. Observed band ' + $doc.T1 + ' to ' + $doc.T3 + ' USD.')
  $jl = CrumbJson @(@{H='Home';U='/'}, @{H=$doc.Title;U=$url})
  $art = '{"@context":"https://schema.org","@type":"Article","headline":"' + (E $title) + '","description":"' + (E $desc) + '","url":"' + $SITE + $url + '","dateModified":"' + $TODAY + '","author":{"@type":"Organization","name":"' + $BRAND + '"},"publisher":{"@type":"Organization","name":"' + $BRAND + '"},"isPartOf":{"@type":"WebSite","url":"' + $SITE + '/"}}'
  $json = '[' + $jl + ',' + $art + ',' + $fb.Json + ']'
  $body = '<nav class="crumbs" aria-label="Breadcrumb"><ol><li><a href="/">Home</a></li><li aria-current="page">' + (E $doc.Title) + '</li></ol></nav>' + $h
  Emit @{ Url = $url; Title = $title; Desc = $desc; Body = $body; Json = $json; Tier = 'T1'; Target = $q }
}

function BuildT2($ctry) {
  $q = 'buy ' + $ctry.Adj.ToLower() + ' documents on telegram'
  $c = Ctx (DocBy 'passport') $ctry 'the relevant issuing office' $ctry.PPass $ctry.Cur 'the local document names' $q
  $c.PID = $ctry.PId
  $c.PGREEN = $ctry.PGreen
  $sd = Seed ('docs-' + $ctry.Code)
  $url = '/buy/' + $ctry.Code + '-documents-on-telegram'
  $h = ''
  $h += '<p class="part">Part of the <a href="/countries">country index</a>.</p>'
  $h += '<h1>Buy ' + (E $ctry.Adj) + ' Documents on Telegram</h1>'
  $h += '<p class="lede">' + (E (Fill (Pick $T2LEDE $sd 1) $c)) + '</p>'
  $h += '<div class="facts"><dl><dt>Documents covered</dt><dd>Passport, ' + (E (DocSing (DocBy 'driver-license') $ctry)) + ', ID card, green card, visa, residence permit</dd>'
  $h += '<dt>Passport authority</dt><dd>' + (E $ctry.APass) + '</dd>'
  $h += '<dt>Observed passport band</dt><dd>' + (D $ctry.PPass) + ' ' + (E $ctry.Cur) + '</dd>'
  $h += '<dt>Delivery</dt><dd>3 to 21 days, tracked</dd></dl></div>'
  $h += '<h2>' + (E $q) + ' &ndash; start here</h2>'
  $h += '<p>' + (E (Fill (Pick $T2P1 $sd 2) $c)) + '</p>'
  $h += '<p>' + (E (Fill (Pick $T2P2 $sd 3) $c)) + '</p>'
  $h += '<h2>Buy ' + (E $ctry.Adj) + ' documents via Telegram: the six documents</h2>'
  $h += '<table><caption>Issuing office and observed band by document. Ranges, not quotes.</caption><thead><tr><th>Document</th><th>Issuing office</th><th>Observed</th></tr></thead><tbody>'
  foreach ($o in $DOCS) {
    $t = DocTitle $o $ctry
    $h += '<tr><td><a href="/buy/' + $ctry.Code + '-' + $o.Code + '-on-telegram">' + (E $t) + '</a></td><td>' + (E (GetAuth $o $ctry)) + '</td><td>' + (D (GetPrice $o $ctry)) + ' ' + (E $ctry.Cur) + '</td></tr>'
  }
  $h += '</tbody></table>'
  $h += '<p>' + (E (Fill (Pick $T2P3 $sd 4) $c)) + '</p>'
  $h += '<p>' + (E (Fill (Pick $T2P1 $sd 7) $c)) + '</p>'
  $h += '<p>' + (E (Fill (Pick $T2P2 $sd 8) $c)) + '</p>'
  $h += '<h2>Price bands in ' + (E $ctry.Name) + '</h2><p>Every band below is an observed range from public adverts. The low figure is a print, the high figure should come with a register check.</p>'
  $h += PriceTable (DocBy 'passport') $ctry.PPass $ctry.PGreen $ctry.PPass $ctry.Cur
  $h += '<p class="note">' + (E (Fill (Pick $NOTE $sd 5) $c)) + '</p>'
  $h += '<h2>What to check in ' + (E $ctry.Name) + '</h2><p>Two local checks and the generic tells, whichever document you are buying.</p><ul class="checks">'
  $h += '<li>' + (E $ctry.Check1) + '</li><li>' + (E $ctry.Check2) + '</li>'
  foreach ($s in $GCHK) { $h += '<li>' + (E (Fill $s $c)) + '</li>' }
  $h += '</ul>'
  $h += '<h2>Red flags</h2><ul class="flags"><li>' + (E $ctry.Flag) + '</li>'
  foreach ($s in $GFLG) { $h += '<li>' + (E $s) + '</li>' }
  $h += '</ul>'
  $h += Pills $c (DocBy 'passport')
  $fb = FaqBlock (DocBy 'passport') $c
  $h += $fb.Html
  $h += '<div class="cta"><h2>Choose a document</h2><p>' + (E (Fill (Pick $T2CLOSE $sd 6) $c)) + '</p><a class="btn" href="/buy/' + $ctry.Code + '-passport-on-telegram">Start with the passport</a><a class="btn alt" href="/countries/' + $ctry.Code + '">' + (E $ctry.Adj) + ' hub</a></div>'
  $h += '<h2>All documents from ' + (E $ctry.Adj) + '</h2><div class="grid">'
  foreach ($o in $DOCS) { $t = DocTitle $o $ctry; $h += '<a class="card" href="/buy/' + $ctry.Code + '-' + $o.Code + '-on-telegram"><h3>Buy a ' + (E $t) + ' on Telegram</h3><p>' + (E (GetAuth $o $ctry)) + '</p></a>' }
  $h += '</div>'
  $h += '<h2>Other countries</h2><div class="grid">'
  $n = 0
  for ($i = 0; $i -lt $CTRY.Count -and $n -lt 8; $i++) { $o = $CTRY[($sd + $i) % $CTRY.Count]; if ($o.Code -eq $ctry.Code) { continue }; $h += '<a class="card" href="/buy/' + $o.Code + '-documents-on-telegram"><h3>' + (E $o.Adj) + ' documents</h3><p>Six documents, six offices</p></a>'; $n++ }
  $h += '</div>'
  $h += Revision 'Country overview reviewed.'
  $title = 'Buy ' + $ctry.Adj + ' Documents on Telegram: Authorities and Prices'
  $desc = Norm-D ('Passport, licence, ID card, visa and residence permit in ' + $ctry.Name + ': issuing offices, observed price bands and the checks that catch a print.')
  $jl = CrumbJson @(@{H='Home';U='/'}, @{H='Countries';U='/countries'}, @{H=$ctry.Adj;U='/countries/' + $ctry.Code}, @{H=($ctry.Adj + ' documents');U=$url})
  $art = '{"@context":"https://schema.org","@type":"Article","headline":"' + (E $title) + '","description":"' + (E $desc) + '","url":"' + $SITE + $url + '","dateModified":"' + $TODAY + '","author":{"@type":"Organization","name":"' + $BRAND + '"},"isPartOf":{"@type":"WebSite","url":"' + $SITE + '/"}}'
  $json = '[' + $jl + ',' + $art + ',' + $fb.Json + ']'
  $body = '<nav class="crumbs" aria-label="Breadcrumb"><ol><li><a href="/">Home</a></li><li><a href="/countries">Countries</a></li><li><a href="/countries/' + $ctry.Code + '">' + (E $ctry.Adj) + '</a></li><li aria-current="page">' + (E ($ctry.Adj + ' documents')) + '</li></ol></nav>' + $h
  Emit @{ Url = $url; Title = $title; Desc = $desc; Body = $body; Json = $json; Tier = 'T2'; Target = $q }
}

function BuildHub($ctry) {
  $url = '/countries/' + $ctry.Code
  $sd = Seed ('hub-' + $ctry.Code)
  $h = ''
  $h += '<p class="part">Part of the <a href="/countries">country index</a>.</p>'
  $h += '<h1>' + (E $ctry.Adj) + ' Documents: Authorities and Price Bands</h1>'
  $h += '<p class="lede">Every document in ' + (E $ctry.Name) + ' comes from a different office. This hub lists all six with the office that issues it and the observed band, so you can pick the right page before you open a chat.</p>'
  $h += '<p>Price bands differ by document by an order of magnitude and the checks differ completely. Read the office column before the price column, because the office tells you what the document is and the price only tells you what a seller hopes to get for it.</p>'
  $h += '<h2>' + (E $ctry.Adj) + ' documents: the six offices</h2>'
  $h += '<table><caption>Issuing office by document.</caption><thead><tr><th>Document</th><th>Office</th><th>Observed</th></tr></thead><tbody>'
  foreach ($o in $DOCS) { $t = DocTitle $o $ctry; $h += '<tr><td><a href="/buy/' + $ctry.Code + '-' + $o.Code + '-on-telegram">' + (E $t) + '</a></td><td>' + (E (GetAuth $o $ctry)) + '</td><td>' + (D (GetPrice $o $ctry)) + ' ' + (E $ctry.Cur) + '</td></tr>' }
  $h += '</tbody></table>'
  $h += '<h2>Two checks specific to ' + (E $ctry.Name) + '</h2><ul class="checks"><li>' + (E $ctry.Check1) + '</li><li>' + (E $ctry.Check2) + '</li></ul>'
  $h += '<h2>Local red flag</h2><ul class="flags"><li>' + (E $ctry.Flag) + '</li></ul>'
  $h += '<div class="cta"><h2>Overview</h2><p>All six documents side by side, with the price spread and the generic checks.</p><a class="btn" href="/buy/' + $ctry.Code + '-documents-on-telegram">' + (E $ctry.Adj) + ' document overview</a></div>'
  $h += '<h2>All documents</h2><div class="grid">'
  foreach ($o in $DOCS) { $t = DocTitle $o $ctry; $h += '<a class="card" href="/buy/' + $ctry.Code + '-' + $o.Code + '-on-telegram"><h3>' + (E $t) + '</h3><p>' + (E (GetAuth $o $ctry)) + '</p></a>' }
  $h += '</div>'
  $h += '<h2>Other countries</h2><div class="grid">'
  $n = 0
  for ($i = 0; $i -lt $CTRY.Count -and $n -lt 8; $i++) { $o = $CTRY[($sd + $i) % $CTRY.Count]; if ($o.Code -eq $ctry.Code) { continue }; $h += '<a class="card" href="/countries/' + $o.Code + '"><h3>' + (E $o.Adj) + '</h3><p>Authorities and bands</p></a>'; $n++ }
  $h += '</div>'
  $h += Revision 'Hub reviewed.'
  $title = $ctry.Adj + ' Documents: Authorities and Price Bands'
  $desc = Norm-D ('All six documents in ' + $ctry.Name + ' with the issuing office and the observed band for each. Two local checks and one local red flag.')
  $jl = CrumbJson @(@{H='Home';U='/'}, @{H='Countries';U='/countries'}, @{H=$ctry.Adj;U=$url})
  $json = '[' + $jl + ',{"@context":"https://schema.org","@type":"CollectionPage","name":"' + (E $title) + '","url":"' + $SITE + $url + '","isPartOf":{"@type":"WebSite","url":"' + $SITE + '/"}}]'
  $body = '<nav class="crumbs" aria-label="Breadcrumb"><ol><li><a href="/">Home</a></li><li><a href="/countries">Countries</a></li><li aria-current="page">' + (E $ctry.Adj) + '</li></ol></nav>' + $h
  Emit @{ Url = $url; Title = $title; Desc = $desc; Body = $body; Json = $json; Tier = 'HUB'; Target = ($ctry.Adj.ToLower() + ' documents') }
}