defmodule FuelCalculator.Mission.Step do
  @moduledoc "A launch or landing at a supported planet."

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :action, Ecto.Enum, values: [:launch, :land]
    field :planet, Ecto.Enum, values: [:earth, :moon, :mars]
  end

  @type t :: %__MODULE__{
          action: :launch | :land | nil,
          planet: :earth | :moon | :mars | nil
        }

  @doc "Validates an individual flight step."
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(step, attrs) do
    step
    |> cast(attrs, [:action, :planet])
    |> validate_required([:action, :planet])
  end
end
