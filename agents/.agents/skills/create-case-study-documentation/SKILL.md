---
name: create-case-study-documentation
description: Use when turning an old and new website into portfolio case-study documentation, before/after screenshots, Lighthouse and latency comparisons, or a downloadable PDF report.
---

# Create Case Study Documentation

## Core Principle

Build a persuasive report from reproducible evidence. Separate measured results, browser observations, expert design judgments, and unavailable business outcomes. Never turn a lab score or visual opinion into a conversion, traffic, ranking, or revenue claim.

## Deliverables

Produce these artifacts unless the user explicitly narrows scope:

1. A neutral Markdown case study containing context, challenge, approach, measured results, UX audit, technical deliverables, tradeoffs, limitations, and visual evidence.
2. Matched full-page screenshots for every inventoried page in `artifacts/before/` and `artifacts/after/` with identical route and viewport names.
3. Raw Lighthouse JSON and latency measurements in `artifacts/evidence/` or a temporary directory.
4. A standalone print HTML source and a downloadable PDF in `artifacts/case-study/`.

## Evidence Contract

Before writing claims, create a complete route inventory for both sites:

| Cohort | Old URL | New URL | Status/content notes |
| --- | --- | --- | --- |

Discover routes from source files, sitemaps, navigation and internal-link crawls, build output, and direct probes. Use one row for every public route or URL variant on either site, including deep pages, added and removed pages, moved pages, extension variants, redirecting aliases, and failed routes. Mark each row as `shared`, `added`, `removed`, `moved`, `rewritten`, `redirect`, `failure`, or `unavailable`. Preserve the exact old and new URLs and record the date, browser version, tool versions, viewport, cache state, and third-party availability.

Compare equivalent routes, not raw URL counts. The complete inventory is the report scope. A “cohort” is a named subset used for a specific calculation; it must never be an implicit representative sample. If the site is too large for exhaustive coverage, stop and ask the user to approve a narrower scope before omitting anything.

Use these labels internally while researching:

- **Measured:** Lighthouse, `curl`, Playwright, build/test output, or a direct HTTP response.
- **Observed:** a repeatable browser or screenshot observation.
- **Subjective:** an expert design judgment, clearly written as such.
- **Unavailable:** analytics, conversion, user research, or any other evidence not collected.

If there is no comparable old baseline, report the new result as a benchmark, not an improvement. If analytics are absent, explicitly say that conversion, traffic, engagement, rankings, and revenue impact were not measured.

## Workflow

### 1. Freeze Scope

Read the repository instructions, existing documentation, source inventory, recent commits, and existing screenshots before auditing. Confirm permission to republish client screenshots and redact personal data, tokens, private URLs, or form contents.

Capture every inventoried page that resolves on either site, not only important or representative pages. Capture one-sided pages where no equivalent exists, and record failures, redirects, and unavailable counterparts explicitly instead of silently substituting a nearby page.

### 2. Capture Matched Screenshots

Use Playwright's bundled Chromium, Firefox, or WebKit. Do not require system Chrome when a Playwright browser is available.

Capture each route at `1440x900` and `390x844` with the same device scale factor. Wait for fonts and images, scroll slowly in viewport-sized increments to trigger lazy content, wait roughly 1.5-2.5 seconds after each position, settle 5-8 seconds before and after the scroll, return to the top, then capture `fullPage: true`. Use `animations: "disabled"` only for the final screenshot so lazy content and scroll states have had time to settle.

Use generic, stable ASCII names. Do not bake a client or project name into the directory convention:

```text
artifacts/before/home-desktop.png
artifacts/before/home-mobile.png
artifacts/after/home-desktop.png
artifacts/after/home-mobile.png
artifacts/evidence/lighthouse/before/home-mobile-run-01.json
artifacts/evidence/lighthouse/after/home-mobile-run-01.json
```

Use a normalized route slug for nested paths and preserve the exact URL in the route inventory. Verify every capture returned HTTP 200 or an explicitly documented redirect, is a non-empty PNG, and shows the intended route. Generate a contact sheet or inspect every route's capture set; representative zoom checks may supplement full coverage but may not replace it.

### 3. Collect Performance Data

Use one pinned Lighthouse version and one browser binary for both sites. Run the mobile configuration and `--preset=desktop` for every inventoried route that resolves on either site. Pair shared and moved routes; report added, removed, one-sided, redirecting, and failed routes separately. Do not omit a route because it is deep, added, moved, slow, or an outlier. Prefer three runs per route and report medians and ranges. If time or environment permits only one run, label the table `single-run lab data` and do not present it as field performance.

