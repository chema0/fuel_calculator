defmodule FuelCalculatorWeb.MissionLive do
  use FuelCalculatorWeb, :live_view

  alias FuelCalculator.Missions
  import FuelCalculatorWeb.MissionComponents

  @apollo_steps [
    %{"action" => "launch", "planet" => "earth"},
    %{"action" => "land", "planet" => "moon"},
    %{"action" => "launch", "planet" => "moon"},
    %{"action" => "land", "planet" => "earth"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    params = %{"mass" => "28801", "steps" => index_steps(@apollo_steps)}

    {:ok,
     socket
     |> assign(:page_title, "Mission fuel calculator")
     |> assign_mission(params)}
  end

  @impl true
  def handle_event("validate", %{"mission" => params}, socket) do
    {:noreply, assign_mission(socket, params)}
  end

  @impl true
  def handle_event("add_step", _params, socket) do
    params = socket.assigns.params
    steps = ordered_steps(params) ++ [%{"action" => "launch", "planet" => "earth"}]
    {:noreply, assign_mission(socket, Map.put(params, "steps", index_steps(steps)))}
  end

  @impl true
  def handle_event("remove_step", %{"index" => index}, socket) do
    params = socket.assigns.params

    steps =
      params
      |> ordered_steps()
      |> Enum.with_index()
      |> Enum.reject(fn {_step, position} -> Integer.to_string(position) == index end)
      |> Enum.map(&elem(&1, 0))

    {:noreply, assign_mission(socket, Map.put(params, "steps", index_steps(steps)))}
  end

  defp assign_mission(socket, params) do
    params = Map.put_new(params, "steps", %{})
    changeset = Missions.change_mission(params)

    total =
      case Missions.calculate_fuel(changeset) do
        {:ok, fuel} -> fuel
        {:error, _changeset} -> nil
      end

    socket
    |> assign(:params, params)
    |> assign(:form, to_form(changeset, as: :mission))
    |> assign(:total, total)
    |> assign(:step_count, length(ordered_steps(params)))
  end

  defp ordered_steps(%{"steps" => steps}) when is_map(steps) do
    steps
    |> Enum.sort_by(fn {index, _step} ->
      case Integer.parse(index) do
        {position, ""} -> position
        _ -> 0
      end
    end)
    |> Enum.map(&elem(&1, 1))
  end

  defp ordered_steps(_params), do: []

  defp index_steps(steps) do
    steps
    |> Enum.with_index()
    |> Map.new(fn {step, index} -> {Integer.to_string(index), step} end)
  end
end
