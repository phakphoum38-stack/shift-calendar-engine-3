# AI Scheduler Architecture

The AI scheduler layer is an explainable orchestration boundary built on top of
the canonical deterministic scheduling engine in `workforce_core`.

It does not replace the canonical `SchedulerEngine`, `SchedulerRequest`,
`SchedulerResult`, roster constraints, or fairness evaluation. Instead, it
adapts those existing components into reviewable proposals for future Flutter
workflows.

## Design goals

- preserve the canonical scheduler as the single source of scheduling logic
- keep proposal generation deterministic and testable
- support multiple constraint plugins without coupling them to the UI
- expose structured explanations instead of opaque AI output
- require explicit human approval before saving or publishing
- allow multiple deterministic assistants to be simulated and compared

## Main contracts

### `AiSchedulerAssistant`

Creates an `AiScheduleProposal` from a canonical `SchedulerRequest`.

`DeterministicAiScheduler` is the default implementation. It delegates schedule
generation to the existing `SchedulerEngine` and delegates explanation creation
to an `AiSchedulerRuleEngine`.

### `AiScheduleProposal`

An immutable review model containing:

- the canonical `SchedulerResult`
- structured `AiScheduleExplanation` entries
- an explicit `requiresApproval` flag

The proposal never persists or publishes a schedule by itself.

### `AiSchedulerRuleEngine`

Converts a request and result into structured explanations for assignments,
unassigned slots, constraint outcomes, fairness score, and approval status.

The default implementation uses stable explanation codes so presentation code
can localize or group messages without parsing human-readable text.

### `AiConstraintPlugin`

Adds optional validation rules around generated assignments. Plugins receive an
immutable `AiConstraintContext` and return canonical `RosterViolation` values.

`AiConstraintPluginEngine` validates plugin identifiers at construction time and
runs plugins in their declared order. Plugin IDs must be non-empty and unique.

Plugins must be deterministic for the same context and must not mutate the
canonical schedule or perform persistence.

### `AiScheduleOptimizer`

Runs one or more assistants and returns an `AiScheduleSimulation` containing
reviewable proposals. The current optimizer is deterministic and preserves the
assistant order supplied by the composition root.

`AiScheduleSimulation.bestProposal` ranks proposals using the canonical schedule
evaluation score. This is comparison support only; approval remains a human
decision.

## Data flow

```text
SchedulerRequest
      |
      v
AiSchedulerAssistant
      |
      +--> canonical SchedulerEngine.generate(...)
      |
      +--> AiSchedulerRuleEngine.explain(...)
      v
AiScheduleProposal
      |
      +--> optional constraint-plugin review
      +--> optional multi-proposal simulation
      v
Flutter preview / compare / approve workflow
```

## Safety boundaries

The AI scheduler layer must not:

- introduce a second schedule aggregate
- duplicate canonical roster constraints or fairness calculations
- write to repositories directly
- publish to Google Calendar or external systems
- silently approve its own proposals
- depend on network-based generative AI for correctness

Any future generative assistant must remain an adapter behind the same contracts
and must produce a canonical `SchedulerResult` that is validated by the existing
constraint and evaluation engines.

## Testing expectations

Tests should remain deterministic and cover:

- stable proposal generation for identical requests
- immutable proposal and context collections
- unique and non-empty plugin IDs
- plugin execution order and aggregated violations
- structured explanation codes and approval requirement
- deterministic simulation ordering and best-proposal selection

## Flutter integration sequence

The first UI integration should be read-only:

1. create a scheduler application controller outside the widget tree
2. generate a proposal from canonical request data
3. display score, completeness, violations, and explanations
4. support proposal comparison without persistence
5. add explicit approve/reject actions
6. connect approval to canonical persistence only after controller tests pass

This sequence keeps presentation concerns separate from scheduling logic and
preserves the human-approval boundary.