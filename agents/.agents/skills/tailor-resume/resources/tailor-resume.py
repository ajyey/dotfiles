#!/usr/bin/env python3
import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.request

CRAWL4AI_URL = os.environ.get("CRAWL4AI_URL", "http://192.168.68.211:11235/crawl_sync")
CRAWL4AI_TOKEN = os.environ.get("CRAWL4AI_TOKEN", "crawl4ai_local_secret")
BASE_RESUME_REPO = os.environ.get("BASE_RESUME_REPO", "ajyey/resume")
BASE_RESUME_REF = os.environ.get("BASE_RESUME_REF", "master")
BASE_RESUME_PATH = os.environ.get("BASE_RESUME_PATH", "resume.tex")


def scrape_job_posting(url):
    """Scrape job posting details using the configured Crawl4AI service."""
    req_body = json.dumps({"urls": url, "priority": 10}).encode("utf-8")
    req = urllib.request.Request(
        CRAWL4AI_URL,
        data=req_body,
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {CRAWL4AI_TOKEN}",
        },
    )

    try:
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read().decode("utf-8"))
    except Exception as exc:
        sys.stderr.write(f"Error calling Crawl4AI at {CRAWL4AI_URL}: {exc}\n")
        sys.exit(1)

    result = data.get("result", {})
    markdown = (result.get("markdown") or "").strip()
    if len(markdown) > 100:
        return markdown

    html = result.get("html") or ""
    # Try parsing JSON-LD Schema.org JobPosting.
    ld_matches = re.findall(r"application/ld\+json[^>]*>(.*?)</script>", html, re.DOTALL)
    for match in ld_matches:
        try:
            parsed = json.loads(match)
            job = parsed[0] if isinstance(parsed, list) else parsed
            if job.get("description"):
                title = f"JOB TITLE: {job.get('title')}\n\n" if job.get("title") else ""
                clean_desc = re.sub(r"<[^>]+>", " ", job.get("description"))
                clean_desc = " ".join(clean_desc.split())
                return title + clean_desc
        except Exception:
            pass

    # Fall back to extracting text from the HTML response.
    cleaned_html = re.sub(r"<(script|style)[^>]*>[\s\S]*?</\1>", "", html, flags=re.IGNORECASE)
    text = re.sub(r"<[^>]+>", " ", cleaned_html)
    return " ".join(text.split())[:10000]


def fetch_base_resume(repo, ref, path):
    """Fetch raw LaTeX from a private GitHub repository using gh authentication."""
    gh_bin = shutil.which("gh")
    if not gh_bin:
        sys.stderr.write("GitHub CLI (gh) is not installed or not available on PATH.\n")
        return None

    result = subprocess.run(
        [
            gh_bin,
            "api",
            "-H",
            "Accept: application/vnd.github.raw+json",
            f"repos/{repo}/contents/{path}?ref={ref}",
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    if result.returncode != 0:
        sys.stderr.write(f"Unable to fetch {repo}/{path} at {ref}:\n{result.stderr}")
        return None

    return result.stdout


def compile_latex_local(latex_code, output_pdf_path):
    """Compile a LaTeX string into a PDF using the host pdflatex command."""
    pdflatex_bin = shutil.which("pdflatex")
    if not pdflatex_bin and os.path.isfile("/Library/TeX/texbin/pdflatex"):
        pdflatex_bin = "/Library/TeX/texbin/pdflatex"
    if not pdflatex_bin:
        sys.stderr.write("pdflatex is not installed or not available on PATH.\n")
        return False

    with tempfile.TemporaryDirectory() as tmpdir:
        tex_path = os.path.join(tmpdir, "document.tex")
        pdf_path = os.path.join(tmpdir, "document.pdf")

        with open(tex_path, "w", encoding="utf-8") as file:
            file.write(latex_code)

        cmd = [
            pdflatex_bin,
            "-no-shell-escape",
            "-interaction=nonstopmode",
            "-output-directory",
            tmpdir,
            tex_path,
        ]

        # Run twice to resolve references.
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if os.path.exists(pdf_path):
            subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

        if not os.path.exists(pdf_path):
            log_path = os.path.join(tmpdir, "document.log")
            if os.path.exists(log_path):
                with open(log_path, "r", encoding="utf-8", errors="ignore") as log_file:
                    log_content = log_file.read()
            else:
                log_content = result.stdout + "\n" + result.stderr
            sys.stderr.write(f"Local pdflatex compilation failed:\n{log_content[-2000:]}\n")
            return False

        os.makedirs(os.path.dirname(os.path.abspath(output_pdf_path)), exist_ok=True)
        shutil.copyfile(pdf_path, output_pdf_path)
        return True


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Fetch a base resume or scrape job details for resume tailoring.")
    parser.add_argument("url", nargs="?", help="Job posting URL")
    parser.add_argument("--scrape-only", action="store_true", help="Print scraped job text and exit")
    parser.add_argument("--fetch-base-only", action="store_true", help="Print the raw base resume and exit")
    parser.add_argument("--base-resume-repo", default=BASE_RESUME_REPO, help="GitHub repository in owner/name format")
    parser.add_argument("--base-resume-ref", default=BASE_RESUME_REF, help="Git branch, tag, or commit")
    parser.add_argument("--base-resume-path", default=BASE_RESUME_PATH, help="Path to the LaTeX resume in the repository")
    parser.add_argument("--compile-tex", help="Compile this LaTeX file using the host pdflatex")
    parser.add_argument("--output-pdf", help="PDF destination; defaults to the input path with a .pdf suffix")
    args = parser.parse_args()

    if args.compile_tex:
        input_path = os.path.abspath(os.path.expanduser(args.compile_tex))
        output_path = args.output_pdf or os.path.splitext(input_path)[0] + ".pdf"
        output_path = os.path.abspath(os.path.expanduser(output_path))
        try:
            with open(input_path, "r", encoding="utf-8") as tex_file:
                latex_code = tex_file.read()
        except OSError as exc:
            sys.stderr.write(f"Unable to read LaTeX input {input_path}: {exc}\n")
            sys.exit(1)

        if not compile_latex_local(latex_code, output_path):
            sys.exit(1)
        print(output_path)
        sys.exit(0)

    if args.fetch_base_only:
        latex = fetch_base_resume(args.base_resume_repo, args.base_resume_ref, args.base_resume_path)
        if latex is None:
            sys.exit(1)
        sys.stdout.write(latex)
        sys.exit(0)

    if not args.url:
        parser.error("a job posting URL is required unless --fetch-base-only is used")

    print(f"Scraping job posting from {args.url} via Crawl4AI...")
    job_text = scrape_job_posting(args.url)
    print(f"Scraped job description successfully ({len(job_text)} characters).")

    if args.scrape_only:
        print("\n--- JOB POSTING TEXT ---")
        print(job_text)
