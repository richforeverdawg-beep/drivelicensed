# DriveLicensed

Static programmatic SEO site for drivelicensed.com. No framework, no npm. One PowerShell generator, plain HTML output.

## Rebuild

    Set-Location (Join-Path $env:USERPROFILE 'Desktop\drivelicensed')
    .\build.ps1

Then confirm it printed `Issues: 0`. If it printed anything else, fix and rerun before committing.

## Structure

- `documents/countries.txt` - 30 countries, 25 pipe fields each
- `documents/documents.txt` - 6 documents, definition, checks, flags, tiers, FAQ
- `documents/blog.txt` - blog posts
- `build.ps1` - generator, writes to `dist`, audits its own output
- `style.css` - the only stylesheet
- `dist/` - build output, committed, served by Vercel

## Add a blog post

Append one line to `documents/blog.txt` in this field order:

    slug|Title|Description|p1|p2|p3|p4|p5|p6|p7|p8|q1|a1|q2|a2|q3|a3

Then rebuild, commit, push.

## Swap the Telegram handle

Replace `t.me/drivelicensed` in `build.ps1` (variable `$TG`) and rebuild.

## Deploy

Committed to GitHub, imported to Vercel. `dist` is committed on purpose because there is no build step.

## Claims

No document is called genuine. Replica versus registered original is stated on every guide. Prices are observed ranges.