defmodule FuelCalculator.Mission do
  @moduledoc "Validates the temporary mission entered in the calculator."

  use Ecto.Schema
  import Ecto.Changeset

  alias FuelCalculator.Mission.Step

  @primary_key false
  embedded_schema do
    field :mass, :integer
    embeds_many :steps, Step, on_replace: :delete
  end

  @type t :: %__MODULE__{mass: integer() | nil, steps: [Step.t()]}

  @doc "Builds a changeset for a spacecraft mass and ordered flight steps."
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(mission, attrs) do
    mission
    |> cast(attrs, [:mass])
    |> validate_required([:mass])
    |> validate_number(:mass, greater_than: 0)
    |> cast_embed(:steps, with: &Step.changeset/2, required: true)
  end
end
