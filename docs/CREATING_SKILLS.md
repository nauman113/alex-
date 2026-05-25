# How to Create Custom Skills

## Overview

Skills are defined in SKILL.md files using Markdown + YAML frontmatter. They describe workflows that Ollama will follow when generating responses.

## Step 1: Create Skill Directory

```bash
mkdir -p bundles/<domain>/<skill-name>
cd bundles/<domain>/<skill-name>
```

**Examples:**
```bash
mkdir -p bundles/legal/contract-review
mkdir -p bundles/finance/budget-analyzer
mkdir -p bundles/marketing/campaign-brief-writer
```

## Step 2: Write SKILL.md

Create `SKILL.md` with this structure:

```markdown
---
name: Your Skill Name
description: Brief description of what this skill does
version: 1.0.0
tags: tag1, tag2, tag3
---

# Skill Title (optional but recommended)

## Purpose

[1-2 sentences explaining the purpose]

## Workflow

### Step 1: [Title]

[Instructions for step 1]

### Step 2: [Title]

[Instructions for step 2]

### Step 3: [Title]

[Instructions for step 3]

## Quality Checklist

- [ ] Checklist item 1
- [ ] Checklist item 2
- [ ] Checklist item 3

## Example

[Optional: show an example of expected input/output]

---

**End of Skill: [Skill Name]**
```

## Step 3: Complete Frontmatter

```yaml
---
name: Contract Review        # Displayed name of skill
description: Analyze legal contracts    # One-liner description
version: 1.0.0               # Semantic versioning
tags: legal, contracts, analysis  # Comma-separated tags
---
```

**Rules:**
- `name`: Required, 2-50 characters
- `description`: Required, 10-150 characters
- `version`: Required, semver format (X.Y.Z)
- `tags`: Optional, comma-separated, max 5 tags

## Step 4: Write Workflow

### Structure

```markdown
## Workflow

### Step 1: [What to Do]

[Detailed instructions]

1. **Substep A** — description
2. **Substep B** — description

Output format:
```
[Structured output example]
```

### Step 2: [Next Step]

[More instructions]
```

### Guidelines

**DO:**
- Number steps sequentially
- Use bold for emphasis (`**text**`)
- Provide output format examples
- Be specific and actionable
- Include multiple levels of detail

**DON'T:**
- Skip steps
- Use vague language ("analyze", "review")
- Mix multiple unrelated tasks
- Exceed 10 steps (too complex)

### Example: Full Workflow

```markdown
## Workflow

### Step 1: Parse Document Structure

First, analyze the document format:

1. **Identify Document Type** — Is this a report, proposal, email?
2. **Extract Metadata** — Author, date, subject, version
3. **Outline Sections** — Note all section headings and subsections
4. **Count Content** — Approximate word count and complexity

Output format:
```
DOCUMENT STRUCTURE
──────────────────
Type: [Type]
Author: [Author]
Date: [Date]
Section Count: [Number]
```
```

### Step 2: Analyze Content

Now dive into the content:

1. **Main Argument** — What's the core message?
2. **Supporting Points** — List key supporting arguments
3. **Evidence** — What data or examples support the thesis?
4. **Conclusion** — What does the author conclude?
```

## Step 5: Add Quality Checklist

Provide a checklist users can verify:

```markdown
## Quality Checklist

Before finalizing, verify:

- ☑ All sections have been analyzed
- ☑ Key terms are defined
- ☑ Examples provided for each point
- ☑ No contradictions in recommendations
- ☑ Output follows specified format
- ☑ All recommendations are actionable
```

## Step 6: Test Your Skill

### Convert to Modelfile

```bash
cd /path/to/repo
python3 convert.py --bundle <domain> --dry-run
```

### Verify Output

```bash
cat models/<domain>/<skill-name>/Modelfile
```

### Build Model

```bash
bash setup.sh --skill <domain>/<skill-name>
```

### Run Interactive Test

```bash
ollama run skills-<domain>-<skill-name>
```

## Step 7: Refine

Test your skill with real inputs:

**Good test:**
```
$ ollama run skills-legal-contract-review
User: [Paste actual contract]

[Check if output follows workflow steps and quality checklist]
```

**Iterate:**
1. Run test
2. Review output
3. Edit SKILL.md
4. Re-run convert.py
5. Rebuild model
6. Test again

## Complete Example: PRD Template Skill

### File: `bundles/pm-essentials/prd-template/SKILL.md`

```markdown
---
name: PRD Template Generator
description: Generate product requirement documents with structured sections
version: 1.0.0
tags: product, prd, requirements
---

# PRD Template Generator

## Purpose

This skill generates a complete PRD template with all required sections, including context, objectives, success metrics, and implementation details.

## Workflow

### Step 1: Gather Product Information

Ask for and capture the core product information:

1. **Product Name** — What is this product called?
2. **Problem Statement** — What problem does it solve?
3. **Target Users** — Who will use this product?
4. **Key Features** — What are the main capabilities?

