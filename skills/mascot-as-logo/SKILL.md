---
name: mascot-as-logo
description: Generate highly simplified personified IP mascot logos with Flat-first geometry, rounded heavy forms, two IP colors plus one background color by default, and continuous-gradient neo-skeuomorphic micro-volume. Use when creating an animal, creature, robot, ghost, plant, object, or other character as a minimal square logo or app-icon artwork, including when the agent should infer three product-relevant directions and propose six independent candidates for approval.
---

# Mascot as Logo

Create a logo first and a character second. Reduce the subject to a compact symbol that remains recognizable at `32 × 32`; do not produce a character illustration.

## Workflow

1. Parse the request for an explicit IP subject and available product context. Do not ask the user to choose a color mode unless they explicitly want to control it.
2. When the user has not specified an IP subject and the current workspace is a product repository, inspect relevant read-only context before asking questions. Prefer the README, product docs, package or app metadata, landing-page copy, manifests, and design tokens. Treat context as sufficient when the product purpose, primary audience, and intended personality can be inferred with reasonable confidence.
3. When product context is insufficient, ask one consolidated round of background questions covering what the product does, who it serves, and how it should feel. Do not start a second background questionnaire. Continue with the best supported interpretation after the answer.
4. Once context is sufficient, always present three concise directions before generation and explicitly propose generating six independent logo candidates in one batch. Do not generate until the user agrees, unless the current request already explicitly authorizes six outputs or asks the agent to proceed without another confirmation.
5. Choose the three proposed directions deliberately:
   - When the user explicitly specifies an IP subject, keep that subject and propose three distinct design treatments based on composition, silhouette treatment, secondary color region, or personality emphasis.
   - When the user does not specify an IP subject, propose three genuinely different IP subjects or metaphors. Tie each one to a different product attribute or brand promise; do not return three arbitrary animals with no rationale.
6. Interpret the user's response exactly:
   - If the user accepts all three directions and the six-image proposal, generate two independent variants per direction and label them `A1`, `A2`, `B1`, `B2`, `C1`, and `C2`.
   - If the user selects one direction but accepts six images, generate six controlled variants of that direction and label them `A1` through `A6`.
   - If the user rejects the proposed quantity, directions, or distribution, follow the user's replacement instructions without arguing for the default.
7. Default every generated candidate to three semantic colors in total: two IP colors plus one background color. Do not reserve any fraction of the batch for two-color logos. If the user explicitly specifies another color count, follow it instead. Keep required product cues, identifying features, complexity limits, and any supplied palette consistent enough for useful comparison.
8. Determine the available image-generation path before promising output. In Codex, use ImageGen when it is available. In any other agent environment, use an available configured image generator; if none is available, ask the user whether they can provide or enable one. Do not fabricate generated results.
9. If the runtime supports subagents, parallelize the six independent candidates up to the available concurrency. Give every subagent the same product brief, shared constraints, and one assigned direction or variant; run remaining candidates in subsequent waves when capacity is limited. If subagents are unavailable, generate the candidates through separate image-generation calls or jobs.
10. If the user supplies a background palette, reserve every supplied color for backgrounds unless they explicitly say otherwise. Keep the two IP base colors distinct from the background. When the user explicitly requests a two-color logo, allow the background color to reappear only as negative-space facial cutouts, not as a separate painted IP region.
11. Abstract each subject using the complexity budget below. Generate every candidate as a separate full-resolution square asset; never ask an image model to compose a contact sheet, grid, or multi-logo image. Do not use existing logos or sibling candidates as image references when testing prompt-only reproducibility.
12. Inspect every output against every evaluation rule. Retry with one targeted correction when practical; never hide a failed constraint with silent post-processing. Treat a transparent or absent background as an allowed output variation unless the user explicitly requires an opaque background.
13. Preserve and label every generated result, whether its background is opaque or transparent. Report every label, IP direction and rationale, saved path, prompt/color mapping, dimensions, background mode, and remaining deviations. Present all results together and ask which candidate the user wants to refine.

When proposing directions before generation, describe each in one compact line: `<IP subject> — <product connection> — <defining silhouette>`. End with a direct proposal to generate six images using the distribution above. Do not turn the discovery phase into a long branding workshop unless the user asks for one.

## Complexity budget

- Build one dominant continuous outer silhouette from roughly `6–10` basic geometric shapes.
- Use at most one species-defining feature: for example, one large pouch beak, one pair of curled horns, or one broad visor.
- Use at most two internal color regions. Keep the face to two eyes and one mouth; omit eyebrows, highlights, nostrils, texture, and decorative marks unless essential.
- Prefer a head or compact upper-body crop. Do not explain the full anatomy, costume, machinery, or story.
- Remove repeated feathers, scales, fur tufts, armor plates, buttons, screws, numbers, labels, and other illustrative detail.
- Require a readable black silhouette and recognizability at `32 × 32`.

## Shape language and composition

