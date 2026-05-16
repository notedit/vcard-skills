# VCard Skills

[![skills.sh](https://skills.sh/b/notedit/vcard-skills)](https://skills.sh/notedit/vcard-skills)

English: [README.EN.md](./README.EN.md)

## 简介

用于基于源内容创建社交卡片合集的可复用代理技能。

## 技能

### `text-card-generator`

使用 HTML/CSS 和 Playwright 截图生成精致、可复现、适合分享的卡片图片集合。

适用于：

- 信息密集的文字卡片；
- 金融、产品、技术或编辑类说明内容；
- 需要稳定渲染的精确文案；
- 方形、竖版、故事流或自定义比例的卡片导出。

### `image-card-generator`

生成以信息为先、由 GPT Image 2 驱动的社交卡片合集。

适用于：

- 以图片为主的说明内容；
- 视觉笔记；
- 封面卡片；
- 适合信息流发布的系列卡片，由 GPT Image 2 生成最终 PNG。

这个技能在实际生成时需要一个兼容 Aiberm 的图片 API Key：

```bash
export AIBERM_API_KEY=...
```

它也支持 `AIBEAM_API_KEY` 或 `API_KEY`。请不要将密钥提交到这个仓库。

## 安装

安装全部技能：

```bash
npx skills add notedit/vcard-skills
```

安装单个技能：

```bash
npx skills add notedit/vcard-skills --skill text-card-generator
npx skills add notedit/vcard-skills --skill image-card-generator
```

显式为 Codex 安装：

```bash
npx skills add notedit/vcard-skills --agent codex
```

## 仓库结构

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

每个技能都是自包含的。`SKILL.md` 中的相对路径会在各自的技能目录内解析。

## 开发

在本地检出目录中验证技能发现：

```bash
npx skills add . --list
```

从本地检出目录安装：

```bash
npx skills add . --skill text-card-generator
```

## 许可证

MIT
