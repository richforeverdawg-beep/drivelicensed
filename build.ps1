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
$t = $t.Replace('{PID}', $c.PID).Replace('{PGREEN}', $c.PGREEN)
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

$LEDE = @(
'Somebody is selling a {ADJ} {DOC} on Telegram right now and the advert almost certainly quotes a price below {PRICE} {CUR}. Whether that price is honest depends on what is in the envelope, not on how confident the seller sounds.',
'The {ADJ} {DOC} is issued by {AUTH}. Every real one carries marks from that office and a seller who cannot point to them is guessing. This page is a checklist for that conversation.',
'A {ADJ} {DOC} is not one product. It is a data page, a number, a feature set and a register entry, and sellers price each layer differently. {AUTH} issues the real thing.',
'Searching for a {ADJ} {DOC} on Telegram returns a hundred near-identical adverts and no way to rank them. The only reliable filter is knowing what {AUTH} puts on the document and what a print cannot reproduce.',
'Most people who buy a {ADJ} {DOC} through Telegram have never held one. That is the whole difficulty, because you cannot compare it to a memory. So the checks have to be written down in advance.',
'The advertised price for a {ADJ} {DOC} on Telegram usually sits between {PRICE} {CUR}. Anything far below that band is a print and anything far above it should come with a register check you can run yourself.',
'There is no single market price for a {ADJ} {DOC}. There are three, for a print, for correct stock, and for a number that resolves at {AUTH}. Adverts blur all three into one figure.',
'A {ADJ} {DOC} sold on Telegram is either a replica, a registered original, or a genuine document with your details typed in. Those three are priced differently and fail differently, and the advert rarely says which.'
)
$SQ1 = @(
'If you want the short version, a {ADJ} {DOC} bought through Telegram is only worth the money when three things line up. The stock has to match what {AUTH} uses, the number has to follow that office format, and the seller has to survive a question about a feature a photocopier cannot copy.',
'The band you should expect for a {ADJ} {DOC} is {PRICE} {CUR}. Below the bottom you are buying a print and should be told so. Above the top you should be getting a number that was registered rather than invented.',
'Nothing about Telegram makes a {ADJ} {DOC} more likely to be fake. It is a shop window with no returns policy, which is why the checks matter more here than they would at a counter.',
'A {ADJ} {DOC} is checked in five minutes by anybody who knows what {AUTH} prints. Ghost image, microprint, machine-readable zone, laminate edge, UV response. A seller with real stock will not mind you asking.',
'The price question and the quality question are the same question for a {ADJ} {DOC}. Cheap means the security layer was skipped, and the security layer is the only part that is hard to fake.',
'Sellers advertise {ADJ} {DOCS} at {PRICE} {CUR} and then call them original. Ask which register the number sits in. A registered {ADJ} {DOC} resolves at {AUTH} and a print resolves nowhere.',
'For a {ADJ} {DOC} the realistic expectation is {PRICE} {CUR} and one to three weeks of waiting. Same day delivery at the bottom of the band usually means a digital file rather than a card.',
'Before paying for a {ADJ} {DOC}, ask for a UV shot of the data page and a close crop of the number field. Both are cheap for the seller and both expose a print immediately.'
)
$SQ2 = @(
'That is the whole test in one line, and everything below is the detail behind it. The sections that follow break the document down feature by feature so you can run each check in order rather than guessing at the overall impression.',
'Work through the rest of this page with the card in front of you if you can. The numbered process later on is the sequence to follow and the checks list is what to look for at each step.',
'The figure above is a range rather than a quote, and it moves with stock and season. Hold it in your head as a filter, not as a target, and treat every deviation as a claim to be tested.',
'Everything here assumes the seller is a stranger and the money is not reversible. That is the normal condition on Telegram and it is why the process later on is staged rather than a single transfer.',
'None of these checks need equipment beyond a loupe and a UV torch. Both cost less than the deposit on a single document and both last for years of buying.',
'The next section covers how the transaction itself runs, because the ordering of photos, checks and payment is where most deals actually fail, not the document inspection.',
'If you only take one thing from this page, take the register question. It sorts sellers faster than any physical test because a reseller cannot answer it and a printer cannot fake it.',
'Read the price table before you open a chat, not after. Knowing the band stops you anchoring on whatever number the seller opens with.'
)
$VIA1 = @(
'The transaction runs in a private chat, usually after a public channel advert. That is fine. What matters is that the sequence is fixed before money moves: photos first, then a number check, then payment, then tracked delivery.',
'Most {ADJ} {DOC} sellers work through a channel that posts stock and a chat that closes the sale. The channel is marketing. The chat is where you find out whether the person knows the document.',
'Ask for the issue date and the issuing office before you ask the price. A seller working with {AUTH} stock answers instantly. A reseller has to go and look, and that pause tells you where you sit in the chain.',
'Payment is usually a transfer or a crypto address and neither is reversible. Split it: a deposit for the data page photo, the balance against a tracking number that moves.',
'Delivery is where most {ADJ} {DOC} deals go quiet. Insist on a tracking number inside forty eight hours and treat a seller who only offers a photo of an envelope as unproven.',
'A serious seller of {ADJ} {DOCS} will send an uncropped photo of the card on a plain surface with the laminate edge in frame. Screenshots and cropped data pages are where problems hide.',
'Treat the chat as a written record. Ask in full sentences, keep the answers, screenshot the price. If the deal sours you will want the thread rather than a summary of it.',
'A seller who handles {ADJ} {DOCS} well names {AUTH} without prompting. If the authority only appears after you mention it, the seller is repeating your words back at you.'
)
$VIA2 = @(
'That ordering is not bureaucratic. Each step is a small payment of trust that the seller has to earn before the next one, and it removes most of the loss from a failed deal.',
'Some sellers will push for the full amount up front. Offer the deposit and hold firm on the balance. Most accept and the ones who do not are usually reselling stock they do not have.',
'Keep the photos the seller sends. When the parcel arrives, photograph the unopened envelope before you open it, then the document beside the envelope. That sequence ties the document to the seller.',
'If the seller wants to move to another app for payment, that is normal, but keep the conversation on Telegram. The chat is the only record that survives a disappearing account.',
'A live video call is worth ten photos. Ask the seller to hold the card to a window in daylight and tilt it slowly. The ghost image and the laminate edge are both visible on a call and neither can be staged with a print.',
'Do not send the balance against a promise of a tracking number. Send it against the number itself, checked on the carrier site rather than on a screenshot.',
'When a seller is good, say so and keep them. A reliable contact in this market is worth more than a small saving, and repeat buyers get the better stock.',
'If the deal collapses after the deposit, write a dated summary in the chat, name the amount and stop. Sellers respond to a record far more than to complaint.'
)
$WHO1 = @(
'The issuing authority for a {ADJ} {DOC} is {AUTH}. Nobody on Telegram issues anything. Sellers are downstream of that office and the only question worth asking is how many steps downstream they are.',
'{AUTH} produces the {ADJ} {DOC}. Stock, number range and security features all come from one place, and a document that contradicts any of the three did not come from there.',
'It helps to know that {AUTH} does not sell to the public through Telegram. The chain always ends at that office and the register it keeps is the only authority that counts.',
'The {ADJ} {DOC} is a state product made by {AUTH}. Replicas copy the look, registered originals carry a number in the office records, and both are sold on Telegram as if they were the same thing.',
'In {CTRY} the office behind the {DOC} is {AUTH}. The local name is {NAME}. Use the local name in the chat and the seller immediately knows whether you have done any reading.',
'{AUTH} is the body to check against. If a seller cannot name the office that issued the document in the photo, the photo is probably borrowed from a stock gallery.',
'Every feature on a {ADJ} {DOC} exists because {AUTH} put it there: substrate, print method, UV ink, number format. Strip those out and what is left is a picture of a card.',
'The {ADJ} {DOC} sits under {AUTH} and that office number format is published widely enough to test. A number that breaks the format is the fastest single proof that something is wrong.'
)
$WHO2 = @(
'That is why the authority question comes before the price question. A seller who knows the office knows the stock, and a seller who knows the stock can tell you what the number should look like.',
'Local name matters more than it sounds. Using {NAME} rather than a translated term shows the seller you are not reading from a generic script, and the quality of the answers changes immediately.',
'The office also sets the expiry convention. Some issue five years, some ten, some tie it to the vehicle class or the permit purpose. A date that breaks the convention is a quiet but solid tell.',
'If the seller names a different office, that is not automatically wrong. {AUTH} may delegate. But the answer should be specific enough to be checkable, and vague regional answers are not.',
'Number formats are the one part of this that a buyer can always test without equipment. Look up the format for {CTRY} and compare digit by digit. It takes a minute and settles most arguments.',
'Register access varies. Some countries let you check a number online, some need the holder, some need a call. Ask the seller what route exists and expect a specific answer rather than a general one.',
'Where no public route exists, the physical checks carry all the weight. That is not ideal, but it is the honest position and any seller who claims otherwise is overselling.',
'Finally, remember the office never contacts you. Any message claiming to be from {AUTH} confirming your purchase is a second party, usually the seller, and worth exactly as much as their word.'
)
$PRICE1 = @(
'Observed adverts for a {ADJ} {DOC} cluster between {PRICE} {CUR}. That is the range to hold in your head, and it is deliberately wide because it covers three different products.',
'The bottom of the {PRICE} {CUR} band buys a data page print. The middle buys correct stock and the right print method. The top buys a number that resolves at {AUTH}. Ask which one is quoted.',
'Prices move with the document own difficulty. A card with a chip and a UV layer costs more to produce than a laminate print and the advert should reflect that.',
'You will see {ADJ} {DOCS} below {PRICE} {CUR} described as original. Sometimes they are. More often a print has been priced and given a word it has not earned.',
'Fair pricing on a {ADJ} {DOC} is not about the cheapest number in the chat. It is about paying the bottom of the band for a print and the top only when somebody shows a register hit.',
'The band for a {ADJ} {DOC} is {PRICE} {CUR}. Sellers quoting outside it usually have a reason and the reason is worth hearing before you decide they are wrong.',
'Treat {PRICE} {CUR} as the market for a {ADJ} {DOC} and every deviation as a claim to be tested. A high price is a promise of quality, so make the seller keep it.',
'Price is the easiest thing to compare and the least informative. Two adverts at the same figure can differ completely in stock, number and delivery, and the figure shows you none of it.'
)
$PRICE2 = @(
'The table below splits the band into the three tiers so you can see what each figure is actually for. Read it before you open a chat and you will not anchor on whatever number the seller opens with.',
'There is a floor below which the maths stops working for the seller. Below roughly the bottom third of the band, nobody is buying stock, so nobody is selling you stock.',
'Delivery is part of the price and worth separating. Tracked delivery costs the seller money, and a quote that excludes it is not comparable to one that includes it.',
'Replacement terms are the other hidden line. A seller who replaces a failed parcel prices higher and is usually worth the premium, but only after a track record long enough to make the promise mean something.',
'If a quote is far above the band, ask what the extra buys. A register check, a replacement guarantee and tracked delivery justify the top. Confidence alone does not.',
'If a quote is far below, ask what was left out. The answer is almost always the security layer or the stock, and either one turns the document into a print.',
'Negotiate on delivery and the register check rather than on print quality. The print is what it is at every price point, so arguing about it moves nothing.',
'The honest summary is that you get what the tier buys. Pay the print price for a print, the stock price for stock, and the top price only when somebody proves the number.'
)
$REV1 = @(
'Replica and registered original are used interchangeably in adverts and they are not the same purchase. A replica is a print. It copies the layout and fails on UV, on substrate and on the number.',
'A registered original is a document whose number sits in the office records. It may still be a genuine book with your details typed in, but the number resolves, and that is the whole difference in value.',
'The middle tier is stock. The seller has real blank or cancelled stock of the right type and prints onto it, so the physical layer is genuine and the number is invented. Most adverts at the middle of the band are this.',
'Ask the direct question in writing: does the number resolve at the office, yes or no. A seller who says yes and hedges is selling stock. A seller who says no and prices accordingly is honest.',
'Never accept the word original as a category. It is an adjective. The specification is the register, and a register either answers or it does not.',
'If the card only has to look right across a counter, a print is enough and the bottom of the band is fair. If a number has to be looked up, pay the top and make the seller prove the lookup first.'
)
$REV2 = @(
'This is the single most useful distinction on the page, because it explains the price spread better than anything else. A quote tells you which tier the seller thinks you are in.',
'The failure modes are different too. A print fails the first UV torch. Stock fails the number. A registered original fails only if the entry has lapsed or the details do not match it.',
'That is why the number should be requested before any payment. If a seller sends the number first and invites you to check it, you are talking to somebody confident about the register.',
'Some sellers will not send a number before a deposit. That is a reasonable position, but the deposit should be small and the number should follow immediately after it.',
'Where the country has no public register route, the tier question becomes harder to prove. In those cases, buy stock at the middle of the band and do not pay top-tier prices on an unprovable claim.',
'Whichever tier you buy, ask for it in writing. A one-line message saying the number does or does not resolve is worth more than any amount of reassurance in prose.'
)
$STEPINTRO = @(
'The sequence below is the one that keeps you protected. Run it in order and do not skip ahead to payment.',
'Work through these in order. Each step exists because it is where a bad {ADJ} {DOC} deal usually breaks.',
'Six steps, in this order. The order matters more than any single step.',
'Run this sequence once, properly, rather than half of it three times with three sellers.',
'The steps below are deliberately boring. Boring is what a {ADJ} {DOC} purchase should feel like.',
'Follow these in sequence and stop at the first one that fails.'
)
$CHKINTRO = @(
'These are the checks that separate a real {ADJ} {DOC} from a good print. All of them are cheap to run and two are local to {CTRY}.',
'Run these before money moves. Each one targets a feature that survives handling but not a photocopier.',
'The five checks below take minutes and catch almost everything. Two of them are specific to {CTRY}.',
'Every check here targets something a seller cannot fake without real stock or real equipment.',
'Do these in daylight, with the card in your hand, and never accept a photo as proof of any of them.',
'These are the tests that matter for a {ADJ} {DOC}. The two local ones are worth memorising.'
)
$FLGINTRO = @(
'Any one of these is enough to walk away. Two together is a pattern.',
'These end a {ADJ} {DOC} conversation for good.',
'If you see any of these, stop paying attention to the price.',
'Red flags specific to {CTRY}, plus the generic tells that apply anywhere.',
'None of these are fatal alone. All of them are fatal when the seller has no explanation.'
)
$CTA = @(
'Take the checks above into the chat. If a seller passes all of them, the {ADJ} {DOC} is worth the top of the band.',
'The band for a {ADJ} {DOC} in {CTRY} is {PRICE} {CUR}. Anything else needs a reason, so ask for it.',
'Print the checklist, run it in order and pay only at the end. That is the whole method for a {ADJ} {DOC}.',
'If you have a {ADJ} {DOC} in front of you and something feels off, compare it against the list above before you send anything.',
'Start with the authority and the number, then work outward. The contact page is open if you want a second pair of eyes.'
)
$NOTE = @(
'Prices are observed ranges from public Telegram adverts, not fixed tariffs. They move with stock and season and are not a quote.',
'The band above is what adverts ask, not what documents are worth. Treat it as a starting point for negotiation.',
'Observed ranges only. A seller quoting the top of the band owes you a register check.',
'Ranges are observed, not official. No seller is obliged to honour them.'
)
$T2LEDE = @(
'Sellers list {ADJ} documents on Telegram as a bundle: passport, licence, identity card, visa. The bundle is a marketing shape rather than a real one, because each document comes from a different office and fails in a different way.',
'Every {ADJ} document in this market has its own issuing office, its own number rule and its own price band. Grouping them is convenient for a seller and dangerous for a buyer, so this page keeps them separate.',
'If you are buying more than one {ADJ} document, the checks do not carry across. What catches a bad passport is not what catches a bad licence, and the offices behind them are not even in the same department.'
)
$T2P1 = @(
'The {ADJ} passport comes from {AUTH}. The licence comes from a different office entirely, and the identity card from a third. A seller who talks about all three in one breath is describing a shopping list, not a supply chain.',
'Price bands differ by document by an order of magnitude. An identity card sits at {PID} {CUR} and a permanent residence card at {PGREEN} {CUR}, because the register behind each one carries different weight.',
'Start with the document you actually need rather than the bundle. If the requirement is a counter glance, the identity card is enough and the passport is wasted money.',
'Number formats are the fastest filter across all six documents. Each office publishes a rule, and a document that breaks its own rule is wrong no matter how good the print looks.'
)
$T2P2 = @(
'Replica versus registered original applies to every {ADJ} document and it is the distinction that sets the price. A replica copies the look. A registered original carries a number in an office record and resolves when checked.',
'Ask the register question for whichever document you are buying. A seller who can answer it for a passport usually can for a licence too, and a seller who cannot answer it for either is a reseller.',
'Do not pay top-tier prices for a document whose number nobody can check. Where {ADJ} has no public route, buy stock at the middle of the band and accept that the physical layer is all you have.'
)
$T2P3 = @(
'UV response is the common thread across all six. Every {ADJ} document carries UV print from its issuing office, and no colour copier can reproduce it. One cheap torch tests the whole bundle.',
'Substrate differs by document, which is why a single feel test does not work across a set. Polycarbonate cards flex and spring back. Passport pages are dense and cool. Paper laminated between sheets clicks when tapped.'
)
$T2CLOSE = @(
'Take the document you need first and leave the rest. A bundle bought in one go is cheaper per item and harder to test item by item, and the tests are the only thing that matters.',
'Run the six checks on the page you need before you discuss the others. Once one document passes properly, the seller has shown you their standard and you can judge the rest against it.'
)

