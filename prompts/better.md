---
description: Rewrite a task or plan request into a deeper, repo-grounded prompt using Felix Rieseberg's Depth prompt
argument-hint: "[task or plan request]"
---
First, without asking me anything, find and read the code, files, docs, and logs this touches, so your answers rest on them. Keep searches quick and targeted. Do not start the work itself or modify any files.

I want a deeper version of this task/plan request, not a bigger one:
${@:-(no prompt given; use the task or plan currently in progress in this conversation)}

Before rewriting it:
1. Say what a top professional in this field would do here that I am not asking for.
2. Name the rawest material they would start from instead of what has already been digested for me.
3. Name the specific methods and tools they would use.
4. Say what, other than you or me, would show the result is right.

Then rewrite my prompt to ask for exactly that, grounded in the real files, symbols, commands, and checks you found. Output the 4-point analysis briefly, followed by the ready-to-send rewritten prompt.