Collect:

- Performance, accessibility, best-practices, and SEO scores.
- FCP, LCP, CLS, TBT or INP, and Speed Index.
- Total byte weight and network request count.
- Failed audits and run warnings.

When Lighthouse cannot paint a route, record `NO_FCP` and the reason. Do not invent a score or silently drop the route from the denominator.

For document-only latency, run compressed `curl` requests with redirects enabled and record status, final URL, redirect count, DNS, connect, TLS, TTFB, total time, and downloaded bytes. Call this client-observed document timing, not backend latency. Keep TTFB and total transfer time separate; different CDNs can make TTFB worse while a smaller document transfers faster.

For runtime complexity, use Playwright to record comparable observations such as serialized document size, script count, resource entries, intrinsic image dimensions, and navigation timing. State the exact page and wait condition for these observations.

### 4. Audit Behavior and Design

Run the same manual checks on every inventoried route that contains the relevant control:

- Find and activate the primary CTA.
- Open and close mobile navigation, including Escape and focus behavior.
- Navigate between every route and refresh every deep route.
- Use keyboard focus through menus, forms, dialogs, and galleries.
- Inspect form fields without submitting live data unless the user approves it.
- Open every gallery or modal, use previous/next controls, close it, and confirm focus return.
- Test at desktop and mobile viewports, including horizontal-overflow checks.

Record findings as observations. Use phrases such as “the audit observed,” “the screenshots show,” or “the implementation provides.” Do not call expert inspection a usability study. Do not call automated accessibility scores WCAG compliance.

Audit hierarchy, navigation clarity, CTA placement, content scanability, responsive layout, motion, contrast, focus states, semantic landmarks, image handling, and form feedback. Mention improvements such as fewer decorative scroll animations only when visible in the screenshots or supported by source and browser behavior.

### 5. Write the Markdown Case Study

Use a neutral, portfolio-ready structure:

1. Title, client, scope, stack, and date.
2. Overview and challenge.
3. Goals and approach.
4. Lighthouse result tables with denominator and conditions.
5. Latency and runtime-complexity findings.
6. UX, design, responsive, motion, and accessibility audit.
7. Technical deliverables and hosting tradeoffs.
8. Limitations and next opportunities.
9. A complete route-by-route evidence section with every inventoried page, its old/new URL, status, screenshot coverage, measurement coverage, and notes.
10. Closing summary that repeats only supported outcomes.

Include total route counts by status, the measurement denominator, capture coverage, and an explicit list of unavailable or omitted evidence. Every route in the inventory must appear in the Markdown at least once, including added, removed, moved, failed, and unavailable routes. A representative sample may receive deeper commentary, but it may not replace route-by-route coverage. Include a limitation whenever evidence is absent. Deep-page outliers belong in the report even when they weaken the headline. Do not claim “the site is faster” from a homepage score alone; say which cohort and metric improved under which conditions.

### 6. Generate the PDF Report

Create a dedicated HTML print layout rather than printing raw Markdown. Use US Letter for US client and agency portfolios unless the user requests A4. Keep the report visually aligned with the redesigned site: local font, brand colors, clear metric cards, restrained borders, and repeated page headers/footers.

Use a content-driven page plan; never impose a fixed page-count limit that can omit routes:

1. Cover and positioning statement.
2. Executive summary and metric cards.
3. Scope, complete route inventory, and methodology.
4. One route evidence entry or page for every inventoried route, including status and unavailable evidence where applicable.
5. Aggregate Lighthouse, latency, and runtime findings.
6. Cross-route UX, responsive, motion, and accessibility audit.
7. Architecture, technical deliverables, hosting tradeoffs, and limitations.
8. Closing statement and evidence appendix.

The approved route inventory is the PDF's complete scope. Every route must appear in the PDF at least once through a route evidence entry or an explicit documented status such as added, removed, moved, unavailable, failed, or not comparable. Include before/after screenshot pairs for every route that has both captures. Report length is content-driven; the compact outline above is not an eight-page limit.

Use local `<img>` elements for screenshots, local fonts, `@page { size: Letter; margin: 0; }`, `printBackground: true`, zero API margins, `preferCSSPageSize: true`, and explicit page wrappers with `break-after: page`. Avoid using `overflow: hidden` to conceal content until each page's content height has been checked. Keep tables, figures, and metric cards from splitting when possible.

