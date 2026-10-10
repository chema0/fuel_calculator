# Mission Fuel — Claude Code instructions

Read [AGENTS.md](AGENTS.md) before changing code. Its project rules take precedence over the general guidance in the skills below.

This is a Phoenix 1.8 LiveView fuel calculator. `FuelCalculator.Fuel` calculates fuel, `FuelCalculator.Mission` and `FuelCalculator.Mission.Step` validate an in-memory mission with Ecto embedded schemas, and `FuelCalculatorWeb.MissionLive` handles the UI. The app has no database, Repo, Oban, authentication, or external HTTP integration. Do not introduce those to follow a generic skill example.

## Project skills

The 19 skills from [elixir-phoenix-guide](https://github.com/j-morgan6/elixir-phoenix-guide) v2.4.0 live in `.claude/skills/`. Read the relevant `SKILL.md` before work in its area:

- Elixir code: `elixir-essentials`
- LiveView or HEEx: `phoenix-liveview-essentials`
- Embedded schemas and changesets: `ecto-essentials`; use `ecto-changeset-patterns` or `ecto-nested-associations` for complex forms
- Tests: `testing-essentials`
- Refactoring: `code-quality`
- Security-sensitive code: `security-essentials`
- OTP, uploads, PubSub, telemetry, deployment, channels, JSON APIs, authorization, authentication, or Oban: the corresponding skill when that feature is actually involved

The imported skills contain generic examples. Follow the existing app and `AGENTS.md` when an example assumes a database, different project layout, or different testing style. The upstream Claude hooks are not installed as part of this project-local skill set.

## Commands

- `make setup` — install and build dependencies
- `make dev` — start the Phoenix server
- `mix test` — run tests
- `mix precommit` — required final check; compiles with warnings as errors, formats, and tests
- `bash .claude/elixir-phoenix-guide/scripts/run_analysis.sh` — optional code quality analysis

Reference material is in `.claude/elixir-phoenix-guide/reference/`. The upstream license is in `.claude/elixir-phoenix-guide/LICENSE`.
