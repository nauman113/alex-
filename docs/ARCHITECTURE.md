# Ollama Skills Library — Architecture & Design

## System Overview

```
┌─────────────────────────────────────────────────────────────┐
│         User: "ollama run skills-legal-contract-review"     │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    Ollama Runtime                            │
│  • Loads Modelfile from disk                                │
│  • Initializes base LLM (llama3.2)                          │
│  • Injects system prompt                                     │
│  • Applies parameters (temp, context, penalties)            │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│               Generated Modelfile                            │
│  ─────────────────────────────────────────                 │
│  FROM llama3.2                                              │
│  PARAMETER temperature 0.3                                   │
│  PARAMETER num_ctx 8192                                      │
│  SYSTEM "You are a legal expert..."                         │
│  [Structured workflow instructions]                         │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              Base Model (llama3.2)                           │
│  • Executes instructions from system prompt                 │
│  • Maintains conversation history                           │
│  • Applies domain-specific parameters                       │
└─────────────────────────────────────────────────────────────┘
```

---

## Pipeline: SKILL.md → Modelfile → Ollama

### Stage 1: Source Format (SKILL.md)

**Location:** `bundles/<domain>/<skill>/SKILL.md`

**Format:** Markdown with YAML frontmatter

```markdown
---
name: Contract Review
description: Legal analysis of contracts
version: 1.0.0
tags: legal, contracts
---

## Workflow

1. **Step One** — Instructions
2. **Step Two** — Instructions

## Quality Checklist
- [ ] Item 1
- [ ] Item 2
```

**Key Characteristics:**
- Human-readable format
- Frontmatter metadata (name, description, version, tags)
- Markdown body contains workflow
- Includes quality checklist
- No Ollama-specific syntax

### Stage 2: Conversion (convert.py)

**Process:**

```
Input: SKILL.md
  ↓
parse_frontmatter()
  └─→ Extract metadata (name, description, version, tags)
  └─→ Extract body (workflow instructions)
  ↓
remove_trigger_phrases()
  └─→ Strip "## Example Trigger Phrases" section
  ↓
escape_system_prompt()
  └─→ Replace """ with '''
  ↓
build_modelfile()
  └─→ Get temperature from TEMPERATURE_MAP[bundle]
  └─→ Get domain from DOMAIN_MAP[bundle]
  └─→ Build system prompt: "You are... [domain]... [workflow]"
  └─→ Generate Modelfile with FROM, PARAMETER, SYSTEM directives
  ↓
Output: Modelfile
```

**Python Functions:**

```python
def parse_frontmatter(text: str) → (dict, str)
    # Returns: (frontmatter_dict, body_text)

def remove_trigger_phrases(body: str) → str
    # Pattern: \n## Example Trigger Phrases\b.*?(?=\n## |\Z)

def escape_system_prompt(text: str) → str
    # Replace """ with '''

def build_modelfile(bundle, fm, body, base_model) → str
    # Generates full Modelfile content

def slug(name: str) → str
    # Convert "My Skill" → "my-skill"
```

### Stage 3: Output Format (Modelfile)

**Location:** `models/<domain>/<skill>/Modelfile`

**Format:** Ollama Modelfile syntax

```dockerfile
# Ollama Skills Library — legal / contract-review
# Version: 1.0.0
# Tags: legal, contracts, risk-analysis
# Description: Comprehensive legal analysis

FROM llama3.2

PARAMETER temperature 0.3
PARAMETER num_ctx 8192
PARAMETER top_p 0.9
PARAMETER repeat_penalty 1.1

SYSTEM """
You are a professional assistant specializing in legal document analysis.
Follow the structured workflow below exactly when the user asks for help.

## Workflow

1. **Step One** — Instructions
2. **Step Two** — Instructions

## Quality Checklist
- [ ] Item 1
- [ ] Item 2
"""
```

**Key Components:**
- `FROM` — Specifies base model
- `PARAMETER temperature` — Controls determinism (0-1)
- `PARAMETER num_ctx` — Context window size
- `PARAMETER top_p` — Nucleus sampling
- `PARAMETER repeat_penalty` — Avoid repetition
- `SYSTEM` — System prompt injected into every conversation

---

## Configuration: Temperature Mapping

### By Domain Expertise Level

