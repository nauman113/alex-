---
name: Contract Review & Risk Analysis
description: Comprehensive legal analysis of contracts with risk identification and key term extraction
version: 1.0.0
tags: legal, contracts, risk-analysis, compliance
---

# Contract Review & Risk Analysis

## Purpose

This skill provides a structured workflow for analyzing legal contracts, extracting key terms, identifying potential risks, and generating executive summaries for legal review.

## Workflow

### Step 1: Document Intake & Structure Analysis

First, read through the entire contract and analyze its structure:

1. **Document Type** — Identify contract category (NDA, Employment, Service Agreement, etc.)
2. **Parties Involved** — List all signing parties and their roles
3. **Effective Date & Term** — Note dates, duration, renewal conditions
4. **Key Sections** — Outline main sections present

Output format:
```
CONTRACT STRUCTURE
─────────────────
Type: [Contract Type]
Parties: [Party 1], [Party 2], etc.
Effective Date: [Date]
Term: [Duration]
Renewal: [Conditions]
```

### Step 2: Extract Key Financial & Commercial Terms

Analyze all financial and business provisions:

1. **Payment Terms** — Amount, schedule, currency, conditions
2. **Fee Structures** — Hourly rates, retainers, caps, escalations
3. **Penalties & Liquidated Damages** — Late fees, breach costs
4. **Termination Fees** — Early exit costs, breakup fees
5. **Insurance Requirements** — Coverage amounts, policy types
6. **Indemnification** — Who indemnifies whom, scope, limits

Output format:
```
FINANCIAL TERMS
───────────────
Payment: $X per [unit]
Schedule: [payment schedule]
Late Payment: [penalty]
Termination: [costs]
Insurance: [requirements]
Indemnification: [coverage]
```

### Step 3: Identify Critical Legal Risks

Flag issues that require immediate attention:

1. **Unfavorable Liability Caps** — Unlimited vs capped liability
2. **One-Sided Indemnification** — Unbalanced risk allocation
3. **Perpetual Obligations** — Terms extending beyond contract end
4. **Restrictive Covenants** — Non-compete, non-solicitation scope
5. **IP Ownership Ambiguities** — Unclear ownership of work product
6. **Broad Termination Rights** — Easy termination by counterparty
7. **Unilateral Amendment Rights** — One party can change terms
8. **Jurisdiction & Venue Issues** — Unfavorable legal jurisdiction

Output format:
```
🚩 CRITICAL RISKS
─────────────────
RISK 1: [Risk Name]
  Issue: [Specific problem]
  Impact: [Business consequence]
  Recommendation: [Fix]
  Severity: HIGH/MEDIUM/LOW

RISK 2: [Risk Name]
  ...
```

### Step 4: Analyze Intellectual Property Provisions

Evaluate IP ownership and usage rights:

1. **Work Product Ownership** — Who owns created IP?
2. **Pre-Existing IP** — How are existing tools/code handled?
3. **License Grants** — What can the other party do with materials?
4. **Derivative Works** — Who can modify and redistribute?
5. **Open Source** — Any open source licensing requirements?
6. **Confidential Information** — How is trade secrets handled?

Output format:
```
INTELLECTUAL PROPERTY
─────────────────────
Work Product Owner: [Party]
Pre-Existing IP: [Terms]
License Scope: [Permitted Uses]
Derivative Works: [Restrictions]
Open Source: [Requirements]
```

### Step 5: Check Compliance & Regulatory Provisions

Identify compliance obligations:

1. **Data Protection** — GDPR, CCPA, data handling requirements
2. **Export Controls** — Sanctions, trade restrictions
3. **Regulatory Approvals** — Required licenses or permits
4. **Compliance Certifications** — ISO, SOC2, industry standards
5. **Audit Rights** — Who can audit whom and when?
6. **Regulatory Changes** — How do contract terms adapt?

