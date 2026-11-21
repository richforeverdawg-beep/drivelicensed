
function Simple($url, $title, $desc, $h1, $html, $tier) {
  $jl = CrumbJson @(@{H='Home';U='/'}, @{H=$title;U=$url})
  $json = '[' + $jl + ']'
  $body = '<nav class="crumbs" aria-label="Breadcrumb"><ol><li><a href="/">Home</a></li><li aria-current="page">' + (E $title) + '</li></ol></nav><h1>' + (E $h1) + '</h1>' + $html
  Emit @{ Url = $url; Title = $title; Desc = (Norm-D $desc); Body = $body; Json = $json; Tier = $tier; Target = '' }
}

function BuildSupport() {
  $tg = '<div class="cta"><h2>Contact</h2><p>Corrections and price-band updates are welcome by email. Telegram handle is added shortly.</p><a class="btn" href="mailto:' + $MAIL + '">' + $MAIL + '</a></div>'

  $h = '<p class="lede">An independent reference for documents sold on Telegram. Not a seller, no affiliate padding, no stock list. Just the authority behind each document, the band a fair price sits in, and the checks that catch a print.</p>'
  $h += '<h2>What this site does</h2><p>Every page names the office that actually issues the document, gives an observed price band from public adverts, and lists the checks in the order a buyer should run them. Where a country has a number rule, the page gives the rule.</p>'
  $h += '<h2>How to use it</h2><p>Start from the document, then pick the country. The <a href="/how-to-buy">method page</a> is the sequence to follow. The <a href="/faq">FAQ</a> covers the recurring questions.</p>'
  $h += '<h2>Start here</h2><div class="grid">'
  foreach ($o in $DOCS) { $h += '<a class="card" href="/buy/' + $o.Code + '-on-telegram"><h3>Buy a ' + (E $o.Title) + ' on Telegram</h3><p>' + (E $o.Def.Substring(0, [Math]::Min(90, $o.Def.Length))) + '...</p></a>' }
  $h += '</div>'
  $h += '<h2>Countries</h2><ul class="hub">'
  foreach ($o in $CTRY) { $h += '<li><a href="/countries/' + $o.Code + '">' + (E $o.Adj) + '</a></li>' }
  $h += '</ul>'
  $h += $tg
  $homeBody = '<nav class="crumbs" aria-label="Breadcrumb"><ol><li aria-current="page">Home</li></ol></nav><h1>Buy Documents on Telegram</h1>' + $h
  $json = '[{"@context":"https://schema.org","@type":"WebSite","name":"' + $BRAND + '","url":"' + $SITE + '/","inLanguage":"en"},{"@context":"https://schema.org","@type":"Organization","name":"' + $BRAND + '","url":"' + $SITE + '/","email":"' + $MAIL + '"}]'
  Emit @{ Url = '/'; Title = 'Buy Documents on Telegram: Prices, Authorities, Checks'; Desc = (Norm-D 'Independent guide to buying passports, licences, ID cards, visas and residence permits on Telegram. Observed prices, issuing offices and the checks that catch prints.'); Body = $homeBody; Json = $json; Tier = 'HOME'; Target = '' }

  $h = '<p class="lede">Thirty countries, six documents, the office behind each one and the band a fair price sits in. No African states, no padding.</p>'
  $h += '<h2>By document</h2><ul class="hub">'
  foreach ($o in $DOCS) { $h += '<li><a href="/buy/' + $o.Code + '-on-telegram">' + (E $o.Title) + '</a></li>' }
  $h += '</ul><h2>By country</h2><ul class="hub">'
  foreach ($o in $CTRY) { $h += '<li><a href="/countries/' + $o.Code + '">' + (E $o.Adj) + '</a></li>' }
  $h += '</ul>'
  Simple '/countries' 'Countries Covered: 30 Document Markets' 'Thirty countries covered, each with issuing offices, observed price bands and local checks for six document types.' 'Countries' $h 'COL'

  $h = '<p class="lede">The order matters more than any single step. Run it in sequence and stop at the first failure.</p>'
  $h += '<h2>The sequence</h2><ol class="steps">'
  foreach ($s in $STEPS) { $h += '<li>' + (E ($s.Replace('{AUTH}', 'the issuing office').Replace('{PRICE}', 'the observed band').Replace('{CUR}', 'local currency'))) + '</li>' }
  $h += '</ol>'
  $h += '<h2>Why the order is fixed</h2><p>Each step is a small payment of trust the seller has to earn before the next. Photos before payment, number before balance, tracking before the second half. Reversing any two of those moves risk onto you.</p>'
  $h += '<h2>Payment</h2><p>Split it. A third up, two thirds against a tracking number that actually moves. Crypto is fine at that split, never for the whole amount.</p>'
  $h += '<h2>On arrival</h2><p>Photograph the unopened envelope, then the document beside it. Check against the photos before you accept. If the document is wrong, the envelope ties it to the seller.</p>'
  $h += '<h2>The generic checks</h2><ul class="checks">'
  foreach ($s in $GCHK) { $h += '<li>' + (E ($s.Replace('{AUTH}', 'the issuing office'))) + '</li>' }
  $h += '</ul><h2>The generic red flags</h2><ul class="flags">'
  foreach ($s in $GFLG) { $h += '<li>' + (E $s) + '</li>' }
  $h += '</ul>'
  $h += $tg
  Simple '/how-to-buy' 'How to Buy Documents on Telegram: Full Method' 'The six-step buying sequence, the payment split that protects you, and the generic checks and red flags in one place.' 'How to Buy on Telegram' $h 'PAGE'

  $h = '<p class="lede">The questions that come up on every page, answered once.</p>'
  $qs = @(
    @('Is anything sold on Telegram genuine?','Rarely in the strict sense. Most of the market is replica or registered original. The genuine article is expensive and usually needs your details.'),
    @('What is the difference between replica and registered original?','A replica is a print. A registered original carries a number in an issuing office record that resolves when checked. They are priced about five times apart.'),
    @('How much should I pay?','Between the observed band on the page for your country and document. The bottom buys a print, the top should come with a register check.'),
    @('How do I know the price is fair?','Compare against the band. Anything far below is a print described as original. Anything far above needs a register check and tracked delivery to justify it.'),
    @('Do prices include delivery?','Not always. Ask. Tracked delivery costs the seller money and a quote that excludes it is not comparable.'),
    @('Can a number be checked?','In some countries yes, publicly. In others only the holder can. Ask which route exists and expect a specific answer.'),
    @('What is the fastest test?','The number format. It is free, takes a minute, and a number that breaks the rule cannot be argued with.'),
    @('Should I use a UV torch?','Yes. A 365 nanometre torch is under ten pounds and exposes every print. Ask for a live call with the torch in frame.'),
    @('What if the seller refuses checks?','They either lack the equipment or do not want the result. Hold the balance back.'),
    @('How long should delivery take?','A tracking number that moves inside 48 hours is the realistic standard. Same day means a file, not a card.'),
    @('What deposit is normal?','A third. Below a fifth the seller is exposed, above a half you are.'),
    @('Is real escrow available?','Rarely. Only worth it with a published fee schedule and a verifiable operator. A second Telegram account is not escrow.'),
    @('What if the parcel never arrives?','Send a dated summary in the chat, name the amount, keep the thread. Then report the account.'),
    @('Do you sell documents?','No. This is a guide. Prices are observed ranges from public adverts and are not quotes.'),
    @('Why these thirty countries?','They carry the bulk of English-language search demand and the clearest published number rules. African markets are excluded to keep the set testable.')
  )
  $faqJson = @()
  foreach ($pair in $qs) { $h += '<details class="faq"><summary>' + (E $pair[0]) + '</summary><div><p>' + (E $pair[1]) + '</p></div></details>'; $faqJson += '{"@type":"Question","name":"' + (E $pair[0]) + '","acceptedAnswer":{"@type":"Answer","text":"' + (E $pair[1]) + '"}}' }
  $h += $tg
  $jl = CrumbJson @(@{H='Home';U='/'}, @{H='FAQ';U='/faq'})
  $json = '[' + $jl + ',{"@context":"https://schema.org","@type":"FAQPage","mainEntity":[' + ($faqJson -join ',') + ']}]'
  $body = '<nav class="crumbs" aria-label="Breadcrumb"><ol><li><a href="/">Home</a></li><li aria-current="page">FAQ</li></ol></nav><h1>Frequently Asked Questions</h1>' + $h
  Emit @{ Url = '/faq'; Title = 'Document Buying on Telegram: 15 Straight Answers'; Desc = (Norm-D 'Fifteen answers on Telegram document buying: replica versus original, fair prices, deposits, tracking, UV checks and what to do when a parcel fails.'); Body = $body; Json = $json; Tier = 'PAGE'; Target = '' }

  $h = '<p class="lede">A reference site about documents sold on Telegram, built by a buyer rather than a seller.</p>'
  $h += '<h2>Editorial position</h2><p>No document on this site is described as genuine. Every page states the replica versus registered original distinction, because that distinction is the whole market. Prices are observed ranges from public adverts and are labelled as such.</p>'
  $h += '<h2>What is not here</h2><p>No stock list, no affiliate links, no seller ranking, no legal advice. Where the law matters, the page says so and stops.</p>'
  $h += '<h2>Method</h2><p>Each page is generated from one data file: the issuing office per document per country, an observed price band in local currency, two local checks and one local red flag. The generic checks come from the document type. Nothing is invented per page.</p>'
  $h += '<h2>Corrections</h2><p>Authorities reorganise and price bands drift. Corrections by email are welcome and are applied at the next build.</p>'
  $h += $tg
  Simple '/about' 'About DriveLicensed: Independent Document Reference' 'An independent reference for documents sold on Telegram. No seller affiliation, no stock list, no affiliate padding.' 'About' $h 'PAGE'

  $h = '<p class="lede">Email is the reliable route. Telegram is added shortly.</p>'
  $h += '<h2>Email</h2><p><a href="mailto:' + $MAIL + '">' + $MAIL + '</a> for corrections, price updates and questions.</p>'
  $h += '<h2>What to include</h2><p>For a correction, the page URL and the correct figure. For a price update, the country, the document and the observed band with a date.</p>'
  $h += '<h2>Response</h2><p>Usually within a few days. No seller enquiries please, only buyer questions and corrections.</p>'
  $h += $tg
  Simple '/contact' 'Contact DriveLicensed' 'Contact the site by email for corrections, price updates and buyer questions. No seller enquiries.' 'Contact' $h 'PAGE'

  $h = '<h2>What is collected</h2><p>No analytics, no cookies, no tracking scripts. The site is static HTML and one stylesheet. Server logs at the host record IP and user agent for security and are not joined to anything.</p>'
  $h += '<h2>Email</h2><p>If you email, your address and message are kept for as long as the thread is useful.</p>'
  $h += '<h2>Hosting</h2><p>Pages are served by a third party static host. Their own logging policy applies to requests.</p>'
  $h += '<h2>No affiliate tracking</h2><p>Outbound Telegram links carry no tracking parameters.</p>'
  Simple '/privacy' 'Privacy Policy: No Cookies, No Tracking' 'No analytics, no cookies, no tracking scripts. What the site does and does not collect, and how email is handled.' 'Privacy Policy' $h 'PAGE'

  $h = '<h2>No legal advice</h2><p>Nothing here is legal advice. Where a document is required by law, confirm with the issuing authority.</p>'
  $h += '<h2>No guarantee</h2><p>Prices are observed ranges, not quotes, and not offered by this site. No document is described as genuine.</p>'
  $h += '<h2>Accuracy</h2><p>Pages are revised on the date shown at the foot of each. Authorities reorganise and bands drift, so verify against the issuing office before relying on anything here.</p>'
  $h += '<h2>Liability</h2><p>No liability for loss arising from a purchase made with a third party.</p>'
  Simple '/terms' 'Terms of Use: Reference Only, No Legal Advice' 'The site offers general reference only. No legal advice, no price guarantee, no liability for third party purchases.' 'Terms of Use' $h 'PAGE'

  $h = '<h2>No affiliate links</h2><p>No outbound link on this site is monetised. There are no referral codes and no tracking parameters.</p>'
  $h += '<h2>No seller relationship</h2><p>The site is not a seller, an agent, or a reseller. No seller pays for placement and none is ranked.</p>'
  $h += '<h2>No stock list</h2><p>Stock changes hourly and a static list would be wrong by the time it published. The site covers what a fair price and a real document look like instead.</p>'
  $h += '<h2>How the site is funded</h2><p>Out of pocket. No advertising, no sponsorship.</p>'
  Simple '/disclosure' 'Disclosure: No Affiliates, No Seller Ties' 'No affiliate links, no seller relationship, no paid placement and no stock list. How the site is funded.' 'Disclosure' $h 'PAGE'

  $h = '<p class="lede">Every page on the site, in hierarchy order.</p>'
  $h += '<h2>Documents</h2><ul class="hub">'
  foreach ($o in $DOCS) { $h += '<li><a href="/buy/' + $o.Code + '-on-telegram">' + (E $o.Title) + ' on Telegram</a></li><li><a href="/buy/' + $o.Code + '-via-telegram">' + (E $o.Title) + ' via Telegram</a></li>' }
  $h += '</ul><h2>Countries</h2><ul class="hub">'
  foreach ($o in $CTRY) { $h += '<li><a href="/countries/' + $o.Code + '">' + (E $o.Adj) + '</a></li><li><a href="/buy/' + $o.Code + '-documents-on-telegram">' + (E $o.Adj) + ' documents</a></li>' }
  $h += '</ul><h2>Reference</h2><ul class="hub"><li><a href="/how-to-buy">How to buy</a></li><li><a href="/faq">FAQ</a></li><li><a href="/blog">Blog</a></li><li><a href="/about">About</a></li><li><a href="/contact">Contact</a></li><li><a href="/privacy">Privacy</a></li><li><a href="/terms">Terms</a></li><li><a href="/disclosure">Disclosure</a></li></ul>'
  Simple '/sitemap' 'HTML Sitemap: Every Page on DriveLicensed' 'Every page on the site in hierarchy order: documents, thirty country markets and the reference section.' 'Sitemap' $h 'PAGE'
}