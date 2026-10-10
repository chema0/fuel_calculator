defmodule FuelCalculator.FuelTest do
  use ExUnit.Case, async: true

  alias FuelCalculator.Fuel
  alias FuelCalculator.Mission.Step

  test "landing fuel includes fuel needed to carry fuel" do
    assert Fuel.step_fuel(28_801, %Step{action: :land, planet: :earth}) == 13_447
  end

  test "non-positive initial fuel requires no fuel" do
    assert Fuel.step_fuel(40, %Step{action: :land, planet: :earth}) == 0
  end

  test "formula floors exactly at the positive-fuel boundary" do
    assert Fuel.step_fuel(80, step(:launch, :earth)) == 0
    assert Fuel.step_fuel(81, step(:launch, :earth)) == 0
    assert Fuel.step_fuel(83, step(:launch, :earth)) == 1
  end

  test "a very large mass does not lose precision or overflow a float" do
    mass = 10 ** 310
    assert Fuel.step_fuel(mass, step(:launch, :earth)) > 0
  end

  test "Apollo 11 mission" do
    steps = [
      step(:launch, :earth),
      step(:land, :moon),
      step(:launch, :moon),
      step(:land, :earth)
    ]

    assert Fuel.calculate_total(28_801, steps) == 51_898
  end

  test "Mars mission" do
    steps = [
      step(:launch, :earth),
      step(:land, :mars),
      step(:launch, :mars),
      step(:land, :earth)
    ]

    assert Fuel.calculate_total(14_606, steps) == 33_388
  end

  test "passenger ship mission" do
    steps = [
      step(:launch, :earth),
      step(:land, :moon),
      step(:launch, :moon),
      step(:land, :mars),
      step(:launch, :mars),
      step(:land, :earth)
    ]

    assert Fuel.calculate_total(75_432, steps) == 212_161
  end

  defp step(action, planet), do: %Step{action: action, planet: planet}
end