- Use thick, rounded, weighty contours and broad color masses.
- Forbid sharp corners, pointed ears or beaks, needle-like tails, thin antennae, thin smiles, narrow gaps, and acute flame or feather tips. Replace every necessary tip with a visibly blunt rounded end.
- Show both members of paired identifying features, such as ears, horns, wings, gills, or bells.
- Let the IP emerge from the lower-left or lower-right corner and fill about `75–85%` of the canvas. Cropping at the bottom or side is intentional, but do not crop an identifying paired feature.
- Keep the artwork upright; never rotate the logo canvas or tilt the main mark without an explicit request.

## Flat-first geometry, continuous-gradient micro-volume

- Build the logo from flat semantic shapes first. Keep every IP color region as one continuous base shape with one readable outer silhouette.
- Model depth only with one uninterrupted, low-frequency diffuse gradient inside each large IP color region. Never represent lighting as an additional shape, swatch, patch, band, or layer.
- Use one shared default light direction from the upper-left toward the lower-right. Keep the gradient axis coherent across the head, ears, body, and secondary color region; do not light each part independently.
- Make each tonal transition span at least `50%` of the dominant form's width. Keep any local highlight area broader than roughly `20%` of that form; reject small glossy hotspots.
- Keep the gradient inside the original semantic color family. Relative to the base color, limit OKLCH hue drift to about `3°`, chroma drift to `0.015`, highlight lightness to `+0.025–0.04`, and shadow lightness to `-0.03–0.05`. Keep total peak-to-peak lightness variation at or below `0.08`.
- Keep small facial marks nearly flat. Allow only the same broad global illumination already affecting their parent region; do not give eyes, mouths, noses, or tiny details separate highlights or shadows.
- Allow shallow contact darkening only as a soft continuation of the same gradient where two large regions meet. Never create a closed contact-shadow blob, a second internal contour, or an ambient-occlusion seam.
- Keep the background visually flat. Apply continuous tonal modeling only inside the IP, never as a vignette, spotlight, or directional background gradient.
- Make the micro-volume visible at full resolution but almost disappear at `32 × 32`, leaving only the flat silhouette and semantic color regions.
- Keep the finish clean and softly dimensional. Use the broad continuous gradients above to create restrained micro-volume while preserving the clarity of the underlying flat geometric shapes.

## Color and canvas

- Default to exactly three semantic colors in the finished logo: two IP base colors plus one background color. Reuse one IP color for facial marks and keep the second IP color in one large continuous region. Do not mix in a default quota of two-color candidates.
- Treat the two IP base colors as color families, not mechanically uniform flat swatches. Closely related values created by the continuous-gradient micro-volume rules above do not count as additional semantic colors.
- Use more than three semantic colors only when the user explicitly requests them. Use a two-color logo only when the user explicitly requests it: exactly one IP base color plus one background color, with eyes and mouth formed as negative-space cutouts that reveal the background.
- Prefer a warm off-white such as cream or parchment over pure white, and charcoal or deep navy over pure black. Use pure black or white when the user requests it or when it provides the clearest result.
- Prefer backgrounds with a clear hue and restrained saturation: terracotta, muted coral, dusty plum, sage or forest green, glaucous or denim blue, ochre, and similar softened colors. Avoid neon, electric, candy-bright, and primary-color intensity unless explicitly requested. Also avoid reducing chroma until the color reads gray, muddy, or lifeless.
- Evaluate color in OKLCH when numeric control is available; do not use HSL saturation as the primary quality test. Use these default target bands:
  - chromatic mid-tone background: `L 0.45–0.75`, `C 0.08–0.16`;
  - dark chromatic background: `L 0.18–0.35`, `C 0.05–0.14`;
  - cream or parchment background: `L 0.92–0.98`, `C 0.01–0.06`.
- Treat `C < 0.05` on a chromatic background as likely too gray and `C > 0.20` as likely too saturated. These are defaults, not overrides for a user-supplied color.
- Maintain at least `3:1` relative-luminance contrast between the dominant IP silhouette and the intended background, and at least `4.5:1` between small facial marks and the surface beneath them. If the requested palette misses these targets, preserve the requested background and adjust the IP colors first. For a transparent result, report background contrast as dependent on its eventual placement rather than treating it as a failure.
- Build the second IP base color from a large continuous region such as a face mask, hat, shell, belly, or visor. Do not scatter it into small decorative patches.
- Do not introduce an unrelated hue under the label of shading. Do not quantize a continuous gradient into several neighboring flat swatches or count layered light and dark patches as acceptable color-family variants.
- Keep an opaque background visually solid. Across unobstructed background areas, target no more than about `0.02` OKLCH lightness variation and `0.01` chroma variation; report visible vignettes or directional gradients rather than silently flattening them in post-processing.
- Request a fully opaque, edge-to-edge background by default. Keep the selected background visibly present in all four corners and every open area around the IP, with normal square outer corners. Preserve and report a transparent result when the generator returns one.
- Generate a direct `1:1` square with square outer corners. Request approximately `1536 × 1536`; accept and preserve a native `1254 × 1254` result when that is the service output limit. Never resample merely to reach the requested number.

## Prompt skeleton