```python
TEMPERATURE_MAP = {
    # Factual, deterministic (low temp)
    "legal": 0.3,           # Contracts must be precise
    "finance": 0.3,         # Financial analysis needs accuracy
    
    # Structured, slightly creative (medium temp)
    "engineering": 0.4,     # Technical but allows explanation variants
    "data": 0.4,            # Data analysis with structured reasoning
    "analytics": 0.4,       # Metrics with multiple approaches
    "delivery": 0.4,        # Project management with some flexibility
    "research": 0.4,        # Structured research methodology
    "operations": 0.4,      # Process documentation
    "healthcare": 0.4,      # Medical accuracy required
    
    # Balanced (medium-high temp)
    "hr": 0.5,              # HR policies with tone variation
    "pm-essentials": 0.5,   # Product management
    "pm-engineering": 0.5,  # Engineering-focused PM
    "agile": 0.5,           # Agile methodologies
    "strategy": 0.5,        # Strategy frameworks
    "consulting": 0.5,      # Consulting approaches
    
    # Creative, varied (high temp)
    "education": 0.6,       # Educational content creation
    "sales": 0.6,           # Sales messaging variants
    "design": 0.6,          # Design exploration
    "leadership": 0.6,      # Leadership communication
    "startup": 0.6,         # Startup ideation
    "marketing": 0.7,       # Marketing creativity
    "communications": 0.7,  # Creative corporate messaging
}
```

### Why This Matters

**Low Temperature (0.3):**
- Model is more deterministic
- Follows instructions exactly
- Less hallucination
- Better for legal/financial/compliance

**High Temperature (0.7):**
- Model is more creative
- Generates varied content
- More engaging marketing copy
- Better for ideation

---

## Domain Mapping: System Prompt Prefixes

```python
DOMAIN_MAP = {
    "legal": "legal document analysis",
    "finance": "financial planning and analysis",
    "engineering": "software engineering documentation",
    "design": "UX and product design",
    # ... 18 more
}
```

Each domain gets a custom system prompt prefix:

```
You are a professional assistant specializing in [DOMAIN].
Follow the structured workflow below exactly when the user asks for help.

[Workflow from SKILL.md body]
```

---

## Bundle Structure

### Directory Layout

```
bundles/
├── legal/
│   ├── plugin.json
│   ├── contract-review/
│   │   └── SKILL.md
│   ├── nda-analysis/
│   │   └── SKILL.md
│   └── ...
├── finance/
│   ├── plugin.json
│   ├── okr-builder/
│   │   └── SKILL.md
│   └── ...
└── ...
```

### plugin.json (Bundle Metadata)

```json
{
  "name": "Legal Document Analysis",
  "version": "1.0.0",
  "description": "Contract review, NDA analysis, compliance...",
  "category": "legal",
  "keywords": ["legal", "contracts", "compliance"]
}
```

---

## Output Manifests

### manifest.json (Bundle Level)

**Location:** `models/legal/manifest.json`

```json
{
  "$schema": "https://ollama.com/skills/manifest.schema.json",
  "name": "legal",
  "displayName": "Legal Document Analysis",
  "version": "1.0.0",
  "description": "...",
  "skillCount": 5,
  "baseModel": "llama3.2",
  "skills": [
    {
      "id": "contract-review",
      "name": "Contract Review",
      "description": "...",
      "modelName": "skills-legal-contract-review",
      "path": "models/legal/contract-review/Modelfile"
    },
    // ... more skills
  ]
}
```

### library.json (Library Level)

**Location:** `library.json`

```json
{
  "$schema": "https://ollama.com/skills/library.schema.json",
  "name": "Ollama Skills Library",
  "version": "1.0.0",
  "description": "106 skills across 22 domains...",
  "defaultBaseModel": "llama3.2",
  "bundles": [
    {
      "id": "legal",
      "name": "Legal",
      "skillCount": 5,
      "path": "models/legal",
      "manifestConfig": "models/legal/manifest.json"
    },
    // ... more bundles
  ]
}
```

---

## Runtime Behavior

### Session Flow

```
User: "ollama run skills-legal-contract-review"
  │
  ├─→ Ollama loads Modelfile from disk
  │
  ├─→ Reads: FROM llama3.2
  │    • Downloads/initializes base model
  │
  ├─→ Reads: PARAMETER directives
  │    • temperature = 0.3
  │    • num_ctx = 8192
  │    • top_p = 0.9
  │    • repeat_penalty = 1.1
  │
  ├─→ Reads: SYSTEM prompt
  │    • Stores in memory
  │    • Will inject into every turn
  │
  ├─→ Starts interactive session
  │    • Awaits user input
  │    • Injects system prompt
  │    • Generates response with parameters
  │    • Maintains conversation history
  │
  └─→ Session ends → Memory freed
```

