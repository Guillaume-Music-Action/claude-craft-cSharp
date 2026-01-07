---
name: generate-prd
description: Generate a Product Requirements Document from project context and specifications
arguments:
  - name: source
    description: Source file with specifications (optional, default auto-detect)
    required: false
  - name: output
    description: Output path (default project-management/prd.md)
    required: false
---

# /project:generate-prd

## Mission

Generate a comprehensive Product Requirements Document (PRD) by analyzing the project context, existing specifications, and through interactive clarification with the user.

## Prerequisites

- Project directory exists
- Optional: `./docs/` with existing specifications
- Optional: `README.md` with project description

## Workflow

### Phase 1: Context Discovery

```
╔══════════════════════════════════════════════════════════╗
║              PRD GENERATION - DISCOVERY                   ║
╠══════════════════════════════════════════════════════════╣
║ Scanning project context...                               ║
╚══════════════════════════════════════════════════════════╝
```

**Automatic Analysis:**
1. Read `README.md` for project overview
2. Scan `./docs/` for existing specifications
3. Check `project-management/personas.md` if exists
4. Analyze codebase structure for tech stack
5. Review previous conversations for context

**Sources Found:**
- [ ] README.md
- [ ] docs/specifications.md
- [ ] docs/requirements.md
- [ ] project-management/personas.md
- [ ] Conversation history

### Phase 2: Interactive Clarification

Ask the user clarifying questions to fill gaps:

#### Problem & Opportunity
```
┌─────────────────────────────────────────────────────────┐
│ QUESTIONS - Problem Statement                            │
├─────────────────────────────────────────────────────────┤
│ 1. What problem are you solving?                         │
│ 2. Who experiences this problem most?                    │
│ 3. What happens if this problem isn't solved?            │
│ 4. What's the business opportunity?                      │
└─────────────────────────────────────────────────────────┘
```

#### Target Users
```
┌─────────────────────────────────────────────────────────┐
│ QUESTIONS - Target Users                                 │
├─────────────────────────────────────────────────────────┤
│ 1. Who are your primary users? (role, demographics)      │
│ 2. What are their main goals?                            │
│ 3. What frustrates them with current solutions?          │
│ 4. Are there secondary user types?                       │
└─────────────────────────────────────────────────────────┘
```

#### Goals & Metrics
```
┌─────────────────────────────────────────────────────────┐
│ QUESTIONS - Success Metrics                              │
├─────────────────────────────────────────────────────────┤
│ 1. What are your business goals?                         │
│ 2. How will you measure success? (KPIs)                  │
│ 3. What are the target values and timeline?              │
│ 4. What does MVP success look like?                      │
└─────────────────────────────────────────────────────────┘
```

#### Requirements & Constraints
```
┌─────────────────────────────────────────────────────────┐
│ QUESTIONS - Scope & Constraints                          │
├─────────────────────────────────────────────────────────┤
│ 1. What are the must-have features (P0)?                 │
│ 2. What's explicitly out of scope?                       │
│ 3. Any technical constraints? (legacy systems, etc.)     │
│ 4. Budget or timeline constraints?                       │
│ 5. Compliance requirements? (GDPR, SOC2, etc.)           │
└─────────────────────────────────────────────────────────┘
```

### Phase 3: PRD Generation

Using the collected information, generate the PRD:

1. **Load Template**: `./templates/prd.md`
2. **Fill Sections**: Populate all sections with gathered data
3. **Generate Personas**: Create detailed persona profiles
4. **Structure Requirements**: Organize into P0/P1/P2 priorities
5. **Identify Risks**: Based on constraints and dependencies

### Phase 4: Review & Iteration

```
╔══════════════════════════════════════════════════════════╗
║                    PRD GENERATED                          ║
╠══════════════════════════════════════════════════════════╣
║ Output: project-management/prd.md                         ║
║                                                           ║
║ Sections completed:                                       ║
║ ✅ Executive Summary                                      ║
║ ✅ Problem Statement                                      ║
║ ✅ Goals & Metrics                                        ║
║ ✅ Target Users (3 personas)                              ║
║ ✅ Functional Requirements (12 items)                     ║
║ ✅ Non-Functional Requirements                            ║
║ ✅ Scope & Constraints                                    ║
║ ⚠️  Timeline (needs review)                               ║
║ ✅ Risks & Mitigations                                    ║
╚══════════════════════════════════════════════════════════╝
```

**Offer iterations:**
- "Would you like me to expand any section?"
- "Should I add more detail to the personas?"
- "Do you want to adjust the prioritization?"

## Output Structure

```
project-management/
├── prd.md                    # Generated PRD
├── personas.md               # Extracted/created personas
└── analysis/
    └── discovery-notes.md    # Notes from discovery phase
```

## Integration with Workflow

After PRD generation, suggest next steps:

```
╔══════════════════════════════════════════════════════════╗
║                     NEXT STEPS                            ║
╠══════════════════════════════════════════════════════════╣
║ PRD is ready! Recommended next actions:                   ║
║                                                           ║
║ 1. /project:generate-tech-spec    → Technical design      ║
║ 2. /project:generate-backlog      → Create SCRUM backlog  ║
║ 3. /workflow:design               → Architecture phase    ║
╚══════════════════════════════════════════════════════════╝
```

## Example Session

```
User: /project:generate-prd

Claude: Starting PRD generation...

📂 Context Discovery
Found sources:
- README.md (project overview)
- docs/brief.md (initial brief)

Let me ask some clarifying questions:

❓ Problem Statement
1. What specific problem does this product solve?
> User: Our users spend too much time manually tracking expenses...

❓ Target Users
2. Who are your primary users?
> User: Small business owners and freelancers...

[... interactive Q&A continues ...]

✅ PRD Generated!
Output: project-management/prd.md

The PRD includes:
- 2 primary personas (Business Owner, Freelancer)
- 8 P0 requirements, 5 P1 requirements
- KPIs: Time saved (50%), Error reduction (80%)
- 4 identified risks with mitigations

Would you like me to:
1. Expand any section?
2. Generate the Technical Specification?
3. Create the product backlog?
```

## Related Commands

- `/project:generate-tech-spec` - Generate technical specification
- `/project:generate-backlog` - Create SCRUM backlog from PRD
- `/workflow:plan` - Full planning phase workflow
- `/workflow:init` - Initialize project workflow