Render with the available Playwright browser:

```js
import { chromium } from 'playwright';
import { resolve } from 'node:path';
import { pathToFileURL } from 'node:url';

const browser = await chromium.launch({ headless: true });
const page = await browser.newPage({ viewport: { width: 816, height: 1056 } });
await page.emulateMedia({ media: 'print' });
await page.goto(pathToFileURL(resolve('artifacts/case-study/report.html')).href, { waitUntil: 'load' });
await page.evaluate(async () => {
  await document.fonts.ready;
  for (const image of document.images) {
    if (!image.complete || !image.naturalWidth) throw new Error(`Image failed: ${image.src}`);
    await image.decode();
  }
});
await page.pdf({
  path: 'artifacts/case-study/report.pdf',
  format: 'Letter',
  printBackground: true,
  preferCSSPageSize: true,
  margin: { top: 0, right: 0, bottom: 0, left: 0 },
});
await browser.close();
```

If the runtime only provides `playwright-core`, import it from the installed package and set its browser `executablePath` to the bundled browser. Never switch to an untracked system browser just to make the command work.

### 7. Verify the PDF Itself

Browser screenshots do not prove PDF pagination. Run all applicable checks:

```bash
pdfinfo artifacts/case-study/report.pdf
pdftotext -layout artifacts/case-study/report.pdf -
pdftoppm -png -r 160 artifacts/case-study/report.pdf /tmp/case-study-page
```

Also verify that the PDF has the content-driven page count, Letter dimensions, every route from the inventory, required headings in extracted text, every image embedded, no page blank or clipped, screenshot labels paired, tables readable, colors printable, and no missing local assets. Use `qpdf --check` and `pdfimages -list` when those tools are installed. A PDF that contains only a summary and representative pages fails this requirement.

## Common Failure Modes

| Rationalization | Correction |
| --- | --- |
| “The homepage represents the whole site.” | Build the complete route inventory; use cohorts only for named calculations and disclose outliers. |
| “Use the best Lighthouse run.” | Repeat runs and report medians/ranges. |
| “TTFB is backend latency.” | Label it client-observed timing and separate it from transfer time. |
| “Different route extensions are close enough.” | Build an old-to-new route map and test direct responses. |
| “The design obviously converts better.” | State that conversion impact is unavailable without analytics or experiments. |
| “A browser screenshot proves the PDF is correct.” | Render every PDF page and inspect the actual output. |
| “A missing image is only a preview issue.” | Fail generation when `naturalWidth` is zero. |
| “The PDF can hide overflow.” | Measure page content before using clipping or fixed-height wrappers. |
| “A compact report is cleaner if it shows only representative pages.” | Put every inventoried route in the PDF; use representative pages only for deeper commentary. |
| “A 100 accessibility score means accessible.” | Report the score as automated evidence, not certification. |
| “The form should work because the code exists.” | Verify a real submission separately; otherwise disclose the gap. |

## Completion Checklist

- [ ] Old/new route map and route status checks recorded.
- [ ] Route discovery reconciled against source files, sitemaps, navigation/link crawls, build output, and direct probes.
- [ ] Every public route and URL variant appears in the inventory, including added, removed, moved, redirecting, failed, and unavailable routes.
- [ ] Screenshot permission and privacy review completed.
- [ ] Every inventoried route has matched desktop/mobile captures where the route resolves; one-sided evidence is documented.
- [ ] Lighthouse version, browser, settings, date, denominator, and warnings recorded.
- [ ] Lighthouse coverage includes every inventoried route that resolves on either site.
- [ ] Lighthouse medians/ranges computed without cherry-picking.
- [ ] TTFB and document transfer metrics labeled correctly.
- [ ] Qualitative observations separated from measured outcomes.
- [ ] No unsupported traffic, conversion, SEO, ranking, or revenue claims.
- [ ] Markdown includes every route in the inventory at least once.
- [ ] PDF HTML source uses local assets and a single page-size authority.
- [ ] PDF includes every route in the inventory at least once, with explicit statuses for unavailable evidence.
- [ ] PDF page count is content-driven; dimensions, extracted text, embedded images, route coverage, and rendered pages are verified.
- [ ] Final Markdown and PDF links resolve.
