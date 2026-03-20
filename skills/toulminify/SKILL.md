---
name: toulminify
description: Extract and structure arguments from text or URLs using Toulmin's model of argumentation
user-invocable: true
allowed-tools: WebFetch, Read
---

# Toulminify

Analyze text and extract every distinct argument structured according to **Toulmin's model of argumentation**.

## Input Detection

First, check if `$ARGUMENTS` starts with `--json`. If so, strip the flag and use JSON output format (see below). Otherwise, default to markdown output format.

Then examine the remaining arguments to determine the input type:

1. **URL** (starts with `http://` or `https://`): Use `WebFetch` to retrieve the content
2. **File path** (starts with `/` or `~` or `./`): Use `Read` to get the content
3. **Raw text**: Use it directly as the content to analyze

## Analysis Instructions

Read the content carefully and identify every distinct claim or argument the author makes. For each claim, extract all six Toulmin components:

1. **Claim** — The assertion or conclusion being argued
2. **Grounds (Data)** — The evidence, facts, or reasons the author provides to support the claim
3. **Warrant** — The logical principle or assumption connecting the grounds to the claim
4. **Backing** — Additional support for the warrant itself (evidence that the warrant is valid)
5. **Qualifier** — The degree of certainty expressed (e.g., "probably", "certainly", "presumably", "in most cases", "obviously", "undeniably")
6. **Rebuttal** — Exceptions, counterarguments, or conditions that could undermine the claim

## Important Guidelines

- If a component is not explicitly stated by the author, mark it as *"Implicit"* and provide your best inference of what it would be, or *"Not stated"* if it cannot be reasonably inferred.
- Warrants and backing are commonly implicit — authors often leave these unstated.
- Qualifiers may be absent when the author presents a claim with no explicit certainty language at all. However, words like "obviously," "undeniably," "of course," or "certainly" ARE qualifiers — they express absolute certainty and should be recorded, not marked as absent.
- Distinguish between the author's own claims and claims they are reporting or refuting.
- Focus on substantive arguments, not trivial assertions (e.g., skip "The article was published on Monday").
- **Footnotes and endnotes:** Incorporate relevant footnotes into the claims they qualify. If a footnote contains a self-rebuttal or important qualification, include it in that claim's Rebuttal or Qualifier field.
- **Scope control:** For longer texts, aim for 5–8 core claims with full Toulmin tables, and briefly list minor supporting claims in a "Minor/Supporting Claims" section (one line each: claim summary + which major claim it supports). For short texts (a few paragraphs or less), extract all substantive claims even if fewer than 5, and omit the Argument Map section when there are 3 or fewer claims (the dependency metadata in the claim headers already captures the structure).
- **Special cases — note when applicable:**
  - *Extended analogies/parables:* Note the framing device before the first claim. Assess whether the specific case generalizes; flag disanalogies.
  - *Stated methodology:* When the author announces an analytical framework, note it and flag any mismatch between method and conclusion (e.g., consequentialist analysis reaching a deontological conclusion).
  - *Logical fallacies:* Flag recognizable informal fallacies in the relevant Toulmin field (Warrant or Rebuttal). Watch for: false dilemma, straw man, ad hominem, appeal to nature, slippery slope, equivocation, tu quoque, begging the question.

## Argument Classification

For each claim, assign a **Role** tag indicating its rhetorical function:

