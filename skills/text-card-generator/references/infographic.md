# Infographic Forms Reference

Use this reference when a card needs an infographic: a designed structure for organizing information visually. This is broader than data visualization. A strong infographic may contain no numeric data at all.

This file borrows AntV Infographic's structure-first classification while keeping the implementation lightweight. Do not install `@antv/infographic`, do not call its official skills, and do not add a new rendering script. Build the final graphic with local HTML/CSS and deterministic inline SVG inside the card page.

Current scope supports six structure forms: list, comparison, sequential, hierarchical, relational, and statistical. AntV also defines a seventh location-based form, but this skill excludes it because it requires verified spatial data or dedicated location assets.

## Core Rule

Plan the information structure before drawing it. The infographic must be the card's organizing system and visual anchor, not a decorative chart beneath a headline.

Before writing HTML, create an `InfographicPlan`:

```text
type: list | comparison | sequential | hierarchical | relational | statistical
structure_intent: parallel | contrast | ordered-flow | parent-child | network | quantitative
source_status: verified | user-provided | synthetic-demo | non-numeric
visual_anchor: cards-list | split-field | rail | tree | node-diagram | data-mark
layout_recipe: artifact-board | process-rail | split-diagram | before-after | proof-grid | big-number
risk: weak-structure | chart-default-look | tiny-labels | fake-data | too-many-boxes
```

If `source_status` is `synthetic-demo`, label the values as illustrative in the card or credits. If factual values affect the claim, cite them in `sources.md`.

## Classification Priority

When a card has multiple possible structures, classify by visible structure in this order:

1. `statistical`: standard chart/data mark such as bars, line, percentage ring, scatter, or metric scale.
2. `comparison`: explicit contrast layout such as left/right, VS, matrix, quadrant, old/new, before/after.
3. `hierarchical`: tree, nested levels, parent-child structure, taxonomy, decision tree, containment.
4. `relational`: network, dependency, system interaction, bidirectional or multi-node connection.
5. `sequential`: ordered flow, process, timeline, lifecycle, causal progression with connecting marks.
6. `list`: parallel items without necessary order, hierarchy, relation, contrast, or statistical marks.

Numbered items do not automatically mean `sequential`; they are `list` unless connectors, arrows, a timeline, or irreversible order are visually explicit.

## Forms

### List

Use for parallel information items: key points, features, checks, summaries, ranked items, service/catalog entries.

- Visual features: numbered labels, bullets, tags, card groups, receipt rows, specimen labels.
- Local implementation: `artifact-board`, checklist rows, catalog cards, annotation labels.
- Avoid: pretending a list is a process when order does not matter.
- Strong anchor ideas: one dominant artifact with attached labels; asymmetric list with one hero item.

### Comparison

Use for explicit contrast: old/new, before/after, A/B plans, pros/cons, tradeoffs, quadrant/matrix logic.

- Visual features: split field, VS mark, mirrored layout, comparison table, quadrant.
- Local implementation: `before-after`, `split-diagram`, split field, contrast strip, receipt comparison.
- Avoid: three equal columns by default; choose a conclusion side when the story has a winner.
- Strong anchor ideas: one torn or shifted boundary; asymmetric emphasis; stamped verdict.

### Sequential

Use for order-dependent flows: steps, timeline, migration, lifecycle, cause-process-result.

- Visual features: arrows, rails, timeline, ladder, circular loop, path marks.
- Local implementation: `process-rail`, stacked steps, milestone timeline.
- Avoid: equal floating boxes with weak arrows; if order can be changed, use `list`.
- Strong anchor ideas: a physical path, conveyor, spiral, ladder, or ticket sequence.

### Hierarchical

Use for parent-child or containment logic: taxonomy, org structure, decision tree, nested architecture, table of contents.

- Visual features: branch lines, size hierarchy, nested frames, indentation, tree structure.
- Local implementation: inline SVG tree, nested artifact, stacked bands, folder/file hierarchy.
- Avoid: symmetric org-chart defaults with tiny labels.
- Strong anchor ideas: oversized root node, nested dossier, cutaway stack, expandable folder.

### Relational

Use for dependencies, interaction, network, system architecture, knowledge graph, role collaboration.

- Visual features: nodes, connectors, bidirectional arrows, hub-and-spoke, cyclic paths.
- Local implementation: node-flow SVG, dependency diagram, system diagram, annotated arrows.
- Avoid: hairball graphs. Keep one main path or one dominant hub.
- Strong anchor ideas: one central object with a few meaningful connections; primary edge bold, secondary edges quiet.

### Statistical

Use for quantitative relationships: bars, line trend, percentage ring, metric scale, distribution, rank.

- Visual features: data bars, line, percentage ring, statistical symbols, one dominant metric.
- Local implementation: `big-number`, simple bar, single-series trend, scale mark, ranking strip.
- Avoid: dashboard aesthetics, dense axes, tiny ticks, multi-color legends, and fake metrics.
- Strong anchor ideas: one large number with context notes; one thick trend line; one comparison bar.

## Explicitly Out Of Scope

- Location-based infographics: regional blocks, store distribution, coordinates, floor plans, or spatial metaphors.
- If the user needs verified geography, use a dedicated location workflow outside this reference.
- If the user only needs a non-geographic relationship, classify it as `relational`.

## Implementation Rules

- Use semantic HTML/CSS for lists, comparisons, artifacts, labels, and rails.
- Use inline SVG for trees, node diagrams, dependency lines, trend strokes, and scale marks when CSS layout becomes brittle.
- Keep text as real HTML where possible. SVG labels are acceptable when they are large, deterministic, and local.
- Use theme tokens for all colors. Infographics may use one accent plus neutral tones; extra colors are only for meaningful categories.
- Labels should stay readable after export; avoid labels below roughly 22-24px on a 1080px canvas.
- Make the structure occupy enough space to be the visual anchor, or attach it to a stronger artifact.
- Record factual sources in `sources.md`; record synthetic/demo values explicitly.

## Design Guidance

- Structure first, style second. If the structure is not recognizable in one second, simplify before decorating.
- Avoid boxed dashboards. A good infographic should feel like a designed object: dossier, board, ticket, tree, specimen, stack, split field, or system diagram.
- Prefer a few meaningful nodes over many generic ones.
- Use connectors only when they encode relation, order, or hierarchy. Decorative arrows are noise.
- The classification should be inspectable in the final screenshot. If the viewer cannot tell whether it is list, comparison, sequence, hierarchy, relation, or chart, the design is under-specified.

## QA Checklist

Pass only if:

- The `InfographicPlan` exists and matches the rendered card.
- The category is visibly correct under the classification priority.
- The structure is the dominant visual anchor.
- The card remains readable at thumbnail scale.
- The result passes normal `render-cards.mjs` audit with no overflow, out-of-bounds elements, or scroll.
- It satisfies `references/taste.md`: no fake-looking data, no default dashboard, no pure black, no Inter default, and no generic AI chart aesthetics.

Fail if:

- The graphic is just decoration and does not organize the information.
- A list is mislabeled as a process only because it has numbers.
- A relation graph becomes a hairball.
- A statistical card looks like a dashboard screenshot.
- A card uses a location-based or floor-plan metaphor under this reference.
- Too many equal boxes compete with no clear anchor.
