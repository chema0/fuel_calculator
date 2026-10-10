defmodule FuelCalculator.MissionsTest do
  use ExUnit.Case, async: true

  alias FuelCalculator.Missions

  describe "calculate_fuel/1" do
    test "returns the fuel for a valid mission" do
      changeset = Missions.change_mission(valid_attrs())

      assert {:ok, 51_898} = Missions.calculate_fuel(changeset)
    end

    test "returns the changeset when the mission is invalid" do
      changeset = Missions.change_mission(Map.put(valid_attrs(), "mass", "0"))

      assert {:error, invalid_changeset} = Missions.calculate_fuel(changeset)
      assert Keyword.has_key?(invalid_changeset.errors, :mass)
    end

    test "preserves the numeric order of more than ten flight steps" do
      steps =
        0..10
        |> Map.new(fn index ->
          planet = if(index == 10, do: "mars", else: "earth")
          {Integer.to_string(index), %{"action" => "launch", "planet" => planet}}
        end)

      changeset = Missions.change_mission(%{"mass" => "1000", "steps" => steps})
      {:ok, mission} = Ecto.Changeset.apply_action(changeset, :validate)

      assert Enum.map(mission.steps, & &1.planet) == List.duplicate(:earth, 10) ++ [:mars]
    end
  end

  defp valid_attrs do
    %{
      "mass" => "28801",
      "steps" => %{
        "0" => %{"action" => "launch", "planet" => "earth"},
        "1" => %{"action" => "land", "planet" => "moon"},
        "2" => %{"action" => "launch", "planet" => "moon"},
        "3" => %{"action" => "land", "planet" => "earth"}
      }
    }
  end
end
