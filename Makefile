.DEFAULT_GOAL := help

.PHONY: help setup dev console test check assets

help:
	@printf 'Mission Fuel commands:\n'
	@printf '  make setup    Install dependencies and build assets\n'
	@printf '  make dev      Start the Phoenix server\n'
	@printf '  make console  Start Phoenix in IEx\n'
	@printf '  make test     Run the test suite\n'
	@printf '  make check    Run the precommit checks\n'
	@printf '  make assets   Rebuild CSS and JavaScript\n'

setup:
	mix setup

dev:
	mix phx.server

console:
	iex -S mix phx.server

test:
	mix test

check:
	mix precommit

assets:
	mix assets.build
