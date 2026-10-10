defmodule FuelCalculatorWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use FuelCalculatorWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="border-b border-[#cdd7dd]">
      <div class="mx-auto flex min-h-16 max-w-[1440px] items-center justify-between gap-4 px-4 sm:px-6 lg:min-h-[76px] lg:px-12">
        <a
          href="/"
          class="inline-flex items-center gap-3 text-[1.05rem] font-extrabold tracking-[-.04em] text-[#152237] focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-[#3b9aad]"
          aria-label="Mission Fuel home"
        >
          <span
            class="relative inline-grid size-7 place-items-center rounded-full border-[1.5px] border-[#152237]"
            aria-hidden="true"
          >
            <span class="size-2 rounded-full bg-[#ff835d]"></span>
            <span class="absolute -right-0.5 -top-0.5 size-1.5 rounded-full bg-[#152237]"></span>
          </span>
          <span>Mission Fuel</span>
        </a>
        <span class="hidden text-xs tracking-wide text-[#5e6c79] sm:inline">
          A flight planning instrument
        </span>
      </div>
    </header>

    <main class="mx-auto max-w-[1440px] px-4 pb-8 sm:px-6 lg:px-12 lg:pb-20">
      {render_slot(@inner_block)}
    </main>

    <footer class="mx-auto max-w-[1440px] border-t border-[#cdd7dd] px-4 py-6 text-xs text-[#5e6c79] sm:px-6 lg:px-12">
      Mission Fuel / Earth, Moon and Mars
    </footer>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end
end
