defmodule FuelCalculatorWeb.MissionLiveTest do
  use FuelCalculatorWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "opens with the editable Apollo mission", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#mission-form")
    assert has_element?(view, "#spacecraft-mass[value='28801']")
    assert has_element?(view, "#flight-step-3")
    assert has_element?(view, "#fuel-total", "51,898")
  end

  test "updates the estimate when the mass changes", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> form("#mission-form", mission: %{mass: "14606"})
    |> render_change()

    refute has_element?(view, "#fuel-total", "51,898")
    assert has_element?(view, "#fuel-total")
  end

  test "updates the estimate when the path changes", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    render_change(view, "validate", %{
      "mission" => %{
        "mass" => "14606",
        "steps" => %{
          "0" => %{"action" => "launch", "planet" => "earth"},
          "1" => %{"action" => "land", "planet" => "mars"},
          "2" => %{"action" => "launch", "planet" => "mars"},
          "3" => %{"action" => "land", "planet" => "earth"}
        }
      }
    })

    assert has_element?(view, "#step-planet-1[value='mars']")
    assert has_element?(view, "#step-planet-1-trigger", "Mars")
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

    view
    |> form("#mission-form", mission: %{mass: "28801"})
    |> render_change()

    assert has_element?(view, "#fuel-total", "51,898")
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