$STEPS = @(
'Ask which office issued it and confirm the answer is {AUTH}.',
'Request an uncropped photo of the full card on a plain surface with the laminate edge in frame.',
'Request a UV shot of the data page and a close crop of the number field.',
'Test the number against the format {AUTH} uses. A number that breaks the format ends the deal.',
'Agree a price inside the {PRICE} {CUR} band and pay in two parts, deposit then balance against tracking.',
'On arrival check the document against the photos before you accept delivery and photograph the unopened envelope.'
)
$GCHK = @(
'Check the number format against the published rule for {AUTH}. Constructed numbers cannot be invented by hand.',
'Look for the UV print with a 365 nanometre torch. Real ink is sharp and placed deliberately. A print shows a dull bloom or nothing.',
'Loupe the microprint and the ghost image. Both collapse into a dotted line or a grey patch on a photocopy.',
'Compare the data across every field for internal consistency. A postcode that contradicts the state or the office area is a tell.',
'Check the laminate or polycarbonate edge for a fused seal rather than a cut line under a laid sheet.'
)
$GFLG = @(
'The seller cannot name the issuing office, only the country.',
'The number breaks the published format, or is round and repeating.'
)

function DocTitle($doc, $ctry) { if ($doc.Code -eq 'driver-license' -and $ctry -and $ctry.Code -ne 'usa') { return 'Driving Licence' } else { return $doc.Title } }
function DocSing($doc, $ctry) { if ($doc.Code -eq 'driver-license' -and $ctry -and $ctry.Code -ne 'usa') { return 'driving licence' } else { return $doc.Sing } }

