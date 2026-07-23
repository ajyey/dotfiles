---
name: tailor-resume
description: Use when tailoring or generating a customized LaTeX resume PDF for a job posting URL using Crawl4AI scraping, a local base resume file, and the host system pdflatex compiler
---

# Tailor Resume Skill

## Overview

Automates tailoring a LaTeX resume for a target job posting URL using the Crawl4AI service at `192.168.68.211:11235` by default and the host system's native `pdflatex` tool for PDF compilation. Set `CRAWL4AI_URL` to override the service endpoint.

## Triggering Scenarios

- User provides a job posting URL and asks to tailor, adapt, or update their resume for it.
- User says `/tailor-resume <URL>` or "tailor my resume for this job: `<URL>`".

---

## Workflow Execution Steps

Before starting, record the absolute directory from which the user invoked the
skill as `INVOCATION_DIR`. Use this original directory for the repository check
at the end of the workflow, even if later commands operate in `/tmp` or the
output directory.

### Step 1: Scrape Job Posting Details (Crawl4AI)

Run the helper bundled with this skill. Its repository source is
`agents/.agents/skills/tailor-resume/resources/tailor-resume.py`, and Stow makes
it available at the following installed path:

```bash
python3 ~/.agents/skills/tailor-resume/resources/tailor-resume.py "<JOB_URL>" --scrape-only
```

### Step 2: Fetch the Private Base Resume from GitHub

Confirm that GitHub CLI is installed and authenticated:

```bash
command -v gh
gh auth status
```

Fetch `resume.tex` from the private `ajyey/resume` repository and save the raw
LaTeX to a temporary working file:

```bash
python3 ~/.agents/skills/tailor-resume/resources/tailor-resume.py --fetch-base-only > /tmp/base_resume.tex
```

The helper defaults to repository `ajyey/resume`, ref `master`, and path
`resume.tex`. Override these with `--base-resume-repo`, `--base-resume-ref`, and
`--base-resume-path`, or the corresponding `BASE_RESUME_*` environment variables.

Read `/tmp/base_resume.tex` as the base document for tailoring. Never print GitHub
credentials or include them in generated files.

### Step 3: LLM Resume Tailoring

Act as an expert technical resume writer and ATS optimization specialist. Treat
the fetched resume as the source of truth and the scraped job description as the
target. Tailor the resume without changing its underlying facts.

#### Non-Negotiable Truthfulness Rules

- Do not add roles, companies, projects, tools, certifications, degrees, or achievements.
- Do not invent metrics. Keep an accomplishment qualitative when the source has
  no metric, or ask the user for the number.
- Only rewrite, reorder, merge, split, or remove material already supported by
  the base resume.
- Use simple, direct, ATS-friendly language. Avoid fluff and never use the word
  "Spearheaded".
- Adjust a job title only to the closest truthful equivalent and never exaggerate seniority.
- Preserve consistent formatting throughout the document.

#### Analyze the Job Description and Establish a Baseline

Before editing, extract and group the most important JD keywords into:

- Domain
- Product
- Technologies
- Data and metrics
- Leadership

Compare those keywords with evidence in the base resume. Record:

- The 15 strongest matches, or all matches when fewer than 15 exist.
- The 15 most important missing or weak keywords, or all gaps when fewer than 15 exist.
- An estimated ATS alignment score out of 100.
- The five highest-impact truthful changes that would improve alignment.

The ATS score is a transparent heuristic, not a claim about a specific employer's
screening system. Never improve the score by adding unsupported claims.

#### Rewrite the Resume

Rewrite only these sections unless the user requests otherwise:

1. Summary, when present. If absent, ask whether to add a two- or three-line summary.
2. Experience.
3. Projects.
4. Skills.

Apply these constraints:

- Keep each role to at most five or six bullets.
- Keep exactly two bullets per project.
- Use JD terminology wherever it truthfully describes existing experience.
- Structure bullets as action + what + how + outcome.
- Include a metric only when that metric already exists in the base resume.
- Reflect industry language such as AI/ML, fintech, or healthcare only when the
  base resume contains supporting experience.

Preserve the LaTeX document structure while editing its content:

