# Mission Fuel

A Phoenix LiveView calculator for the [Elixir full-stack challenge](https://hi-elixirator.notion.site/elixir-challenge). Plan launches and landings on Earth, the Moon, and Mars, and see fuel requirements update immediately.

## Run locally

Run `make setup`, then `make dev`. Open [localhost:4000](http://localhost:4000). No database is required. Run `make` to see all available commands.

Use `make test` for the calculator and LiveView tests, or `make check` for the full precommit check. Each target wraps the corresponding Mix command, which can also be run directly.

## Calculation

For a launch, fuel is `floor(mass * gravity * 0.042 - 33)`. For a landing, it is `floor(mass * gravity * 0.033 - 42)`. Each positive result is treated as additional mass and passed through the same formula until the next result is zero or negative.

The flight path is calculated in reverse order. Fuel for a later step is added to the spacecraft mass before calculating each earlier step, because the earlier steps must carry it. Inputs and results are whole kilograms. The calculator starts with the Apollo 11 example, which requires 51,898 kg of fuel.