function Ctx($doc, $ctry, $auth, $price, $cur, $name, $query) {
  $h = @{}
  $h.Sing = DocSing $doc $ctry
  if ($h.Sing -eq 'driving licence') { $h.Plural = 'driving licences' } else { $h.Plural = $doc.Plural }
  $h.DTitle = DocTitle $doc $ctry
  if ($ctry) { $h.Adj = $ctry.Adj } else { $h.Adj = '' }
  if ($ctry) { $h.Ctry = $ctry.Name } else { $h.Ctry = 'the country in question' }
  $h.Auth = $auth
  $h.Price = $price
  $h.Cur = $cur
  $h.Name = $name
  $h.Query = $query
  $h.Def = $doc.Def
  $h.PID = ''
  $h.PGREEN = ''
  return $h
}

$CODES = @('passport','driver-license','id-card','green-card','visa','residence-permit')
$PRICEKEY = @{ 'passport' = 'PPass'; 'driver-license' = 'PDl'; 'id-card' = 'PId'; 'green-card' = 'PGreen'; 'visa' = 'PVis'; 'residence-permit' = 'PPr' }
$NAMEKEY = @{ 'passport' = 'NPass'; 'driver-license' = 'NDl'; 'id-card' = 'NId'; 'green-card' = 'NGreen'; 'visa' = 'NVis'; 'residence-permit' = 'NPr' }
$AUTHKEY = @{ 'passport' = 'APass'; 'driver-license' = 'ADl'; 'id-card' = 'AId'; 'green-card' = 'AGreen'; 'visa' = 'Avis'; 'residence-permit' = 'APr' }

