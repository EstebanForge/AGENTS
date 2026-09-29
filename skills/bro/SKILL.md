---
name: bro
description: Restate the last message in plain human language, with no jargon.
disable-model-invocation: true
---

# bro

Restate your previous message as one human engineer speaking to another. Strip out all corporate jargon, buzzwords, AI boilerplate, and convoluted prose. Make it simple, direct, and to the point.

## Rules

1. **Cut the length**: Reduce word count by at least 50%. Keep only the core point and necessary facts.
2. **Zero throat-clearing**: Do not say "Sure", "Certainly", "Here is what I meant", or "To put it simply". Start immediately with the answer.
3. **No corporate or AI jargon**: Never use words like delve, landscape, tapestry, robust, seam, seamless, cutting-edge, transformative, pioneering, leverage, utilize, facilitate, foster, showcase, underscores, holistic, multifaceted, interplay, nuances, comprehensive, crucial, pivotal, in today's world, it's important to note, ultimately, moreover, or furthermore.
4. **Translate to plain everyday words**:
   - `utilize` or `leverage` -> `use`
   - `facilitate` or `enable` -> `let`, `help`
   - `remediate` -> `fix`
   - `initiate` or `commence` -> `start`
   - `terminate` -> `stop`, `kill`
   - `demonstrate` -> `show`
   - `obtain` -> `get`
   - `ensure` -> `make sure`
   - `in order to` -> `to`
   - `aforementioned` -> drop it
   - `comprehensive` -> `full`, `complete`
   - `crucial` or `pivotal` -> `key`, `needed`
5. **No em dashes**: Never use em dashes. Use commas, periods, or parentheses.
6. **Active voice and natural contractions**: Use active voice. Contractions like `it's`, `don't`, and `can't` sound human and are encouraged.
7. **No decorative structure**: Do not create elaborate bulleted hierarchies when 1 or 2 clear sentences do the job.

## Examples

### Example 1: Explaining a bug or failure

**Jargon / AI prose:**
> It is important to note that we observed a memory exhaustion issue. By leveraging asynchronous stream processing, we can facilitate a robust data pipeline and seamlessly mitigate the bottleneck.

**Plain human:**
> The process ran out of RAM because it buffered the whole file at once. Streaming the data chunk by chunk fixes it.

### Example 2: Architecture or design feedback

**Jargon / AI prose:**
> Our comprehensive analysis underscores that the present service landscape exhibits multifaceted coupling, necessitating a transformative refactoring to foster separation of concerns.

**Plain human:**
> These two services are tangled together. Splitting the auth check into its own function untangles them.

### Example 3: Status and next steps

**Jargon / AI prose:**
> Furthermore, in order to ensure optimal alignment with stakeholder requirements, we will commence the implementation phase subsequently.

**Plain human:**
> Tests pass. Starting the implementation next.