### Route constraints by generator capability

Determine the available image model and its actual tool schema from runtime metadata, configured provider documentation, or an explicit user statement. Do not guess a model or invent unsupported parameters.

- For modern instruction-following image models such as GPT Image 2, Nano Banana Pro, and Seedream 5.0 Pro, keep the complete positive prompt and express the minimal exclusions as the natural-language `Constraints:` line inside the main prompt. Do not create a separate negative-prompt payload for these models.
- For an older model or runtime that explicitly exposes a dedicated parameter such as `negative_prompt`, keep every positive prompt line unchanged and deliver the minimal exclusions through that dedicated parameter in the syntax required by the available adapter. Omit the natural-language `Constraints:` line from the main prompt to avoid duplicating the same exclusions in both channels.
- For an older model without a dedicated negative-prompt parameter, follow its documented prompt format. When only one prompt string is available, retain the concise natural-language `Constraints:` line.
- Record the model or provider, the detected constraint-delivery mode (`main-prompt constraints` or `dedicated negative parameter`), and the exact constraint text or payload in the generation report.

When a dedicated legacy negative-prompt parameter is available, adapt this minimal payload to its required syntax:

```text
text, watermark, borders, frames, cards, App-icon masks, extra subjects, scenery, thin fragile lines, sharp tips, photorealistic materials, strong three-dimensional rendering, external cast shadows
```

For modern instruction-following models and single-prompt interfaces, use the following complete prompt:

```text
Create one complete full-bleed 1:1 square IP mascot logo artwork.
Backdrop: cover the entire canvas with one visible, fully opaque solid <background>. Keep <background> clearly visible in all four square corners and every open area surrounding the mascot.
Subject: place one highly simplified <subject> mascot over the backdrop, reduced to one rounded continuous silhouette and one defining feature.
Complexity: use 6–10 broad basic shapes, at most two internal color regions, and a face with two eyes and one mouth. Keep the symbol readable at 32 × 32.
Color count: use exactly three semantic colors in the complete artwork: two IP base colors plus the backdrop color. Reuse one IP color for facial marks and keep the second IP color in one large continuous region.
Color behavior: choose a softened but clearly chromatic backdrop, with warm off-white and charcoal or deep navy as preferred neutrals. Maintain silhouette-to-backdrop contrast of at least 3:1 and facial-detail contrast of at least 4.5:1. Treat continuous same-family tonal variation as modeling within each selected IP base color.
Composition: keep the mascot upright, emerging from the lower-left or lower-right, filling 75–85% of the square, with both paired identifying features visible.
Style: use Flat-first geometry with gentle continuous-gradient micro-volume. Apply one uninterrupted, low-frequency, same-family gradient inside each large IP color region, sharing one upper-left-to-lower-right light direction. Make each transition span at least 50% of the dominant form. Keep total OKLCH lightness variation at or below 0.08, hue drift within 3 degrees, and chroma drift within 0.015. Keep the backdrop visually uniform and let the tonal modeling become subtle at icon size.
Finish: show only the mascot over the full-canvas backdrop, with clean geometric surfaces and normal square outer corners.
Constraints: Use no text or watermark. Add no borders, frames, cards, or App-icon masks. Include one mascot only, with no extra subjects or scenery. Keep the contours thick and rounded, without fragile lines or sharp tips. Keep the finish graphic and softly dimensional, without photorealistic materials, strong three-dimensional rendering, or external cast shadows.
```

## Mark as non-recommended when

- It reads as an illustration rather than a symbol, exceeds the complexity budget, or fails at small size.
- The IP does not contain the requested number of base colors; the second IP color is scattered into decorative patches; shading introduces an unrelated hue; or an explicitly requested two-color logo adds a separate facial-feature color. An absent backdrop color in a transparent result is an allowed variation.
- A background-only color appears as a painted IP region rather than a negative-space cutout.
- An opaque default chromatic background is neon or candy-bright, or is desaturated until it reads gray or muddy; small facial marks lack clear contrast.
- Any contour is thin, sharp, spiky, or visually fragile.
- An ear, horn, wing, gill, bell, or other paired identifier is missing or cropped.
- The IP is too small, centered like a sticker, tilted, framed, or surrounded by excessive empty space.
- A highlight or shadow has its own closed contour, abrupt edge, or readable shape instead of flowing continuously through the base color region.
- Tonal modeling divides one semantic color into stacked layers, overlay bands, cel-shaded steps, or several neighboring flat swatches.
- A gradient changes direction between adjacent parts, transitions across less than half of the dominant form, or creates a small glossy hotspot.
- At `32 × 32`, the tonal modeling still reads as an extra color region instead of nearly disappearing.
- The result lacks the requested gentle gradient modeling or becomes noticeably volumetric instead of subtly modeled.
- An opaque background visibly becomes a scene, texture, halo, vignette, or strong gradient rather than reading as a solid field.

Background transparency by itself is permitted and must not make a result non-recommended. State the exact evaluation findings for every candidate, preserve both opaque and transparent results, and present them together without silently repairing either mode with code.
