defmodule FuelCalculatorWeb.MissionLive do
  use FuelCalculatorWeb, :live_view

  alias FuelCalculator.Missions
  import FuelCalculatorWeb.MissionComponents

  @samples [
    %{
      id: "apollo",
      name: "Apollo 11",
      mass: "28801",
      steps: [
        %{"action" => "launch", "planet" => "earth"},
        %{"action" => "land", "planet" => "moon"},
        %{"action" => "launch", "planet" => "moon"},
        %{"action" => "land", "planet" => "earth"}
      ]
    },
    %{
      id: "mars",
      name: "Mars mission",
      mass: "14606",
      steps: [
        %{"action" => "launch", "planet" => "earth"},
        %{"action" => "land", "planet" => "mars"},
        %{"action" => "launch", "planet" => "mars"},
        %{"action" => "land", "planet" => "earth"}
      ]
    },
    %{
      id: "passenger",
      name: "Passenger ship",
      mass: "75432",
      steps: [
        %{"action" => "launch", "planet" => "earth"},
        %{"action" => "land", "planet" => "moon"},
        %{"action" => "launch", "planet" => "moon"},
        %{"action" => "land", "planet" => "mars"},
        %{"action" => "launch", "planet" => "mars"},
        %{"action" => "land", "planet" => "earth"}
      ]
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    apollo = hd(@samples)

    {:ok,
     socket
     |> assign(:page_title, "Mission fuel calculator")
     |> assign(:samples, @samples)
     |> assign(:selected_sample, apollo.id)
     |> assign_mission(sample_params(apollo))}
  end

  @impl true
  def handle_event("validate", %{"mission" => params}, socket) do
    {:noreply, socket |> assign(:selected_sample, nil) |> assign_mission(params)}
  end

  @impl true
  def handle_event("load_sample", %{"sample" => sample_id}, socket) do
    case Enum.find(@samples, &(&1.id == sample_id)) do
      nil ->
        {:noreply, socket}

      sample ->
        {:noreply,
         socket
         |> assign(:selected_sample, sample.id)
         |> assign_mission(sample_params(sample))}
    end
  end

  @impl true
  def handle_event("add_step", _params, socket) do
    params = socket.assigns.params
    steps = ordered_steps(params) ++ [%{"action" => "launch", "planet" => "earth"}]

    {:noreply,
     socket
     |> assign(:selected_sample, nil)
     |> assign_mission(Map.put(params, "steps", index_steps(steps)))}
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

    {:noreply,
     socket
     |> assign(:selected_sample, nil)
     |> assign_mission(Map.put(params, "steps", index_steps(steps)))}
  end

  defp sample_params(sample),
    do: %{"mass" => sample.mass, "steps" => index_steps(sample.steps)}

  defp assign_mission(socket, params) do
    params = Map.put_new(params, "steps", %{})
    changeset = Missions.change_mission(params)

    {total, changeset} =
      case Missions.calculate_fuel(changeset) do
        {:ok, fuel} -> {fuel, changeset}
        {:error, invalid_changeset} -> {nil, invalid_changeset}
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
