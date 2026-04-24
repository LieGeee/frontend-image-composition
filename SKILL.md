---
name: frontend-image-composition
description: Use when a user provides a UI screenshot, page reference, or frontend page to improve with style recommendations, transparent-background generated assets, project-aware asset save paths, replacement of AI-heavy visuals, and final page integration.
---

# Frontend Image Composition

## Overview

Use this skill when the user wants a full front-end visual workflow: analyze a screen, recommend style changes, decide where assets are needed or should be replaced, generate transparent-background assets with `gpt-image-2`, save them into the most appropriate project directory, review for AI artifacts, and integrate them into the page with minimal front-end changes.

Do not stop at abstract advice when the user expects implementation.

## When to Use

- The user shares a screenshot, mockup, or reference page and wants front-end visual improvement.
- The user asks where a page needs assets, which assets should be replaced, or what style fits best.
- The user wants `gpt-image-2` assets with transparent background for direct UI integration.
- The user wants the AI to choose a save path by probing the project instead of using a hard-coded asset directory.

Do not use this skill for pure copy edits, non-visual frontend bugfixes, or backend-only work.

## Core Workflow

1. Identify the target page, screenshot, component, or visual area the user wants changed.
2. Analyze page type, hierarchy, weak visual areas, and any existing assets that should be replaced.
3. Recommend 1-3 style directions and choose one default direction.
4. Decide whether the page needs new assets, replacement assets, or only layout and style cleanup.
5. Probe the codebase for the nearest existing asset-directory pattern before choosing a save path.
6. Generate only the needed assets with `gpt-image-2`, defaulting to transparent background.
7. Review generated or existing visuals for AI-heavy artifacts before integration.
8. Integrate only assets that improve the page. If an asset is weak, refuse or mark it for replacement instead of forcing it into the UI.

## Required Decisions

Always make these decisions explicitly:

| Decision | Requirement |
| --- | --- |
| Page fit | Decide whether the page actually benefits from imagery or should be improved through layout, spacing, hierarchy, and color only. |
| Asset type | Decide whether the needed asset is decorative, character-based, icon-like, functional, or mixed. |
| Replacement | Decide whether an existing asset should be kept, replaced, or removed. |
| Save path | Decide the final asset directory by using the user path or probing the project. |
| Integration | Decide whether the asset is production-ready, temporary, or should not be integrated. |

## Stop And Ask The User If

- The provided image does not match the claimed page.
- The page purpose is unclear.
- Multiple style directions are equally valid but imply materially different implementations.
- The page is too dense or functional to benefit from added imagery.
- The project structure is too ambiguous to choose a trustworthy save path.
- The reference styles conflict strongly with the existing product language.
- The required asset would be a full-scene background image but the user has not confirmed that exception.

## Save Path Rules

1. If the user gives a directory, use it.
2. Otherwise inspect the project for nearby `assets`, `images`, `icons`, `illustrations`, `media`, or feature-local asset folders.
3. If one clear convention exists, use the closest matching directory automatically.
4. If conventions are unclear, recommend 2-3 candidate directories and ask the user.
5. Only fall back to a generic generated-assets directory when no reliable convention exists.

When probing paths, prefer the directory closest to the target page or feature instead of a global folder unless the project already centralizes all assets.

## Generation Rules

Default to assets that are easy to place inside a UI rather than full scenes.

Always bias prompts toward:

- transparent background
- no background
- isolated subject
- clean edges
- UI-ready asset
- high readability on web pages

Only drop the transparent-background default if the user explicitly wants a full-page or full-section background visual.

Use the templates in `prompt-templates.md` when forming `gpt-image-2` prompts.

## Asset Review Rules

Before integration, explicitly check for:

- dirty or unstable edges
- generic AI look or template-like glow-heavy styling
- broken anatomy or malformed details
- unclear icon semantics
- visual mismatch with the page’s existing language
- assets that reduce trust or readability

Classify each asset as:

1. Use directly
2. Temporary, replace later
3. Do not integrate

Use the checklist in `asset-review-checklist.md` before integrating or recommending replacement.

## Integration Boundaries

- Prefer minimal page edits.
- Prefer hero, empty-state, card-header, side-panel, helper-visual, or supportive illustration placements.
- Do not force imagery into dense tables, serious data-entry zones, or already crowded tools.
- If imagery is the wrong solution, improve layout, spacing, hierarchy, and color instead.
- Respect the project’s existing frontend structure and style conventions.
- If the user explicitly points to a placement that must change, prioritize that over AI-suggested placements.
- If the user explicitly says an area must not change, leave it alone.

## Output Shape

Prefer reporting results in this structure:

1. `Page Analysis`
2. `Style Direction`
3. `Asset Plan`
4. `Path Decision`
5. `Integration Result`
6. `Replacement Notes`

## Common Mistakes

| Mistake | Fix |
| --- | --- |
| Stopping at design advice | Continue into save-path selection, generation, review, and integration when the user expects implementation. |
| Hard-coding a generic asset directory | Probe the project first and use the nearest stable convention. |
| Generating scene images by default | Prefer transparent-background UI-ready assets unless the user explicitly wants a background scene. |
| Integrating weak AI-looking visuals | Mark them temporary or refuse integration. |
| Forcing imagery into functional screens | Choose layout and hierarchy improvements instead. |
