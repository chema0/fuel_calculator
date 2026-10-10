// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// If you have dependencies that try to import CSS, esbuild will generate a separate `app.css` file.
// To load it, simply add a second `<link>` to your `root.html.heex` file.

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import {hooks as colocatedHooks} from "phoenix-colocated/fuel_calculator"
import topbar from "../vendor/topbar"

// Mission menus use rendered options so they can open below their trigger.
function closeMissionSelect(dropdown, restoreFocus = false) {
  const menu = dropdown.querySelector("[data-select-menu]")
  const trigger = dropdown.querySelector("[data-select-trigger]")
  menu.hidden = true
  trigger.setAttribute("aria-expanded", "false")
  if (restoreFocus) trigger.focus()
}

function openMissionSelect(dropdown, focusOption = false, lastOption = false) {
  document.querySelectorAll("[data-mission-select]").forEach(other => {
    if (other !== dropdown) closeMissionSelect(other)
  })

  const menu = dropdown.querySelector("[data-select-menu]")
  menu.hidden = false
  dropdown.querySelector("[data-select-trigger]").setAttribute("aria-expanded", "true")

  if (focusOption) {
    const options = [...menu.querySelectorAll("[data-select-option]")]
    const selected = options.find(option => option.getAttribute("aria-selected") === "true")
    const target = lastOption ? options.at(-1) : selected || options[0]
    target?.focus()
  }
}

document.addEventListener("click", event => {
  const dropdown = event.target.closest("[data-mission-select]")
  const trigger = event.target.closest("[data-select-trigger]")
  const option = event.target.closest("[data-select-option]")

  if (trigger && dropdown) {
    if (dropdown.querySelector("[data-select-menu]").hidden) {
      openMissionSelect(dropdown)
    } else {
      closeMissionSelect(dropdown)
    }
  } else if (option && dropdown) {
    const input = dropdown.querySelector('input[type="hidden"]')
    input.value = option.dataset.selectValue
    dropdown.querySelector("[data-select-value]").textContent = option.textContent.trim()
    dropdown.querySelectorAll("[data-select-option]").forEach(item => {
      item.setAttribute("aria-selected", String(item === option))
    })
    input.dispatchEvent(new Event("change", {bubbles: true}))
    closeMissionSelect(dropdown, true)
  } else {
    document.querySelectorAll("[data-mission-select]").forEach(other => closeMissionSelect(other))
  }
})

document.addEventListener("keydown", event => {
  const dropdown = event.target.closest("[data-mission-select]")
  if (!dropdown) return

  const trigger = dropdown.querySelector("[data-select-trigger]")
  const menu = dropdown.querySelector("[data-select-menu]")
  const options = [...menu.querySelectorAll("[data-select-option]")]

  if (event.key === "Escape" && !menu.hidden) {
    event.preventDefault()
    closeMissionSelect(dropdown, true)
  } else if (event.target === trigger && ["ArrowDown", "ArrowUp"].includes(event.key)) {
    event.preventDefault()
    openMissionSelect(dropdown, true, event.key === "ArrowUp")
  } else if (event.target.matches("[data-select-option]")) {
    const index = options.indexOf(event.target)
    const next = {
      ArrowDown: Math.min(index + 1, options.length - 1),
      ArrowUp: Math.max(index - 1, 0),
      Home: 0,
      End: options.length - 1,
    }[event.key]

    if (next !== undefined) {
      event.preventDefault()
      options[next].focus()
    }
  }
})

document.addEventListener("focusin", event => {
  document.querySelectorAll("[data-mission-select]").forEach(dropdown => {
    if (!dropdown.contains(event.target)) closeMissionSelect(dropdown)
  })
})

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: {...colocatedHooks},
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
  window.addEventListener("phx:live_reload:attached", ({detail: reloader}) => {
    // Enable server log streaming to client.
    // Disable with reloader.disableServerLogs()
    reloader.enableServerLogs()

    // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
    //
    //   * click with "c" key pressed to open at caller location
    //   * click with "d" key pressed to open at function component definition location
    let keyDown
    window.addEventListener("keydown", e => keyDown = e.key)
    window.addEventListener("keyup", _e => keyDown = null)
    window.addEventListener("click", e => {
      if(keyDown === "c"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtCaller(e.target)
      } else if(keyDown === "d"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtDef(e.target)
      }
    }, true)

    window.liveReloader = reloader
  })
}