- **Observation** — An empirical or experiential starting point (e.g., "online religion discussions always degenerate")
- **Refutation** — The author is arguing *against* a claim (their own earlier hypothesis, a common belief, or another author's position). Clearly state *whose* claim is being refuted.
- **Thesis** — A core original claim the author is advancing
- **Derivation** — A claim that follows logically from earlier claims (note which claims it depends on)
- **Prescription** — A practical recommendation or call to action derived from the argument. For prescriptive claims, the Grounds field should include both the *problem* being addressed and the *mechanism* by which the prescription solves it.

## Argument Dependencies

After classifying each claim, note its relationships to other claims using these two categories:

- **Logically depends on:** Claims whose truth this claim *requires* — if those claims fall, this one falls too (e.g., "Depends on: Claim 3")
- **Rhetorically supports:** Claims that this claim provides evidence or motivation for, without strict logical necessity (e.g., "Supports: Claim 5")

This distinction prevents conflating "X gives us reason to care about Y" with "X logically entails Y."

## Output Format

**Default: Markdown.** If `--json` was specified, skip to the JSON Output Format section below.

### Markdown Format

Use this markdown structure:

```
## Toulmin Analysis

**Source:** [title or first ~10 words of text] [by Author] [(Date)]

---

### Claim 1: [Brief summary of the claim]

**Role:** [Observation | Refutation | Thesis | Derivation | Prescription]
**Evidence type:** [Empirical | Anecdotal | Analogical | Logical | Authoritative | Mixed]
**Logically depends on:** [Claim numbers, or "None — foundational claim"]
**Rhetorically supports:** [Claim numbers, or "—"]

| Component | Analysis |
|-----------|----------|
| **Claim** | [The assertion] |
| **Grounds** | [Evidence/data provided] |
| **Warrant** | [Logical connection — mark as *Implicit* if unstated] |
| **Backing** | [Support for the warrant — mark as *Implicit* or *Not stated* if absent] |
| **Qualifier** | [Degree of certainty — mark as *Not stated* if absent] |
| **Rebuttal** | [Counterarguments — mark as *Not stated* if absent] |

---

### Claim 2: [Brief summary]

[... same format ...]
```

## Argument Map

After all claims, render a text-based argument map showing how claims relate. **All arrows flow from evidence/premises toward conclusions** (bottom-up direction):

```
[Claim N] ──supports──▶ [Claim M]
[Claim X] ──refutes───▶ [Claim Y]
[Claim A] + [Claim B] ──derive──▶ [Claim C]
```

Use `──supports──▶` (evidence for), `──refutes──▶` (argues against), and `──derive──▶` (logically entails). The arrow always points from the supporting/refuting claim toward the claim being supported/refuted.

## Summary & Evaluation

After the argument map, add a **Summary** section with:

- **Total claims identified:** [count]
- **Argument structure:** Classify as: **Linear chain**, **Convergent**, **Linked**, **Divergent**, or **Hybrid** (specify). Briefly describe the shape.
- **Evidence quality:** Summarize the overall evidence profile based on per-claim evidence types. Note any dominant patterns (e.g., "relies heavily on anecdote with minimal empirical support").
- **Key implicit assumptions:** List the unstated premises the argument depends on
- **Strongest claim:** Which claim is best supported and why?
- **Weakest claim:** Which claim has the most significant gaps and why?
- **Missing rebuttals:** What counterarguments does the author fail to address?

### JSON Output Format

When `--json` is specified, output a single fenced JSON code block (` ```json ... ``` `) containing the entire analysis. Perform the same analysis as for markdown — all guidelines, classification, and evaluation instructions still apply — but structure the output according to this schema:

```json
{
  "source": {
    "@type": "TextInput | WebPage | File",
    "name": "string — title or first ~10 words of text",
    "url": "string | null — the URL if input was a URL",
    "encodingFormat": "text/plain | text/html | text/markdown",
    "author": "string | null — author name if identifiable",
    "datePublished": "string | null — ISO 8601 date if identifiable"
  },
  "framing_notes": "string | null — noted extended analogies, stated methodology, or other framing devices",
  "claims": [
    {
      "id": "integer — sequential claim number starting at 1",
      "summary": "string — brief summary of the claim",
      "role": "Observation | Refutation | Thesis | Derivation | Prescription",
      "role_detail": "string | null — for Refutation: whose claim is refuted; for Prescription: problem + mechanism",
      "evidence_type": "Empirical | Anecdotal | Analogical | Logical | Authoritative | Mixed",
      "logically_depends_on": "[integer] | null — claim IDs this claim requires to be true",
      "rhetorically_supports": "[integer] | null — claim IDs this claim provides motivation for",
      "toulmin": {
        "claim": "string — the assertion",
        "grounds": "string — evidence/data provided",
        "warrant": "string — logical connection (prefix with 'Implicit: ' if unstated)",
        "backing": "string — support for the warrant ('Implicit: ...' or 'Not stated' if absent)",
        "qualifier": "string — degree of certainty ('Not stated' if absent)",
        "rebuttal": "string — counterarguments ('Not stated' if absent)"
      },
      "fallacies": "[string] | null — any informal fallacies identified in this claim"
    }
  ],
  "minor_claims": [
    {
      "summary": "string — one-line claim summary",
      "supports_claim": "integer — ID of the major claim this supports"
    }
  ],
  "argument_map": [
    {
      "from": "[integer] — source claim ID(s)",
      "to": "integer — target claim ID",
      "relation": "supports | refutes | derives"
    }
  ],
  "summary": {
    "total_claims": "integer — core + minor count",
    "argument_structure": "string — Linear chain | Convergent | Linked | Divergent | Hybrid, plus brief description",
    "evidence_quality": "string — overall evidence profile summary",
    "implicit_assumptions": "[string] — unstated premises the argument depends on",
    "strongest_claim": {
      "id": "integer",
      "reason": "string"
    },
    "weakest_claim": {
      "id": "integer",
      "reason": "string"
    },
    "missing_rebuttals": "[string] — counterarguments the author fails to address"
  }
}