- **Preserve:** Preamble, document class, custom macros, contact info, and layout.
- **TeX escaping:** Escape `# $ % & ~ _ ^ \ { }` using `\#`, `\$`, `\%`,
  `\&`, `\textasciitilde{}`, `\_`, `\textasciicircum{}`,
  `\textbackslash{}`, `\{`, and `\}` when those characters are literal text.
- **Artifact format:** Write a complete raw LaTeX document without Markdown fences.

#### Rescore and Iterate

After each rewrite:

- Recalculate the estimated ATS score.
- Record a concise list of changes.
- Iterate up to three total rewrite passes or stop early once the score reaches 95.
- Stop if another pass would require unsupported evidence or make the resume less
  truthful, readable, or technically accurate.
- If the score cannot improve because evidence is missing, identify the exact
  missing information and ask three targeted questions instead of inventing it.

### Step 4: Host System LaTeX PDF Compilation

Use a portable output directory rather than a Linux-specific home path:

```bash
OUTPUT_DIR="${TAILORED_RESUME_OUTPUT_DIR:-$HOME/Downloads/tailored-resume}"
mkdir -p "$OUTPUT_DIR"
```

Save the generated LaTeX code to `$OUTPUT_DIR/Tailored_Resume.tex`.

Check for `pdflatex` on `PATH`. On macOS, also check MacTeX's standard path:

```bash
command -v pdflatex || test -x /Library/TeX/texbin/pdflatex
```

If it is missing, detect the operating system and ask permission before running
the matching installation command:

- Debian/Ubuntu: `sudo apt-get update && sudo apt-get install -y texlive-latex-recommended texlive-latex-extra`
- Arch/CachyOS: `sudo pacman -S --needed texlive-basic texlive-latexrecommended texlive-latexextra`
- macOS: `brew install --cask mactex-no-gui`

Compile through the bundled helper, which runs `pdflatex` twice with
`-no-shell-escape` and supports both Unix `PATH` lookup and MacTeX:

```bash
python3 ~/.agents/skills/tailor-resume/resources/tailor-resume.py \
  --compile-tex "$OUTPUT_DIR/Tailored_Resume.tex" \
  --output-pdf "$OUTPUT_DIR/Tailored_Resume.pdf"
```

### Step 5: Deliver Output to User

- Provide file links to the generated `.tex` and `.pdf` using their resolved
  absolute paths under `$OUTPUT_DIR`.
- Report the initial and updated ATS estimates, strongest keyword matches, and
  important remaining gaps separately from the LaTeX artifact.
- Summarize the resume sections, bullet points, and skills changed, plus any
  iteration notes or unanswered evidence questions.

### Step 6: Offer to Update the Base Resume Repository

After tailoring and compilation succeed, determine whether `INVOCATION_DIR` is
inside the configured base resume repository:

```bash
REPO_ROOT="$(git -C "$INVOCATION_DIR" rev-parse --show-toplevel 2>/dev/null || true)"
if test -n "$REPO_ROOT"; then
  REMOTE_URL="$(git -C "$REPO_ROOT" remote get-url origin 2>/dev/null || true)"
fi
```

Normalize GitHub SSH and HTTPS origins, including an optional `.git` suffix, to
the `owner/repository` form. Compare the result case-insensitively with
`${BASE_RESUME_REPO:-ajyey/resume}`. Do not prompt when the invocation directory
is not in a Git worktree, has no recognizable GitHub origin, or identifies a
different repository.

When the repositories match, confirm that
`$REPO_ROOT/${BASE_RESUME_PATH:-resume.tex}` exists. Then prompt the user:

> Tailoring is complete and this was run from the base resume repository. Do
> you want to update `<base-resume-path>` with the changes made while tailoring?
> I will show the diff and will not commit or push it.

If the user declines, leave the base resume unchanged. If the user accepts:

- Re-read the local base resume immediately before editing it.
- Compare the fetched base, tailored artifact, and current local base. Apply the
  tailored content changes as a minimal patch rather than blindly copying the
  entire generated file.
- Preserve unrelated local changes. If local changes overlap the tailored
  sections, show the conflict and ask how to proceed before editing those lines.
- Compile the updated local base resume with its repository's documented build
  command when one exists; otherwise compile it with the bundled helper.
- Show the resulting `git diff` for the base resume path and report compilation
  status.
- Never commit or push the base resume unless the user explicitly asks.
