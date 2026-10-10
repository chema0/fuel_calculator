defmodule FuelCalculator.MissionTest do
  use ExUnit.Case, async: true

  alias FuelCalculator.Mission

  describe "changeset/2" do
    test "accepts a positive mass and a maneuver" do
      changeset =
        Mission.changeset(%Mission{}, %{
          "mass" => "28801",
          "steps" => %{"0" => %{"action" => "launch", "planet" => "earth"}}
        })

      assert changeset.valid?
    end

    test "rejects a route without maneuvers" do
      changeset = Mission.changeset(%Mission{}, %{"mass" => "28801", "steps" => %{}})

      refute changeset.valid?
      assert Keyword.has_key?(changeset.errors, :steps)
    end
  end
end
