defmodule FuelCalculatorWeb.MissionComponents do
  @moduledoc "Components for the mission editor and its fuel estimate."

  use FuelCalculatorWeb, :html

  attr :step_form, Phoenix.HTML.Form, required: true
  attr :step_count, :integer, required: true

  def flight_step(assigns) do
    ~H"""
    <div
      id={"flight-step-#{@step_form.index}"}
      class={[
        "relative grid grid-cols-[2rem_minmax(0,1fr)_1.8rem] gap-2 sm:grid-cols-[2.7rem_minmax(0,1fr)_2.25rem] sm:gap-4",
        @step_form.index > 0 && "pt-5"
      ]}
    >
      <div class="relative flex justify-center pt-7 sm:pt-[1.625rem]" aria-hidden="true">
        <span
          :if={@step_form.index < @step_count - 1}
          class="absolute top-[3.75rem] bottom-[-2.875rem] left-1/2 w-px -translate-x-1/2 bg-[#b8c8d1]"
        >
        </span>
        <span class="relative z-10 grid size-[1.8rem] place-items-center rounded-full bg-[#152237] text-[.65rem] font-extrabold text-white sm:size-8">
          {String.pad_leading(Integer.to_string(@step_form.index + 1), 2, "0")}
        </span>
      </div>
      <div class="grid grid-cols-2 gap-2 border-b border-[#e0e7eb] pb-5 sm:gap-3 [&>div]:mb-0">
        <.input
          field={@step_form[:action]}
          id={"step-action-#{@step_form.index}"}
          type="select"
          label="Maneuver"
          options={[Launch: :launch, Land: :land]}
        />
        <.input
          field={@step_form[:planet]}
          id={"step-planet-#{@step_form.index}"}
          type="select"
          label="At"
          options={[Earth: :earth, Moon: :moon, Mars: :mars]}
        />
      </div>
      <button
        id={"remove-step-#{@step_form.index}"}
        type="button"
        phx-click="remove_step"
        phx-value-index={@step_form.index}
        aria-label={"Remove step #{@step_form.index + 1}"}
        class="mt-5 grid h-11 w-full place-items-center text-[#8795a1] transition hover:bg-[#fff0eb] hover:text-[#a93b2c] focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#3b9aad]"
      >
        <.icon name="hero-x-mark" class="size-5" />
      </button>
    </div>
    """
  end

  attr :total, :integer, default: nil

  def fuel_result(assigns) do
    ~H"""
    <div
      id="fuel-result"
      class="border-t border-[#425b70] px-6 pt-8 pb-9 md:border-t-0 lg:border-t lg:px-10"
    >
      <div class="flex items-start justify-between gap-4">
        <div>
          <p class="m-0 text-xs font-bold uppercase tracking-[.15em] text-[#9fe5ed]">
            Calculated fuel mass
          </p>
          <h2 id="result-heading" class="mt-2 mb-0 text-xl font-semibold tracking-[-.03em]">
            Required for this route
          </h2>
        </div>
        <span class="inline-flex items-center gap-2 whitespace-nowrap text-xs text-[#b4c6cf]">
          <span class="size-1.5 rounded-full bg-[#ff835d] shadow-[0_0_0_4px_#ff835d21]"></span>
          Live estimate
        </span>
      </div>
      <div
        :if={@total != nil}
        id="fuel-total"
        class="my-7 flex items-baseline gap-3 whitespace-nowrap"
        aria-live="polite"
      >
        <span class="text-[clamp(3.35rem,5.8vw,6.4rem)] leading-none font-[760] tracking-[-.085em] tabular-nums">
          {format_number(@total)}
        </span>
        <span class="text-xl font-semibold text-[#9fe5ed]">kg</span>
      </div>
      <div :if={@total == nil} id="fuel-prompt" class="my-8" aria-live="polite">
        <strong class="block text-2xl tracking-tight">Awaiting a valid route</strong>
        <p class="text-sm text-[#b4c6cf]">Enter a positive mass and at least one maneuver.</p>
      </div>
      <div class="flex items-start gap-4 border-t border-[#3a4e60] pt-5">
        <span class="mt-2 h-0.5 w-7 shrink-0 bg-[#ff835d]"></span>
        <p class="m-0 max-w-sm text-xs leading-relaxed text-[#a9bcc9]">
          Fuel for later maneuvers adds weight to every earlier one. The estimate includes that carried fuel.
        </p>
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
