# Deduplication/Canonicalization Workflows

This document illustrates the current and proposed workflows for drink recipe deduplication and canonicalization in the Mixologist backend.

---

## Current State Workflow

The current system runs the DB fuzzy/alias search and LLM canonicalization in parallel, then selects the best match.

```mermaid
flowchart TD
    A[User submits drink query] --> B[Run DB fuzzy/alias search and LLM canonicalization in parallel]
    B --> C{DB fuzzy/alias match found?}
    C -- Yes --> D[Return canonical recipe from DB]
    C -- No --> E[LLM returns result]
    E --> F{LLM returns canonical match?}
    F -- Yes --> G[Try to fetch canonical recipe from DB]
    G -- Found --> H[Return canonical recipe from DB]
    G -- Not found --> I[Return LLM's canonical info]
    F -- No --> J[LLM invents new recipe]
    J --> K[Save new recipe to DB]
    K --> L[Return new recipe]
```

---

## Proposed Improved Workflow

The proposed system adds a pre-LLM keyword search and post-processing for near-matches, and enforces stricter canonicalization from the LLM.

```mermaid
flowchart TD
    A[User submits drink query] --> B[Pre-LLM keyword/phrase search for canonical names]
    B --> C{Keyword match found?}
    C -- Yes --> D[Return canonical recipe from DB]
    C -- No --> E[Run DB fuzzy/alias search and LLM canonicalization in parallel]
    E --> F{DB fuzzy/alias match found?}
    F -- Yes --> G[Return canonical recipe from DB]
    F -- No --> H[LLM returns result]
    H --> I{LLM returns canonical match?}
    I -- Yes --> J[Try to fetch canonical recipe from DB]
    J -- Found --> K[Return canonical recipe from DB]
    J -- Not found --> L[Return LLM's canonical info]
    I -- No --> M[LLM invents new recipe]
    M --> N[Post-process: compare to known recipes]
    N --> O{High similarity to canonical?}
    O -- Yes --> P[Return canonical recipe from DB]
    O -- No --> Q[Save new recipe to DB]
    Q --> R[Return new recipe]
``` 