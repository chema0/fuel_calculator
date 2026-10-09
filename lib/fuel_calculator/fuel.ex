defmodule FuelCalculator.Fuel do
  @moduledoc "Calculates the fuel to carry a spacecraft through an ordered flight path."

  alias FuelCalculator.Mission.Step

  @gravity %{earth: 9.807, moon: 1.62, mars: 3.711}
  @formula %{launch: {0.042, 33}, land: {0.033, 42}}

  @doc """
  Returns the total fuel in kilograms for a validated mission.

  Steps are processed from last to first because fuel for a later step must be
  carried through every earlier step.
  """
  @spec calculate_total(pos_integer(), [Step.t()]) :: non_neg_integer()
  def calculate_total(mass, steps) do
    Enum.reduce(Enum.reverse(steps), 0, fn step, fuel_for_later_steps ->
      fuel_for_later_steps + step_fuel(mass + fuel_for_later_steps, step)
    end)
  end

  @doc "Returns fuel for a single step, including the fuel needed to carry it."
  @spec step_fuel(pos_integer(), Step.t()) :: non_neg_integer()
  def step_fuel(mass, %Step{action: action, planet: planet}) do
    {factor, offset} = Map.fetch!(@formula, action)
    gravity = Map.fetch!(@gravity, planet)

    mass
    |> required_fuel(gravity, factor, offset)
    |> add_fuel_weight(gravity, factor, offset, 0)
  end

  defp add_fuel_weight(amount, _gravity, _factor, _offset, total) when amount <= 0,
    do: total

  defp add_fuel_weight(amount, gravity, factor, offset, total) do
    next = required_fuel(amount, gravity, factor, offset)
    add_fuel_weight(next, gravity, factor, offset, total + amount)
  end

  defp required_fuel(mass, gravity, factor, offset),
    do: floor(mass * gravity * factor - offset)
end
