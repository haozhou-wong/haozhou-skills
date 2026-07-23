#!/usr/bin/env bash
set -Eeuo pipefail

SKILLS_DIR="${SKILLS_DIR:-"$HOME/.agents/skills"}"
GITHUB_BASE_URL="${GITHUB_BASE_URL:-https://github.com}"
GITHUB_ARCHIVE_URL="${GITHUB_ARCHIVE_URL:-https://codeload.github.com}"
WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/agents-skills.XXXXXX")"

cleanup() {
  rm -rf "$WORKDIR"
}
trap cleanup EXIT

die() {
  echo "error: $*" >&2
  exit 1
}

require_commands() {
  local missing=()
  local cmd

  for cmd in awk cp curl git mkdir mv rm tar; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      missing+=("$cmd")
    fi
  done

  if ((${#missing[@]})); then
    die "missing required command(s): ${missing[*]}"
  fi
}

default_branch_for() {
  local repo="$1"
  local branch

  branch="$(
    git ls-remote --symref "$GITHUB_BASE_URL/$repo.git" HEAD |
      awk '$1 == "ref:" { sub("refs/heads/", "", $2); print $2; exit }'
  )"

  [[ -n "$branch" ]] || die "could not resolve default branch for $repo"
  printf '%s\n' "$branch"
}

repo_key_for() {
  local repo="$1"
  local ref="$2"

  printf '%s--%s' "${repo//\//__}" "${ref//\//__}"
}

declare -A REPO_ROOTS=()
FETCH_REPO_ROOT=""

fetch_repo() {
  local repo="$1"
  local ref="${2:-}"
  local branch key archive extract roots

  if [[ -z "$ref" ]]; then
    branch="$(default_branch_for "$repo")"
  else
    branch="$ref"
  fi

  key="$(repo_key_for "$repo" "$branch")"
  if [[ -n "${REPO_ROOTS[$key]:-}" ]]; then
    FETCH_REPO_ROOT="${REPO_ROOTS[$key]}"
    return
  fi

  archive="$WORKDIR/$key.tar.gz"
  extract="$WORKDIR/$key"

  echo "fetch $repo@$branch" >&2
  curl -fsSL --retry 3 --retry-delay 2 \
    "$GITHUB_ARCHIVE_URL/$repo/tar.gz/$branch" \
    -o "$archive"

  mkdir -p "$extract"
  tar -xzf "$archive" -C "$extract"

  shopt -s nullglob
  roots=("$extract"/*)
  shopt -u nullglob

  ((${#roots[@]} == 1)) || die "unexpected archive layout for $repo@$branch"
  REPO_ROOTS[$key]="${roots[0]}"
  FETCH_REPO_ROOT="${roots[0]}"
}

replace_dir() {
  local src="$1"
  local dest="$2"
  local old="$WORKDIR/old-$(basename "$dest")"

  mkdir -p "$(dirname "$dest")"

  if [[ -e "$dest" || -L "$dest" ]]; then
    mv "$dest" "$old"
  fi

  if mv "$src" "$dest"; then
    rm -rf "$old"
    return
  fi

  if [[ -e "$old" || -L "$old" ]]; then
    mv "$old" "$dest"
  fi
  die "failed to replace $dest"
}

install_skill() {
  local spec="$1"
  local name repo path ref root src stage

  IFS='|' read -r name repo path ref <<<"$spec"
  [[ -n "$name" && -n "$repo" && -n "$path" ]] || die "bad skill spec: $spec"

  fetch_repo "$repo" "$ref"
  root="$FETCH_REPO_ROOT"
  if [[ "$path" == "." ]]; then
    src="$root"
  else
    src="$root/$path"
  fi

  [[ -d "$src" ]] || die "source directory not found: $repo/$path"
  [[ -f "$src/SKILL.md" ]] || die "source has no SKILL.md: $repo/$path"

  stage="$WORKDIR/stage/$name"
  mkdir -p "$stage"
  cp -a "$src/." "$stage/"
  replace_dir "$stage" "$SKILLS_DIR/$name"

  echo "installed $name"
}

require_commands
mkdir -p "$SKILLS_DIR"

SKILLS=(
  "find-docs|upstash/context7|skills/find-docs|"
  "playwright-cli|microsoft/playwright-cli|skills/playwright-cli|"
  "humanizer|blader/humanizer|.|"
  "humanizer-zh|op7418/Humanizer-zh|.|"
  "grilling|mattpocock/skills|skills/productivity/grilling|"
  "handoff|mattpocock/skills|skills/productivity/handoff|"
  "teach|mattpocock/skills|skills/productivity/teach|"
  "canvas-design|anthropics/skills|skills/canvas-design|"
  "doc-coauthoring|anthropics/skills|skills/doc-coauthoring|"
  "docx|anthropics/skills|skills/docx|"
  "pdf|anthropics/skills|skills/pdf|"
  "pptx|anthropics/skills|skills/pptx|"
  "xlsx|anthropics/skills|skills/xlsx|"
  "creative-thinking-for-research|Orchestra-Research/AI-Research-SKILLs|21-research-ideation/creative-thinking-for-research|"
  "brainstorming-research-ideas|Orchestra-Research/AI-Research-SKILLs|21-research-ideation/brainstorming-research-ideas|"
  "systems-paper-writing|Orchestra-Research/AI-Research-SKILLs|20-ml-paper-writing/systems-paper-writing|"
  "academic-plotting|haozhou-wong/AI-Research-SKILLs|20-ml-paper-writing/academic-plotting|"
  "presenting-conference-talks|Orchestra-Research/AI-Research-SKILLs|20-ml-paper-writing/presenting-conference-talks|"
  "paper-verification|fcakyon/phd-skills|plugin/skills/paper-verification|"
  "pdf-explore|HughYau/AcademicForge|skills/claude-science/pdf-explore|site-first"
  "learn|HughYau/AcademicForge|skills/claude-science/learn|site-first"
  "paper-search|dr-dumpling/paper-search-cli|skills/paper-search|"
  "cliexec|haozhou-wong/cliexec|skills/cliexec|"
  "literature-survey|haozhou-wong/haozhou-skills|literature-survey|"
)

warn_unlisted_skills() (
  local spec name entry
  declare -A listed=()

  for spec in "${SKILLS[@]}"; do
    name="${spec%%|*}"
    listed["$name"]=1
  done

  shopt -s dotglob nullglob
  for entry in "$SKILLS_DIR"/*; do
    [[ -d "$entry" && -f "$entry/SKILL.md" ]] || continue
    name="${entry##*/}"
    [[ -z "${listed[$name]+x}" ]] || continue
    printf 'warning: skill not listed for installation: %s\n' "$name" >&2
    printf 'remove with: rm -rf -- %q\n' "$entry" >&2
  done
)

for spec in "${SKILLS[@]}"; do
  install_skill "$spec"
done

echo
warn_unlisted_skills
echo "done: installed ${#SKILLS[@]} skills into $SKILLS_DIR"
