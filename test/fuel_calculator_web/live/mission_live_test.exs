defmodule FuelCalculatorWeb.MissionLiveTest do
  use FuelCalculatorWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "opens with the editable Apollo mission", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#mission-form")
    assert has_element?(view, "#spacecraft-mass[value='28801']")
    assert has_element?(view, "#flight-step-3")
    assert has_element?(view, "select#step-action-0[name='mission[steps][0][action]']")
    assert has_element?(view, "select#step-planet-0[name='mission[steps][0][planet]']")
    assert has_element?(view, "#fuel-total", "51,898")
  end

  test "loads each sample through the editable calculator", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    for {sample, mass, final_step, total} <- [
          {"apollo", "28801", 3, "51,898"},
          {"mars", "14606", 3, "33,388"},
          {"passenger", "75432", 5, "212,161"}
        ] do
      view |> element("#sample-#{sample}") |> render_click()

      assert has_element?(view, "#sample-#{sample}[aria-pressed='true']")
      assert has_element?(view, "#spacecraft-mass[value='#{mass}']")
      assert has_element?(view, "#flight-step-#{final_step}")
      refute has_element?(view, "#flight-step-#{final_step + 1}")
      assert has_element?(view, "#fuel-total", total)
    end

    refute has_element?(view, "select#step-planet-1 option[value='mars'][selected]")
    assert has_element?(view, "select#step-planet-3 option[value='mars'][selected]")
  end

  test "editing a sample clears its selection", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#sample-mars") |> render_click()

    view
    |> form("#mission-form", mission: %{mass: "15000"})
    |> render_change()

    refute has_element?(view, "#sample-mars[aria-pressed='true']")
    assert has_element?(view, "#spacecraft-mass[value='15000']")
  end

  test "updates the estimate when the mass changes", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> form("#mission-form", mission: %{mass: "14606"})
    |> render_change()

    assert has_element?(view, "#fuel-total", "25,765")
  end

  test "updates the estimate when the path changes", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> form("#mission-form",
      mission: %{
        mass: "14606",
        steps: %{
          "0" => %{action: "launch", planet: "earth"},
          "1" => %{action: "land", planet: "mars"},
          "2" => %{action: "launch", planet: "mars"},
          "3" => %{action: "land", planet: "earth"}
        }
      }
    )
    |> render_change()

    assert has_element?(view, "select#step-planet-1 option[value='mars'][selected]")
    assert has_element?(view, "#fuel-total", "33,388")
  end

  test "adds and removes flight steps", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#add-step") |> render_click()
    assert has_element?(view, "#flight-step-4")

    view |> element("#remove-step-4") |> render_click()
    refute has_element?(view, "#flight-step-4")
    assert has_element?(view, "#fuel-total", "51,898")
  end

  test "shows validation errors and waits for a valid mass", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> form("#mission-form", mission: %{mass: "0"})
    |> render_change()

    assert has_element?(view, "#fuel-prompt")
    refute has_element?(view, "#fuel-total")
    assert has_element?(view, "#mission-form", "must be greater than 0")

    view
    |> form("#mission-form", mission: %{mass: "28801"})
    |> render_change()

    assert has_element?(view, "#fuel-total", "51,898")
  end

  test "recovers from an empty path when a maneuver is added", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    for _ <- 1..4 do
      view |> element("#remove-step-0") |> render_click()
    end

    view |> element("#add-step") |> render_click()

    assert has_element?(view, "#flight-step-0")
    assert has_element?(view, "#fuel-total")
  end

  test "shows an empty path prompt after all steps are removed", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    for _ <- 1..4 do
      view |> element("#remove-step-0") |> render_click()
    end

    assert has_element?(view, "#empty-flight-path")
    assert has_element?(view, "#fuel-prompt")
  end
end
