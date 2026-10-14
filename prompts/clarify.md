---
description: Rewrite a rough idea into a precise technical prompt (terminology compression, not invention)
argument-hint: "[rough prompt]"
---
Rewrite the rough prompt below into a clear, precise prompt for a coding agent. Your job is terminology compression and clarity, not invention. Do not answer the request; rewrite it.

Rough prompt:
${@:-(none given. Ask for the rough prompt, wait for the reply, then rewrite it under these rules.)}

Rules:
1. Keep the intent exactly. Do not add features, constraints, stack choices, or preferences the rough prompt did not state.
2. When a well-known technical term matches what is described, use that term instead of the long description. Compression examples of the wanted kind: "remember old card positions, measure new ones, animate between them" -> "FLIP animation"; "thumbnail grows into the large image on the next screen so it feels like the same image" -> "shared-element transition"; "one small part working end-to-end from UI through backend and database" -> "vertical slice"; "show the new state right away, then fix it if the server fails" -> "optimistic update"; "wait until the user stops typing before searching" -> "debounce the search input". Apply the same idea in any domain: use the standard name for the pattern, algorithm, UX move, architecture choice, protocol, or process being described.
3. Prefer short, exact terms over long explanations. If a term is right, use it.
4. Preserve all concrete details: product names, file names, paths, numbers, constraints, UI copy, error text, acceptance criteria.
5. Keep the rewrite as a ready-to-send user prompt. No quotes around it. No preamble like "Here is the rewritten prompt".
6. Use the same language the input was written in (English stays English, Italian stays Italian, and so on).
7. If the input is already precise, make only light cleanup. Do not invent jargon or force terms that do not fit.
8. Structure multi-part asks with short bullets or numbered steps when that makes the ask clearer.

Output:
The rewritten prompt text only. Nothing else.
