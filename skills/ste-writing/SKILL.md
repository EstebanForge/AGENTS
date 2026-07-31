---
name: ste-writing
description: Rewrite technical prose into ASD-STE100 Simplified Technical English to remove AI slop and ambiguity. Use when the user asks to make docs, READMEs, PR text, error messages, release notes, tool descriptions, or comments clear, plain, or unambiguous. Also use it to enforce a controlled writing style, or to make text safe for a reader who cannot ask a follow-up. Two modes, strict (procedures, safety, error messages) and STE-flavored (general technical prose). STE strips voice on purpose, so route marketing, essays, and anything that needs a voice to the humanizer skill.
---

# ste-writing

ASD-STE100 is a controlled language the aerospace industry built so a maintenance technician cannot misread an instruction. The reader has no back-channel. A misread torque spec can kill someone. The standard removes the two causes of misread text: a word with more than one meaning, and a sentence with more than one structure.

An agent that parses another agent's output is the same reader. It cannot ask "did you mean X or Y?" The same rules that protect a mechanic protect a downstream agent from a misread tool description, error message, or instruction. This skill applies those rules to remove "AI slop" from technical prose.

STE applies to prose. It does not apply to code, identifiers, or command syntax. It strips voice on purpose. Do not use it for marketing copy, essays, or anything that needs a voice. Route that work to the humanizer skill, which keeps and adds voice.

## Rules

| Rule | Do | Do not |
|---|---|---|
| One word, one meaning | Pick one verb for one action and reuse it. Always "check", never mix check, verify, and confirm for the same action. | Rotate synonyms for the same idea. |
| One part of speech | "Apply oil to the valve." (oil as a noun) | "Oil the valve." when oil is approved only as a noun. |
| Plain common word | start, use, help, make sure, before, after, about, get, show, also | begin, commence, initiate, utilize, leverage, facilitate, ensure, prior to, subsequent to, regarding, obtain, demonstrate, additionally, furthermore. |
| Active voice | "The parser reads the file." | "The file is read by the parser." (passive only in description, when the actor is unknown or irrelevant) |
| Simple tense | "We received the report." | "We have received the report." (no present perfect or other compound tense) |
| One verb per action | "Analyze the log." | "Perform an analysis of the log." (no nominalization, no stacked auxiliaries) |
| No -ing main verb | "This improves the result." | "It is important to note that this may help to improve." |
| Sentence length | 20 words max for an instruction, 25 for a description | Long compound or subordinate-clause sentences |
| Noun cluster | Max 3 nouns stacked: "fuel pump valve" | 4 or more nouns in a stack |
| No ellipsis | Keep the subject, verb, and article explicit | Drop words to save space (this makes ambiguity, not clarity) |
| Punctuation | Write two sentences | Use a semicolon. Use an em dash (repo rule). |
| Contractions | Expand them: do not, it is | don't, it's |
| Marketing adjectives | Describe the thing | seamless, robust, powerful, cutting-edge, effortless, revolutionary |
| Paragraph | One topic, 6 sentences max | Multi-topic paragraphs |
| Sequence | Numbered list, one imperative action per item, condition before command | Bury a sequence inside one sentence |
| Spelling | American | British |
| Domain term | Keep a necessary technical noun or verb, and define it once | Use jargon without a definition |

## Modes

- **strict** for procedures, runbooks, safety text, and error messages. Apply every rule and both length caps.
- **STE-flavored** for general technical prose such as READMEs and PR descriptions. Apply the sentence, paragraph, active-voice, word-choice, and no-phrasal-verb discipline. Relax the dictionary lockdown so the text keeps enough range to read naturally.

## Process

1. Read the input once for meaning. Do not rewrite before you know what it must still say.
2. Walk it sentence by sentence. Flag each rule it breaks: word, tense, voice, length, cluster, ellipsis.
3. Rewrite each flagged sentence to fix the break and keep every fact, condition, number, and scope qualifier. If a shorter phrasing would drop a needed precision, keep the longer phrasing and flag the trade-off. Do not simplify a safety condition away.
4. Apply the mode the task asked for.
5. Run the lint gate below before you return the text.
6. If the input already complies, say so. Do not force changes onto clean text.

## Lint gate

Before you return the text, every item below must pass.

- No sentence over the word cap for its mode.
- No semicolon. No em dash.
- No contraction.
- No passive voice where you know the actor.
- No -ing main verb, no nominalization ("perform an analysis"), no phrasal verb ("spin up").
- One name for one thing, used the same way each time.

For a machine score, run the bundled linter:

```
python3 ste-lint.py your-draft.md
```

The score is violations per 100 words. Lint the draft, apply the skill, then lint again. The delta between the two scores is the signal. The full banned-word, marketing-adjective, and phrasal-verb lists live in `ste-lint.py` as the single source of truth. This file lists only the highest-signal examples.

A checker cannot certify a real STE document. It fixes the form of slop. It cannot make a hollow paragraph true. The judgment rules of ASD-STE100 (the right technical noun, whether a sentence makes good sense) still need a human.

## Boundaries

**Will:**
- Rewrite dense or ambiguous English into short, single-meaning, active-voice sentences.
- Flag the rule before each rewrite.
- Keep every fact, condition, and scope qualifier in the original.
- Suggest a one-line glossary entry for a domain term that must stay.

**Will not:**
- Apply to code, identifiers, or command syntax.
- Apply to marketing, essays, or anything that needs a voice (route to humanizer).
- Silently drop a safety condition, exception, or scope qualifier to shorten a sentence. Flag the trade-off instead.
- Certify an aerospace-grade STE document. This is a general-purpose clarity tool inspired by STE.

## References

- `WRITING-RULES.md` for the history of STE, the 9-section rule structure, why STE fits agent output, and source citations.
- `EXAMPLES.md` for before-and-after rewrites of the official STE rules and of agent output.
- The official standard is free at <https://www.asd-ste100.org/>. It is copyrighted, so do not paste it in full.
