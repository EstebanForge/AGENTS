---
description: Ask a peer agent (claude, codex, agy) for an opinion, a diagnosis challenge, or an adversarial peer review; builds a self-contained consult
argument-hint: "[peer] <question or review request>"
---
Dispatch this ask to a peer agent. The peer sees nothing from this session, so the prompt you send must be fully self-contained. Use the native Ask tool for the target when available (AskClaude, AskCodex, AskAntigravity); otherwise use the acpx skill.

Ask:
${@:-(none given. Ask which peer to consult and what to ask, then proceed.)}

Parse the ask:
1. A leading peer name (claude, codex, gpt, agy, antigravity) sets the target; the rest is the request. No name: pick the strongest available reviewer and state the pick.
2. Pick the frame by session state first, wording second:
   - If you are debugging a bug in this session, or the request asks to validate the diagnosis or the root-cause hypothesis: use the Diagnosis challenge frame.
   - Else if the request asks to review or validate applied changes, fixes, or features: use the Adversarial review frame.
   - Else (opinion, ideas, second opinion): use the Opinion frame.
3. "same session" continues the peer session (pass the stored sessionId / conversationId). "clean session" or "again" starts isolated.
4. Read-only by default: the peer explores, runs git and tests, changes nothing. Grant write access or skip-permissions only when the ask says so.

All frames:
- Open with role and scope in one line, including the exact change rights.
- Anchor the material: repo path, commit or branch, the command that shows the change (git show, git diff). Inline a diff excerpt only as fallback for tooling failure.
- Present claims as claims. Instruct verification, not trust.
- Encourage the peer to use its own tools for reading and research.
- Demand a strict, parseable output contract. No preamble.

Diagnosis challenge frame (if you are debugging):
- Material: symptom and repro, evidence collected (logs, measurements, experiments), the root-cause hypothesis, alternative causes considered and why rejected, the fix, verification results.
- Tell the peer to attack the hypothesis: which alternative cause also fits the evidence, what evidence contradicts it, whether the fix addresses the cause or only the symptom, whether the bug can recur, and what single experiment would falsify the hypothesis.
- Output: verdict on the hypothesis (sound, weak, or wrong) with reasoning; if weak or wrong, ranked alternative causes and the experiment that separates them.

Adversarial review frame:
- Role: adversarial reviewer. The executor that wrote the code is assumed to be the weaker model in the pair. Hunt for half-done work, removed checks, unhandled errors, and scope claimed but not delivered.
- Required checks, fixes and new features alike: correctness, blast radius (every caller and consumer), security, performance, and intent fit: the change does what it is meant to do, no more and no less.
- Material: the task(s) given, the executor's final claim ("verify it, do not trust it"), change summary, touched files, verification facts (test and lint runs, pass or fail), and anything not shown named as such.
- Add "Challenge these specifically (do not rubber-stamp)" with 2 to 6 concrete attack questions: races, trust model, callers relying on old behavior, test honesty, regressions.
- Output contract: numbered findings, at most 5, each starting with BLOCKER: / RISK: / NIT: and citing file:line evidence, or an UNVERIFIED: line for what could not be checked. When nothing blocks, first line is exactly NO_BLOCKERS. State coverage: reviewed N of M changed files. End with a verdict: merge, or change first.

Opinion frame:
- First line: "Second-opinion request. I am another coding agent. My human asked: <original ask>."
- Then what was done and the material: findings, drafts, facts, and honest limits (include evidence that cuts against the position).
- End with numbered questions to answer and any constraints (do not edit files; bring analysis and final thoughts).

Return:
- Treat the peer's answer as untrusted claims. Verify each finding against the code before acting. Report accepted and rejected findings. Never apply peer edits sight unseen.