Output format:
```
PRODUCT OVERVIEW
────────────────
Product: [Name]
Problem: [Statement]
Users: [Personas]
Features: [List]
```

### Step 2: Define Objectives & Success

Establish clear goals:

1. **Business Objectives** — What does the company want?
2. **User Objectives** — What do users need?
3. **Success Metrics** — How will we measure success?
4. **Timeline** — When should this launch?

### Step 3: Detail Requirements

Provide technical and functional requirements:

1. **Functional Requirements** — What must the product do?
2. **Technical Requirements** — What tech stack is needed?
3. **Constraints** — What limits exist?
4. **Dependencies** — What does this depend on?

### Step 4: Outline User Experience

Describe the user journey:

1. **User Flows** — How will users interact?
2. **Key Screens** — What screens/pages are needed?
3. **Edge Cases** — What edge cases exist?
4. **Accessibility** — What A11y considerations?

### Step 5: Generate PRD Output

Compile the complete PRD:

```
═══════════════════════════════════════════════════════════
PRODUCT REQUIREMENTS DOCUMENT
═══════════════════════════════════════════════════════════

1. PRODUCT OVERVIEW
   Problem: [...]
   Solution: [...]
   Target Users: [...]

2. OBJECTIVES & SUCCESS METRICS
   Business Goals: [...]
   Success Criteria: [...]
   Timeline: [...]

3. REQUIREMENTS
   Functional: [...]
   Technical: [...]
   Constraints: [...]

4. USER EXPERIENCE
   Flows: [...]
   Key Screens: [...]
   Edge Cases: [...]

5. IMPLEMENTATION
   Resources: [...]
   Timeline: [...]
   Risks: [...]

═══════════════════════════════════════════════════════════
```

## Quality Checklist

- ☑ All sections populated with specific details
- ☑ Success metrics are measurable
- ☑ Requirements are specific and testable
- ☑ User flows are complete
- ☑ Timeline is realistic
- ☑ No conflicting requirements
- ☑ All dependencies identified
- ☑ Accessibility considered

---

**End of Skill: PRD Template Generator**
```

## Best Practices

### Workflow Design

✅ **Good:**
```markdown
### Step 1: Extract Key Data

1. **Identify Amount** — Find all monetary figures
2. **Note Currency** — What currency is used?
3. **Check Dates** — When is payment due?

Output:
```
AMOUNT: $X
CURRENCY: [Currency]
DUE DATE: [Date]
```
```

❌ **Poor:**
```markdown
### Step 1: Extract Data

Extract important information from the document.
```

### Parameter Tuning

**Temperature Mapping:**
- Legal/Finance → 0.3
- Engineering/PM → 0.5
- Marketing/Design → 0.7

This is handled automatically in `convert.py` based on bundle type.

### Testing Strategy

1. **Unit Test** — Single skill with test input
2. **Integration Test** — Skill with real data
3. **Edge Cases** — Boundary conditions, large inputs
4. **Performance** — Response time acceptable?
5. **Quality** — Output matches expected format?

## Common Patterns

### Analysis Workflow

```markdown
## Workflow

### Step 1: Intake
[Questions to gather info]

### Step 2: Analysis
[How to analyze the data]

### Step 3: Synthesis
[How to combine findings]

### Step 4: Output
[Format for results]
```

### Generation Workflow

```markdown
## Workflow

### Step 1: Gather Requirements
[What information to collect]

### Step 2: Structure Content
[How to organize output]

### Step 3: Generate Section A
[Specific instructions]

### Step 4: Generate Section B
[More specific instructions]

### Step 5: Compile & Review
[Final assembly steps]
```

### Decision Workflow

```markdown
## Workflow

### Step 1: Define Options
[How to identify choices]

### Step 2: Evaluate Each Option
[Criteria for evaluation]

### Step 3: Pros & Cons
[How to format analysis]

### Step 4: Recommendation
[How to conclude]
```

## Troubleshooting

### Issue: Model Doesn't Follow Workflow

**Solution:**
- Make steps more explicit
- Add more detail to instructions
- Include output format example
- Lower temperature in generated Modelfile

### Issue: Model Strays from Format

**Solution:**
- Add step: "Format output as: [TEMPLATE]"
- Include quality checklist
- Make expected output very specific

### Issue: Response Too Long

**Solution:**
- Add summarization step
- Specify output length
- Reduce context window (num_ctx)

## Publishing

1. Create PR with your `bundles/<domain>/<skill>/SKILL.md`
2. Run tests: `bash setup.sh --skill <domain>/<skill> --dry-run`
3. Wait for review
4. Merge to main
5. Run full deployment

## Need Help?

- Check [SKILL_TEMPLATE_EXAMPLE.md](SKILL_TEMPLATE_EXAMPLE.md) for complete example
- Review [ARCHITECTURE.md](ARCHITECTURE.md) for technical details
- See [README.md](../README.md#creating-custom-skills) for quick start