$DOCS = @()
foreach ($line in (Get-Content (Join-Path $DATA 'documents.txt') -Encoding UTF8)) {
  if (-not $line.Trim()) { continue }
  $f = $line.Split('|')
  $d = @{}
  $d.Code = $f[0]; $d.Sing = $f[1]; $d.Plural = $f[2]; $d.Title = $f[3]; $d.Def = $f[4]
  $d.Receive = @($f[5],$f[6],$f[7],$f[8],$f[9])
  $d.Checks = @($f[10],$f[11],$f[12])
  $d.Flags = @($f[13],$f[14])
  $d.T1 = $f[15]; $d.T2 = $f[16]; $d.T3 = $f[17]
  $d.Faq = @()
  for ($i = 18; $i -lt 28; $i += 2) { $d.Faq += ,@($f[$i], $f[$i+1]) }
  $DOCS += $d
}

$COUNTRIES = @()
foreach ($line in (Get-Content (Join-Path $DATA 'countries.txt') -Encoding UTF8)) {
  if (-not $line.Trim()) { continue }
  $f = $line.Split('|')
  $o = @{}
  $o.Code = $f[0]; $o.Adj = $f[1]; $o.Name = $f[2]; $o.Cur = $f[3]
  $o.ADl = $f[4]; $o.APass = $f[5]; $o.AId = $f[6]; $o.AGreen = $f[7]; $o.Avis = $f[8]; $o.APr = $f[9]
  $o.PDl = $f[10]; $o.PPass = $f[11]; $o.PId = $f[12]; $o.PGreen = $f[13]; $o.PVis = $f[14]; $o.PPr = $f[15]
  $o.Check1 = $f[16]; $o.Check2 = $f[17]; $o.Flag = $f[18]
  $o.NDl = $f[19]; $o.NPass = $f[20]; $o.NId = $f[21]; $o.NGreen = $f[22]; $o.NVis = $f[23]; $o.NPr = $f[24]
  $COUNTRIES += $o
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
  for ($i = 0; $i -lt $COUNTRIES.Count -and $n -lt 8; $i++) {
    $sib = $COUNTRIES[($seed + $i) % $COUNTRIES.Count]
    $t = DocTitle $doc $sib
    $h += '<a class="card" href="/buy/' + $sib.Code + '-' + $doc.Code + '-on-telegram"><span class="k">' + (E $sib.Adj) + '</span><h3>' + (E $t) + '</h3><p>' + (D $sib.($PRICEKEY[$doc.Code])) + ' ' + (E $sib.Cur) + ' observed</p></a>'
    $n++
  }
  return $h + '</div>'
}

