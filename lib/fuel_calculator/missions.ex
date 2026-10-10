defmodule FuelCalculator.Missions do
  @moduledoc "The public interface for validating missions and calculating their fuel needs."

  alias FuelCalculator.{Fuel, Mission}

  @doc "Builds a changeset for a temporary mission."
  @spec change_mission(map()) :: Ecto.Changeset.t()
  def change_mission(attrs), do: Mission.changeset(%Mission{}, attrs)

  @doc "Validates a mission changeset and calculates its fuel requirement."
  @spec calculate_fuel(Ecto.Changeset.t()) ::
          {:ok, non_neg_integer()} | {:error, Ecto.Changeset.t()}
  def calculate_fuel(changeset) do
    case Ecto.Changeset.apply_action(changeset, :validate) do
      {:ok, %Mission{mass: mass, steps: steps}} ->
        {:ok, Fuel.calculate_total(mass, steps)}

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
