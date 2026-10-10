defmodule FuelCalculatorWeb.MissionLive do
  use FuelCalculatorWeb, :live_view

  alias FuelCalculator.{Fuel, Mission}

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
    changeset = Mission.changeset(%Mission{}, params)

    total =
      case Ecto.Changeset.apply_action(changeset, :validate) do
        {:ok, %Mission{steps: [_ | _] = steps, mass: mass}} ->
          Fuel.calculate_total(mass, steps)

        _ ->
          nil
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

  attr :field, Phoenix.HTML.FormField, required: true
  attr :id, :string, required: true
  attr :label, :string, required: true
  attr :options, :list, required: true

  defp mission_select(assigns) do
    selected_value = to_string(assigns.field.value)

    selected_label =
      Enum.find_value(assigns.options, "Select an option", fn {label, value} ->
        if to_string(value) == selected_value, do: to_string(label)
      end)

    errors =
      if Phoenix.Component.used_input?(assigns.field) do
        Enum.map(assigns.field.errors, &FuelCalculatorWeb.CoreComponents.translate_error/1)
      else
        []
      end

    assigns = assign(assigns, selected_label: selected_label, errors: errors)

    ~H"""
    <div id={"#{@id}-dropdown"} data-mission-select>
      <span id={"#{@id}-label"} class="mb-1 block text-xs font-medium text-slate-500">
        {@label}
      </span>
      <.input field={@field} id={@id} type="hidden" />
      <div class="relative">
        <button
          id={"#{@id}-trigger"}
          type="button"
          data-select-trigger
          aria-haspopup="listbox"
          aria-expanded="false"
          aria-controls={"#{@id}-options"}
          aria-labelledby={"#{@id}-label #{@id}-value"}
          aria-invalid={@errors != []}
          aria-describedby={if(@errors != [], do: "#{@id}-error")}
          class={[
            "flex h-11 w-full cursor-pointer items-center justify-between gap-2 rounded-sm border bg-[#f8fafb] px-3 text-left text-sm font-semibold text-[#152237] outline-none transition hover:border-[#7897a7] focus-visible:border-[#317488] focus-visible:ring-3 focus-visible:ring-[#53adbe33] max-sm:text-xs",
            if(@errors != [], do: "border-[#bb4b41]", else: "border-[#b7c5ce]")
          ]}
        >
          <span id={"#{@id}-value"} data-select-value class="truncate">{@selected_label}</span>
          <.icon name="hero-chevron-down" class="size-4 shrink-0 text-[#5e7482]" />
        </button>
        <div
          id={"#{@id}-options"}
          data-select-menu
          role="listbox"
          aria-labelledby={"#{@id}-label"}
          class="absolute top-full right-0 left-0 z-30 mt-1 overflow-hidden rounded-sm border border-[#b7c5ce] bg-white p-1 shadow-[0_12px_30px_-12px_#192a3f66]"
          hidden
        >
          <button
            :for={{option_label, option_value} <- @options}
            type="button"
            role="option"
            data-select-option
            data-select-value={option_value}
            aria-selected={to_string(option_value) == to_string(@field.value)}
            class={[
              "block w-full cursor-pointer rounded-sm px-3 py-2 text-left text-sm text-[#152237] outline-none transition hover:bg-[#e8f3f5] focus-visible:bg-[#e8f3f5] max-sm:text-xs",
              to_string(option_value) == to_string(@field.value) && "bg-[#eef5f6] font-semibold"
            ]}
          >
            {option_label}
          </button>
        </div>
      </div>
      <div :if={@errors != []} id={"#{@id}-error"} class="mt-1.5 text-sm text-rose-600">
        <p :for={error <- @errors}>{error}</p>
      </div>
    </div>
    """
  end

  defp format_number(number) do
    number
    |> Integer.to_string()
    |> String.reverse()
    |> String.replace(~r/.{3}(?=.)/, "\\0,")
    |> String.reverse()
  end
end
