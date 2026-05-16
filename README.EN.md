# VCard Skills

[![skills.sh](https://skills.sh/b/notedit/vcard-skills)](https://skills.sh/notedit/vcard-skills)

中文版本: [README.md](./README.md)

## Introduction

Reusable agent skills for creating social card sets from source content.

## Skills

### `text-card-generator`

Generate polished, deterministic shareable card image sets with HTML/CSS plus Playwright screenshots.

Use it for:

- dense text cards;
- finance, product, technical, or editorial explainers;
- exact copy that needs reliable rendering;
- square, vertical, story, or custom-ratio card exports.

### `image-card-generator`

Generate information-first GPT Image 2-led social card sets.

Use it for:

- image-led explainers;
- visual notes;
- cover cards;
- feed-ready card series where GPT Image 2 creates the final PNGs.

This skill expects an Aiberm-compatible image API key for real generation:

```bash
export AIBERM_API_KEY=...
```

It also accepts `AIBEAM_API_KEY` or `API_KEY`. Do not commit secrets to this repository.

## Install

Install all skills:

```bash
npx skills add notedit/vcard-skills
```

Install one skill:

```bash
npx skills add notedit/vcard-skills --skill text-card-generator
npx skills add notedit/vcard-skills --skill image-card-generator
```

Install for Codex explicitly:

```bash
npx skills add notedit/vcard-skills --agent codex
```

## Repository Layout

```text
skills/
  text-card-generator/
    SKILL.md
    references/
    scripts/
  image-card-generator/
    SKILL.md
    references/
    scripts/
```

Each skill is self-contained. Relative paths in `SKILL.md` resolve inside the skill directory.

## Development

Validate discovery from a checkout:

```bash
npx skills add . --list
```

Install from a local checkout:

```bash
npx skills add . --skill text-card-generator
```

## License

MIT
