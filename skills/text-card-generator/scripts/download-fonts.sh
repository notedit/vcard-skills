#!/usr/bin/env bash
# download-fonts.sh — 把卡片用字体下载到 skill 本地 assets/fonts/，并生成 fonts.css。
#
# 设计：
#   - 全部为 OFL / ITF Free Font License，可内嵌打包分发。
#   - woff2 优先；fontsource 可变字体单轴覆盖全字重，体积最小。
#   - 幂等：已存在则跳过；--force 重新下载。
#   - 零额外依赖：只用 curl + python3 标准库。
#   - 非 OFL 字体（HarmonyOS / 阿里普惠 / 京華老宋）不在此下载，授权不允许随仓库再分发；
#     这些在 references/fonts.md 里仅作「系统字体回退」选项，不内嵌。
#
# 用法：
#   bash scripts/download-fonts.sh            # 下载缺失字体
#   bash scripts/download-fonts.sh --force    # 全部重新下载
#
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FORCE="${1:-}"

python3 - "$HERE" "$FORCE" <<'PY'
import sys, os, re, json, urllib.request, urllib.error

ROOT, FORCE = sys.argv[1], (len(sys.argv) > 2 and sys.argv[2] == "--force")
OUT = os.path.join(ROOT, "assets", "fonts")
UA = {"User-Agent": "Mozilla/5.0 (font-fetch; text-card-generator)"}

def get(url, binary=False, tries=3):
    last = None
    for _ in range(tries):
        try:
            req = urllib.request.Request(url, headers=UA)
            with urllib.request.urlopen(req, timeout=40) as r:
                return r.read() if binary else r.read().decode("utf-8", "replace")
        except Exception as e:  # noqa
            last = e
    raise last