Output format:
```
COMPLIANCE REQUIREMENTS
──────────────────────
Data Protection: [Requirements]
Export Controls: [Restrictions]
Approvals Needed: [List]
Certifications: [Required]
Audit Rights: [Scope]
```

### Step 6: Generate Executive Summary

Create a concise, executive-level summary:

```
EXECUTIVE SUMMARY
─────────────────

OVERVIEW
[1-2 sentence description of contract]

KEY TERMS
• Payment: [amount and schedule]
• Duration: [term and renewal]
• Termination: [conditions and costs]

TOP 3 RISKS
1. [Risk] — Impact: [consequence]
2. [Risk] — Impact: [consequence]
3. [Risk] — Impact: [consequence]

RECOMMENDATIONS
✓ [Action 1]
✓ [Action 2]
✓ [Action 3]

NEGOTIATION PRIORITIES
1. [Priority with high impact]
2. [Priority with medium impact]
```

## Quality Checklist

Before finalizing your analysis, verify:

- ☑ All contract sections have been analyzed
- ☑ Financial terms are accurately extracted
- ☑ All potential risks have been identified
- ☑ Risk severity levels are appropriately assigned
- ☑ IP ownership provisions are clearly explained
- ☑ Compliance obligations are listed
- ☑ Executive summary is concise (< 1 page)
- ☑ Specific contract language is quoted for key risks
- ☑ Recommendations are actionable
- ☑ All currency and date formats are consistent

## Output Template

Use this exact template for your analysis:

```
═══════════════════════════════════════════════════════════
CONTRACT ANALYSIS REPORT
═══════════════════════════════════════════════════════════

CONTRACT STRUCTURE
──────────────────
Type: [TYPE]
Parties: [PARTIES]
Effective Date: [DATE]
Term: [DURATION]

FINANCIAL TERMS
───────────────
Payment: [TERMS]
Fee Structure: [DETAILS]
Termination Costs: [DETAILS]

🚩 CRITICAL RISKS (High Priority)
─────────────────────────────────
[Risk 1: ...] 
[Risk 2: ...]

⚠️  MODERATE RISKS (Medium Priority)
──────────────────────────────────
[Risk 3: ...]

INTELLECTUAL PROPERTY
─────────────────────
Work Product Owner: [OWNER]
Pre-Existing IP: [TERMS]
License Grant: [SCOPE]

COMPLIANCE REQUIREMENTS
──────────────────────
[Requirement 1]
[Requirement 2]

EXECUTIVE SUMMARY & RECOMMENDATIONS
────────────────────────────────────
[Summary]

NEGOTIATION PRIORITIES
─────────────────────
1. [Top Priority]
2. [Secondary]
3. [Tertiary]

═══════════════════════════════════════════════════════════
```

## Common Patterns to Watch For

### Red Flags 🚩

- "Unlimited liability" without cap
- "Perpetual" clauses extending after termination
- "Sole discretion" giving unilateral power
- "Indemnify us for anything" (overly broad indemnification)
- "We can amend this anytime" (unilateral amendment rights)
- Missing defined terms or ambiguous language

### Yellow Flags ⚠️

- "May terminate for convenience" without notice period
- "Survival beyond [term]" for certain clauses
- "Broad definition" of competing activities
- "Automatic renewal" without clear opt-out

### Green Flags ✅

- Balanced liability caps
- Clear termination conditions
- Specific, limited indemnification
- Defined scope for restrictions
- Clear IP ownership provisions

## Tips for Best Results

1. **Read Completely** — Don't skip sections; every provision matters
2. **Compare Definitions** — Check if key terms are defined consistently
3. **Cross-Reference** — Look for conflicts between sections
4. **Pay Attention to Negatives** — "Not responsible for" can hide issues
5. **Note Silence** — What's NOT in the contract is often important
6. **Use Exact Language** — Quote specific contract text in your analysis
7. **Be Specific** — Don't just say "risky"; explain the business impact
8. **Prioritize** — Focus on high-impact vs low-impact issues

---

**End of Skill: Contract Review & Risk Analysis**
