# ASD-STE100 writing rules: history, structure, and sources

This file holds the background the skill does not need on every run. It summarizes the public, official description of ASD-STE100. It paraphrases rule categories. It does not reproduce the standard text or its dictionary word for word. For the authoritative document, request the free download at the official site.

## What ASD-STE100 is

ASD-STE100 is a controlled natural language, first released in 1986 as AECMA Document PSC-85-16598 by what is now ASD, the AeroSpace and Defense Industries Association of Europe. European airlines asked for it. Most of their staff were not native English speakers. They needed maintenance documentation that could not be misread, because a misread instruction on an aircraft can kill people. The Simplified Technical English Maintenance Group maintains the standard. It has been free to download since Issue 6, in 2013. The current edition is Issue 9, from January 2025.

## Structure

- 53 writing rules across 9 sections. They cover word choice, grammar, sentence structure, and style.
- A dictionary of about 900 approved words. Each word is restricted to one meaning and one part of speech.
- About 1,200 words to avoid, with suggested replacements.
- A terminology allowance. An organization may define its own approved technical nouns and verbs beyond the base 900, for domain vocabulary the base dictionary cannot cover.

## Rule categories, paraphrased

**Word choice**
- Use an approved word only in its approved meaning and part of speech.
- Each word maps to exactly one meaning. Do not rely on context to disambiguate a word that has several dictionary senses.
- Prefer the plainer, shorter, more common word over a formal or rare synonym.

**Verb forms**
- Permitted forms: infinitive, imperative, simple present, simple past, simple future, and past participle used only as an adjective.
- No present perfect, past perfect, or other compound or auxiliary construction. "We have received" is not allowed. "We received" is.
- An "-ing" form is permitted only as a technical noun or as part of one, not as a verb form.

**Voice**
- Active voice is required for procedures and instructions.
- Passive voice is allowed only in descriptive text, and only when the actor is genuinely unknown or irrelevant.

**Sentence structure**
- One instruction per sentence.
- About 20 words max per sentence for procedures and instructions, 25 for descriptive text.
- Do not omit a sentence part (verb, subject, article) just to shorten the sentence. The standard warns that this creates ambiguity rather than clarity.
- A noun cluster (a string of nouns stacked as a modifier) is capped at 3 words.

**Paragraph and document structure**
- One topic per paragraph.
- About 6 sentences max per paragraph.
- Use a vertical list (numbered or bulleted) for a sequence, a set of conditions, or a complex enumeration instead of burying it in prose.

**Safety instructions**
- A safety-critical instruction must open with a clear command or condition. It must not sit in the middle of a sentence.

## Why STE fits agent output

STE was built for a reader who cannot ask a follow-up question: a technician on a tarmac, working from a manual, with no author to call. An AI agent that parses another agent's output, a tool description, or a system message is in the same position. It has no back-channel to resolve "does this passive-voice sentence mean the caller does X, or the callee does X?" The rule set that protects an airline mechanic from a misread torque spec protects a downstream agent from a misread instruction.

## Sources

- [ASD-STE100 official site](https://www.asd-ste100.org/)
- [ASD-STE100: About STE](https://www.asd-ste100.org/about_STE.html)
- [ASD Europe: Simplified Technical English](https://www.asd-europe.org/standards-specifications/simplified-technical-english/)
- [Simplified Technical English on Wikipedia](https://en.wikipedia.org/wiki/Simplified_Technical_English)
- [TechScribe: ASD-STE100 Simplified Technical English](https://www.techscribe.co.uk/techw/asd-simplified-technical-english.htm)
- [SKYbrary: Simplified Technical English (STE)](https://skybrary.aero/articles/simplified-technical-english-ste)
