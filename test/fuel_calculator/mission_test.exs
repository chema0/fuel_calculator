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

    test "rejects missing, zero, negative, fractional, and nonnumeric masses" do
      for mass <- [nil, "", "0", "-1", "1.5", "abc"] do
        changeset = Mission.changeset(%Mission{}, %{"mass" => mass, "steps" => [valid_step()]})
        refute changeset.valid?
        assert Keyword.has_key?(changeset.errors, :mass)
      end
    end

    test "rejects missing and unsupported maneuvers and planets" do
      for step <- [
            %{"action" => "", "planet" => "earth"},
            %{"action" => "orbit", "planet" => "earth"},
            %{"action" => "launch", "planet" => ""},
            %{"action" => "launch", "planet" => "venus"}
          ] do
        changeset = Mission.changeset(%Mission{}, %{"mass" => "100", "steps" => [step]})
        refute changeset.valid?
        assert [step_changeset] = Ecto.Changeset.get_change(changeset, :steps)
        assert step_changeset.errors != []
      end
    end
  end

  defp valid_step, do: %{"action" => "launch", "planet" => "earth"}
end