### Prompt Injection Mechanism

Each user message is processed as:

```
[SYSTEM PROMPT]
You are a professional assistant specializing in legal document analysis.
Follow the structured workflow below exactly...
[Workflow from SKILL.md]

[CONVERSATION HISTORY]
User: Previous messages
Assistant: Previous responses

[USER INPUT]
User: "Review this contract..."

→ Model generates response following system prompt workflow
```

---

## Performance Characteristics

### Model Size vs Speed

| Model | Size | Speed | Quality | Memory |
|---|---|---|---|---|
| llama3.2 | 4GB | Fast | Good | 4GB |
| mistral | 7B | Medium | Very Good | 5GB |
| llama2 | 7B | Medium | Good | 5GB |

### Context Window Impact

| Context | Max Tokens | Use Case | Speed Hit |
|---|---|---|---|
| 4096 | Short docs | Single contracts | +0% |
| 8192 | Standard | Most workflows | +10% |
| 16384 | Long docs | Multi-page analysis | +30% |
| 32768 | Archives | Bulk review | +60% |

### Temperature Impact on Quality

```
Temperature Impact on Legal Analysis:
─────────────────────────────────────

0.1 (Very Low)      → Extremely repetitive, mechanical
0.3 (Our Legal)     → Consistent, precise, formal ✓
0.5 (Medium)        → Varied, professional
0.7 (Creative)      → Multiple interpretations (risky)
1.0 (Maximum)       → Highly creative but unreliable
```

---

## Extension Points

### Adding New Bundles

1. Create `bundles/<new-bundle>/`
2. Create `bundles/<new-bundle>/plugin.json`
3. Create `bundles/<new-bundle>/<skill>/SKILL.md`
4. Add to `TEMPERATURE_MAP` and `DOMAIN_MAP` in `convert.py`
5. Run: `python3 convert.py --bundle <new-bundle>`

### Adding New Skills

1. Create `bundles/<existing-bundle>/<new-skill>/SKILL.md`
2. Run: `python3 convert.py --bundle <existing-bundle>`
3. Deploy: `bash setup.sh --bundle <existing-bundle>`

### Customizing Parameters

Edit the generated Modelfile:

```dockerfile
# models/<bundle>/<skill>/Modelfile

FROM llama3.2

PARAMETER temperature 0.3      # ← Adjust here
PARAMETER num_ctx 8192         # ← Or here
PARAMETER top_p 0.9            # ← Or here
PARAMETER repeat_penalty 1.1   # ← Or here

SYSTEM """
[Your custom prompt]
"""
```

Then rebuild:
```bash
ollama create skills-legal-contract-review -f models/legal/contract-review/Modelfile
```

---

## Troubleshooting

### Issue: Modelfile Syntax Error

**Problem:** `Error loading Modelfile: invalid syntax`

**Solution:**
- Ensure no `"""` characters in SYSTEM prompt body
- Check for unescaped newlines
- Validate PARAMETER formats

### Issue: Model Behavior Inconsistent

**Problem:** Same input produces different outputs

**Causes:**
- Temperature too high (> 0.5)
- Reduce with: `PARAMETER temperature 0.1`

**Solution:**
- Lower temperature in Modelfile
- Rebuild model
- Test again

### Issue: Out of Memory

**Problem:** `CUDA out of memory` or similar

**Solutions:**
1. Reduce context: `PARAMETER num_ctx 4096`
2. Use smaller base model: `FROM mistral`
3. Close other applications

---

## Best Practices

### Skill Design

✅ **DO:**
- Use step-by-step workflows
- Include quality checklists
- Provide output templates
- Quote specific sections
- Use consistent formatting

❌ **DON'T:**
- Write open-ended instructions
- Skip quality validation
- Use ambiguous language
- Mix multiple tasks
- Include contradictory steps

### Parameter Tuning

✅ **DO:**
- Use low temp (0.3) for factual tasks
- Use medium temp (0.5) for balanced tasks
- Test thoroughly before deploying
- Document your choices

❌ **DON'T:**
- Use default parameters without testing
- Use high temp (0.7+) for critical tasks
- Forget about num_ctx limitations
- Ignore repeat_penalty settings

---

## Future Enhancements

- [ ] Multi-turn conversation state management
- [ ] Batch processing API
- [ ] Custom model fine-tuning
- [ ] Skill versioning & rollback
- [ ] Performance monitoring dashboard
- [ ] A/B testing framework
- [ ] Integration with vector databases
- [ ] RAG (Retrieval-Augmented Generation) support