function Revision($what) {
  return '<p class="rev">Page last revised ' + $TODAY + '. ' + $what + ' Prices are observed ranges from public adverts. ' + $BRAND + ' is not a seller and holds no affiliation with any issuing authority.</p>'
}

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
  $h += '<h1>Buy a ' + (E $ctry.Adj) + ' ' + (E $dt) + ' on Telegram</h1>'
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
  $title = 'Buy a ' + $ctry.Adj + ' ' + $dt + ' on Telegram: Price & Checks'
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
  $vw = 'on'
  if ($via) { $vw = 'via' }
  $desc = Norm-D ('What a ' + $doc.Sing + ' costs when bought ' + $vw + ' Telegram, who issues it in each country, and the checks that expose a print. Observed band ' + $doc.T1 + ' to ' + $doc.T3 + ' USD.')
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
  $ppr = $ctry.PPass.Split('-'); $plo = [int]$ppr[0]; $phi = [int]$ppr[1]; $h += PriceTable (DocBy 'passport') $plo ([int](($plo + $phi) / 2)) $phi $ctry.Cur
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
  for ($i = 0; $i -lt $COUNTRIES.Count -and $n -lt 8; $i++) { $sib = $COUNTRIES[($sd + $i) % $COUNTRIES.Count]; if ($sib.Code -eq $ctry.Code) { continue }; $h += '<a class="card" href="/buy/' + $sib.Code + '-documents-on-telegram"><h3>' + (E $sib.Adj) + ' documents</h3><p>Six documents, six offices</p></a>'; $n++ }
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
  for ($i = 0; $i -lt $COUNTRIES.Count -and $n -lt 8; $i++) { $sib = $COUNTRIES[($sd + $i) % $COUNTRIES.Count]; if ($sib.Code -eq $ctry.Code) { continue }; $h += '<a class="card" href="/countries/' + $sib.Code + '"><h3>' + (E $sib.Adj) + '</h3><p>Authorities and bands</p></a>'; $n++ }
  $h += '</div>'
  $h += Revision 'Hub reviewed.'
  $title = $ctry.Adj + ' Documents: Authorities and Price Bands'
  $desc = Norm-D ('All six documents in ' + $ctry.Name + ' with the issuing office and the observed band for each. Two local checks and one local red flag.')
  $jl = CrumbJson @(@{H='Home';U='/'}, @{H='Countries';U='/countries'}, @{H=$ctry.Adj;U=$url})
  $json = '[' + $jl + ',{"@context":"https://schema.org","@type":"CollectionPage","name":"' + (E $title) + '","url":"' + $SITE + $url + '","isPartOf":{"@type":"WebSite","url":"' + $SITE + '/"}}]'
  $body = '<nav class="crumbs" aria-label="Breadcrumb"><ol><li><a href="/">Home</a></li><li><a href="/countries">Countries</a></li><li aria-current="page">' + (E $ctry.Adj) + '</li></ol></nav>' + $h
  Emit @{ Url = $url; Title = $title; Desc = $desc; Body = $body; Json = $json; Tier = 'HUB'; Target = ($ctry.Adj.ToLower() + ' documents') }
}

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
  foreach ($o in $COUNTRIES) { $h += '<li><a href="/countries/' + $o.Code + '">' + (E $o.Adj) + '</a></li>' }
  $h += '</ul>'
  $h += $tg
  $homeBody = '<nav class="crumbs" aria-label="Breadcrumb"><ol><li aria-current="page">Home</li></ol></nav><h1>Buy Documents on Telegram</h1>' + $h
  $json = '[{"@context":"https://schema.org","@type":"WebSite","name":"' + $BRAND + '","url":"' + $SITE + '/","inLanguage":"en"},{"@context":"https://schema.org","@type":"Organization","name":"' + $BRAND + '","url":"' + $SITE + '/","email":"' + $MAIL + '"}]'
  Emit @{ Url = '/'; Title = 'Buy Documents on Telegram: Prices, Authorities, Checks'; Desc = (Norm-D 'Independent guide to buying passports, licences, ID cards, visas and residence permits on Telegram. Observed prices, issuing offices and the checks that catch prints.'); Body = $homeBody; Json = $json; Tier = 'HOME'; Target = '' }

  $h = '<p class="lede">Thirty countries, six documents, the office behind each one and the band a fair price sits in. No African states, no padding.</p>'
  $h += '<h2>By document</h2><ul class="hub">'
  foreach ($o in $DOCS) { $h += '<li><a href="/buy/' + $o.Code + '-on-telegram">' + (E $o.Title) + '</a></li>' }
  $h += '</ul><h2>By country</h2><ul class="hub">'
  foreach ($o in $COUNTRIES) { $h += '<li><a href="/countries/' + $o.Code + '">' + (E $o.Adj) + '</a></li>' }
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
  foreach ($o in $COUNTRIES) { $h += '<li><a href="/countries/' + $o.Code + '">' + (E $o.Adj) + '</a></li><li><a href="/buy/' + $o.Code + '-documents-on-telegram">' + (E $o.Adj) + ' documents</a></li>' }
  $h += '</ul><h2>Reference</h2><ul class="hub"><li><a href="/how-to-buy">How to buy</a></li><li><a href="/faq">FAQ</a></li><li><a href="/blog">Blog</a></li><li><a href="/about">About</a></li><li><a href="/contact">Contact</a></li><li><a href="/privacy">Privacy</a></li><li><a href="/terms">Terms</a></li><li><a href="/disclosure">Disclosure</a></li></ul>'
  Simple '/sitemap' 'HTML Sitemap: Every Page on DriveLicensed' 'Every page on the site in hierarchy order: documents, thirty country markets and the reference section.' 'Sitemap' $h 'PAGE'
}

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
foreach ($o in $COUNTRIES) { BuildHub $o; BuildT2 $o }
foreach ($d in $DOCS) { BuildT1 $d $false; BuildT1 $d $true }
foreach ($o in $COUNTRIES) { foreach ($d in $DOCS) { BuildT3 $d $o } }
foreach ($o in $COUNTRIES) { BuildT3B (DocBy 'driver-license') $o }

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
$TARGET = @{ 'T1' = 1400; 'T2' = 900; 'T3' = 700; 'T3B' = 400; 'HUB' = 150; 'BLOG' = 450; 'PAGE' = 60; 'COL' = 50; 'HOME' = 200 }; $VALID = @{}; foreach ($pp in $script:Pages) { $VALID[$pp.Url] = 1 }
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
  $href = $m.Groups[1].Value; if ($href -eq '') { continue }; $k = $href.TrimEnd('/'); if ($k -eq '') { $k = '/' }; if (-not $VALID.ContainsKey($k)) { Add-Issue "broken internal link $href on $u" }
  }
}
foreach ($f in @('style.css','robots.txt','sitemap.xml','404.html')) { if (-not (Test-Path (Join-Path $DIST $f))) { Add-Issue "missing file $f" } }
$dupes = $script:Pages | Group-Object { $_.Title } | Where-Object { $_.Count -gt 1 }
foreach ($d in $dupes) { Add-Issue "duplicate title: $($d.Name)" }
$dupes = $script:Pages | Group-Object { $_.Desc } | Where-Object { $_.Count -gt 1 }
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