def save(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    mode = "wb" if isinstance(data, (bytes, bytearray)) else "w"
    with open(path, mode) as f:
        f.write(data)

def need(path):
    return FORCE or not os.path.exists(path) or os.path.getsize(path) == 0

# fontsource 包：拉 index.css，把 'Xxx Variable' 家族名改回 'Xxx'，再下所有引用的 woff2。
# (dir, jsdelivr_pkg, css_path, family_variable, family_final)
FONTSOURCE = [
    ("geist",                "@fontsource-variable/geist@latest",         "index.css", "Geist Variable",          "Geist"),
    ("geist-mono",           "@fontsource-variable/geist-mono@latest",    "index.css", "Geist Mono Variable",     "Geist Mono"),
    ("space-grotesk",        "@fontsource-variable/space-grotesk@latest", "index.css", "Space Grotesk Variable",  "Space Grotesk"),
    ("newsreader",           "@fontsource-variable/newsreader@latest",    "index.css", "Newsreader Variable",     "Newsreader"),
    ("source-serif-4",       "@fontsource-variable/source-serif-4@latest","index.css", "Source Serif 4 Variable", "Source Serif 4"),
    ("spectral",             "@fontsource/spectral@latest",               "400.css",   "Spectral",                "Spectral"),
    ("spectral-600",         "@fontsource/spectral@latest",               "600.css",   "Spectral",                "Spectral"),
    ("spectral-800",         "@fontsource/spectral@latest",               "800.css",   "Spectral",                "Spectral"),
    ("ibm-plex-mono",        "@fontsource/ibm-plex-mono@latest",          "400.css",   "IBM Plex Mono",           "IBM Plex Mono"),
    ("ibm-plex-mono-500",    "@fontsource/ibm-plex-mono@latest",          "500.css",   "IBM Plex Mono",           "IBM Plex Mono"),
    ("ibm-plex-mono-600",    "@fontsource/ibm-plex-mono@latest",          "600.css",   "IBM Plex Mono",           "IBM Plex Mono"),
    ("libre-caslon-display", "@fontsource/libre-caslon-display@latest",   "400.css",   "Libre Caslon Display",    "Libre Caslon Display"),
    ("noto-sans-sc",         "@fontsource-variable/noto-sans-sc@latest",  "index.css", "Noto Sans SC Variable",   "Noto Sans SC"),
    ("noto-serif-sc",        "@fontsource-variable/noto-serif-sc@latest", "index.css", "Noto Serif SC Variable",  "Noto Serif SC"),
    ("zcool-qingke-huangyou","@fontsource/zcool-qingke-huangyou@latest", "400.css",   "ZCOOL QingKe HuangYou",   "ZCOOL QingKe HuangYou"),
    ("zcool-xiaowei",        "@fontsource/zcool-xiaowei@latest",          "400.css",   "ZCOOL XiaoWei",           "ZCOOL XiaoWei"),
]

# 嵌套 @import 的整包（lxgw lite / 得意黑）：递归抓 css 与 woff2，保持相对结构。
# rename: 把包内声明的 family 归一到 fonts.md 用的名字（最长匹配优先）。
# 第4位 keep：仅保留入口 css 中 @import 文件名命中这些子串的变体（None=全留）。
# 霞鹜文楷瘦身：只留 regular + bold 普通体，丢弃 light 与全部 mono 变体。
PACKAGED = [
    ("lxgw-wenkai", "https://cdn.jsdelivr.net/npm/lxgw-wenkai-lite-webfont/style.css",
     [("LXGW WenKai Lite", "LXGW WenKai")],
     ["lxgwwenkailite-regular", "lxgwwenkailite-bold"]),
    ("smiley-sans", "https://cdn.jsdelivr.net/npm/cn-fontsource-smiley-sans-oblique-regular/font.css",
     [], None),
]

# Fontshare（ITF-FFL，可变 woff2，单文件/家族）。
FONTSHARE = [
    ("satoshi",         "Satoshi"),
    ("general-sans",    "General Sans"),
    ("cabinet-grotesk", "Cabinet Grotesk"),
]

# 单文件/压缩包字体：没有合适的 fontsource 分包，但授权允许随仓库分发。
# 为控制体积，重型多字重字体只保留卡片最常用的 Regular。
DIRECT_TTF = [
    ("lxgw-marker-gothic", "LXGW Marker Gothic",
     "https://github.com/google/fonts/raw/main/ofl/lxgwmarkergothic/LXGWMarkerGothic-Regular.ttf",
     "LXGWMarkerGothic-Regular.ttf", 400, "OFL"),
]

ARCHIVE_TTF = [
    ("zhuque-fangsong", "Zhuque Fangsong",
     "https://github.com/TrionesType/zhuque/releases/download/v0.212/ZhuqueFangsong-v0.212.zip",
     "ZhuqueFangsong-Regular.ttf", "ZhuqueFangsong-Regular.ttf", 400, "OFL"),
    ("maple-mono-cn", "Maple Mono CN",
     "https://github.com/subframe7536/Maple-font/releases/download/v7.9/MapleMono-CN-unhinted.zip",
     "MapleMono-CN-Regular.ttf", "MapleMono-CN-Regular.ttf", 400, "OFL"),
]

report = []

def do_fontsource(dirn, pkg, csspath, famv, famf):
    base = f"https://cdn.jsdelivr.net/npm/{pkg}/{csspath}"
    dst_css = os.path.join(OUT, "css", dirn + ".css")
    if need(dst_css):
        css = get(base)
        # 家族名归一：'Xxx Variable' -> 'Xxx'
        css = css.replace(f"'{famv}'", f"'{famf}'").replace(f'"{famv}"', f'"{famf}"')
        # 把 url(./files/x.woff2) 改为指向集中 woff2 目录
        css = re.sub(r"url\(\.?/?(?:files/)?([^)]+\.woff2)\)",
                     lambda m: f"url(../woff2/{dirn}/{os.path.basename(m.group(1))})", css)
        # fontsource often ships a secondary .woff fallback in the CSS. We only
        # bundle woff2 to keep the skill small and deterministic, so remove the
        # unused fallback references instead of leaving broken local urls.
        css = re.sub(r",\s*url\(\.?/?(?:files/)?[^)]+\.woff\)\s*format\(['\"]woff['\"]\)", "", css)
        save(dst_css, css)
    files = re.findall(r"url\(\.\./woff2/%s/([^)]+\.woff2)\)" % re.escape(dirn),
                        open(dst_css).read())
    n = 0
    for fn in sorted(set(files)):
        dst = os.path.join(OUT, "woff2", dirn, fn)
        if need(dst):
            save(dst, get(f"https://cdn.jsdelivr.net/npm/{pkg}/files/{fn}", binary=True))
            n += 1
    sz = dir_size(os.path.join(OUT, "woff2", dirn))
    report.append((famf, dirn, len(set(files)), sz, "OFL/ITF" ))
    print(f"  fontsource {famf:<22} files={len(set(files)):<3} new={n:<3} {human(sz)}")

def do_packaged(dirn, top, rename, keep):
    # 递归：解析 @import 与 url() 的 woff2/css，全部镜像到 packages/<dirn>/
    root = os.path.join(OUT, "packages", dirn)
    entry = os.path.basename(top)
    seen = set()
    csspaths = []
    def fetch(url, rel):
        if rel in seen:
            return
        seen.add(rel)
        dst = os.path.join(root, rel)
        is_css = rel.endswith(".css")
        if need(dst):
            save(dst, get(url, binary=not is_css))
        if is_css:
            txt = open(dst, encoding="utf-8", errors="replace").read()
            # 入口 css 瘦身：仅保留命中 keep 的 @import 行，重写文件
            if keep and rel == entry:
                kept = [ln for ln in txt.splitlines()
                        if "@import" not in ln or any(k in ln for k in keep)]
                txt = "\n".join(kept) + "\n"
                save(dst, txt)
            csspaths.append(dst)
            base = url.rsplit("/", 1)[0]
            for ref in re.findall(r"@import url\(['\"]?\.?/?([^'\")]+)['\"]?\)", txt) + \
                       re.findall(r"url\(['\"]?\.?/?([^'\")]+\.woff2)['\"]?\)", txt):
                child_rel = os.path.normpath(os.path.join(os.path.dirname(rel), ref))
                fetch(base + "/" + ref, child_rel)
    fetch(top, entry)
    # family 归一：每次运行都重跑，幂等（最长匹配先替换）
    for cp in csspaths:
        t = open(cp, encoding="utf-8", errors="replace").read()
        orig = t
        for old, new in rename:
            t = t.replace("'%s'" % old, "'%s'" % new).replace('"%s"' % old, '"%s"' % new)
        if t != orig:
            save(cp, t)
    sz = dir_size(root)
    report.append((dirn, "packages/" + dirn, sum(1 for _ in walk_woff2(root)), sz, "OFL"))
    print(f"  packaged   {dirn:<22} entry={os.path.basename(top):<14} {human(sz)}")

def do_fontshare(slug, family):
    css = get(f"https://api.fontshare.com/v2/css?f[]={slug}@1&display=swap")
    m = re.search(r"src:\s*url\(['\"]?(//[^'\")]+\.woff2)", css)
    wr = re.search(r"font-weight:\s*([0-9]+\s+[0-9]+|[0-9]+)", css)
    if not m:
        print(f"  fontshare  {family:<22} SKIP (no woff2 in css)")
        report.append((family, "fontshare/" + slug, 0, 0, "ITF-FFL (missing)"))
        return
    woff2_url = "https:" + m.group(1)
    weight = wr.group(1) if wr else "400 900"
    dst = os.path.join(OUT, "woff2", "fontshare", slug + ".woff2")
    if need(dst):
        save(dst, get(woff2_url, binary=True))
    face = (f"/* {family} — Fontshare, ITF Free Font License */\n"
            f"@font-face{{font-family:'{family}';font-style:normal;font-display:swap;"
            f"font-weight:{weight};src:url(../woff2/fontshare/{slug}.woff2) format('woff2');}}\n")
    save(os.path.join(OUT, "css", slug + ".css"), face)
    sz = os.path.getsize(dst)
    report.append((family, "fontshare/" + slug, 1, sz, "ITF-FFL"))
    print(f"  fontshare  {family:<22} weight={weight:<9} {human(sz)}")

def write_ttf_face(dirn, family, filename, weight, license_name):
    face = (f"/* {family} — {license_name} */\n"
            f"@font-face{{font-family:'{family}';font-style:normal;font-display:swap;"
            f"font-weight:{weight};src:url(../ttf/{dirn}/{filename}) format('truetype');}}\n")
    save(os.path.join(OUT, "css", dirn + ".css"), face)

def do_direct_ttf(dirn, family, url, filename, weight, license_name):
    dst = os.path.join(OUT, "ttf", dirn, filename)
    if need(dst):
        save(dst, get(url, binary=True))
    write_ttf_face(dirn, family, filename, weight, license_name)
    sz = os.path.getsize(dst)
    report.append((family, "ttf/" + dirn, 1, sz, license_name))
    print(f"  direct     {family:<22} weight={weight:<9} {human(sz)}")

def do_archive_ttf(dirn, family, url, member, filename, weight, license_name):
    import zipfile, io
    dst = os.path.join(OUT, "ttf", dirn, filename)
    if need(dst):
        data = get(url, binary=True, tries=2)
        with zipfile.ZipFile(io.BytesIO(data)) as z:
            names = z.namelist()
            target = member if member in names else next((n for n in names if n.endswith("/" + member) or n.endswith(member)), None)
            if not target:
                raise RuntimeError(f"{member} not found in {url}")
            save(dst, z.read(target))
    write_ttf_face(dirn, family, filename, weight, license_name)
    sz = os.path.getsize(dst)
    report.append((family, "ttf/" + dirn, 1, sz, license_name))
    print(f"  archive    {family:<22} weight={weight:<9} {human(sz)}")

def walk_woff2(root):
    for dp, _, fs in os.walk(root):
        for f in fs:
            if f.endswith(".woff2"):
                yield os.path.join(dp, f)

def dir_size(p):
    return sum(os.path.getsize(os.path.join(dp, f))
               for dp, _, fs in os.walk(p) for f in fs) if os.path.isdir(p) else 0

def human(n):
    for u in ("B", "KB", "MB"):
        if n < 1024:
            return f"{n:.0f}{u}"
        n /= 1024
    return f"{n:.1f}GB"

print("→ fontsource (Latin VF + 思源黑/宋 分包):")
for a in FONTSOURCE:
    try:
        do_fontsource(*a)
    except Exception as e:  # noqa
        print(f"  ! {a[4]} FAILED: {e}")

print("→ packaged (霞鹜文楷 Lite / 得意黑):")
for a in PACKAGED:
    try:
        do_packaged(*a)
    except Exception as e:  # noqa
        print(f"  ! {a[0]} FAILED: {e}")

print("→ fontshare (Satoshi / General Sans / Cabinet Grotesk):")
for a in FONTSHARE:
    try:
        do_fontshare(*a)
    except Exception as e:  # noqa
        print(f"  ! {a[1]} FAILED: {e}")

print("→ direct/archive CJK fonts (朱雀 / 霞鹜漫黑 / Maple Mono CN):")
for a in DIRECT_TTF:
    try:
        do_direct_ttf(*a)
    except Exception as e:  # noqa
        print(f"  ! {a[1]} FAILED: {e}")
for a in ARCHIVE_TTF:
    try:
        do_archive_ttf(*a)
    except Exception as e:  # noqa
        print(f"  ! {a[1]} FAILED: {e}")

# 组装 master fonts.css
# 只 @import 实际存在且非空的 css —— 下载失败的字体自动被排除，
# 不会在卡片里引用一个加载不到的家族（“去掉无法完成下载的字体”由此结构性保证）。
def have(rel):
    p = os.path.join(OUT, rel)
    return os.path.exists(p) and os.path.getsize(p) > 0

imports = []
for a in FONTSOURCE:
    if have(f"css/{a[0]}.css"):
        imports.append(f'@import url("./css/{a[0]}.css");')
for slug, _ in FONTSHARE:
    if have(f"css/{slug}.css"):
        imports.append(f'@import url("./css/{slug}.css");')
for dirn, _fam, _url, _fn, _w, _lic in DIRECT_TTF:
    if have(f"css/{dirn}.css"):
        imports.append(f'@import url("./css/{dirn}.css");')
for dirn, _fam, _url, _mem, _fn, _w, _lic in ARCHIVE_TTF:
    if have(f"css/{dirn}.css"):
        imports.append(f'@import url("./css/{dirn}.css");')
for dirn, top, _, _ in PACKAGED:
    if have(f"packages/{dirn}/{os.path.basename(top)}"):
        imports.append(f'@import url("./packages/{dirn}/{os.path.basename(top)}");')

master = "/* fonts.css — 本地内嵌字体（download-fonts.sh 生成，勿手改）\n" \
         "   规则与主题映射见 ../../references/fonts.md。\n" \
         "   家族名：Geist / Geist Mono / Space Grotesk / Newsreader / Source Serif 4 /\n" \
         "   Spectral / IBM Plex Mono / Libre Caslon Display / Satoshi / General Sans /\n" \
         "   Cabinet Grotesk / Noto Sans SC / Noto Serif SC / LXGW WenKai* / Smiley Sans Oblique /\n" \
         "   Zhuque Fangsong / LXGW Marker Gothic / Maple Mono CN / ZCOOL QingKe HuangYou / ZCOOL XiaoWei */\n\n" \
         + "\n".join(imports) + "\n"
save(os.path.join(OUT, "fonts.css"), master)

total = dir_size(OUT)
lines = ["# Font bundle manifest (download-fonts.sh)", "",
         "| family | path | files | size | license |",
         "|---|---|---|---|---|"]
for fam, path, nf, sz, lic in report:
    lines.append(f"| {fam} | {path} | {nf} | {human(sz)} | {lic} |")
lines += ["", f"**Total bundle: {human(total)}**", "",
          "Not bundled (system-font fallback only):",
          "- HarmonyOS Sans SC / Alibaba PuHuiTi 3.0 / KingHwa OldSong — license unclear for repo redistribution.",
          "- Sarasa Gothic SC / Sarasa Mono SC — OFL, but only TTC/7z releases; no clean woff2/ttf source under the",
          "  curl + python3-stdlib zero-dependency constraint. Treat as system fallback; add manually if a webfont appears."]
save(os.path.join(OUT, "MANIFEST.md"), "\n".join(lines) + "\n")

print(f"\n✓ fonts.css + MANIFEST.md written. Total bundle: {human(total)}")
PY
