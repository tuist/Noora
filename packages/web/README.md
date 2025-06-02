# Noora

[![Hex.pm](https://img.shields.io/hexpm/v/noora.svg)](https://hex.pm/packages/noora) [![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/noora/)

<!-- MDOC !-->

Noora is a component library for building web applications with Phoenix LiveView.

## Installation

To start, add `noora` to your list of dependencies in `mix.exs`:

```elixir
defp deps do
  [
    {:noora, "~> 0.1.0"}
  ]
end
```

Additionally, you need to add the stylesheet and scripts to your own assets.  
These come bundled with the package, so, assuming that you are using the default Phoenix setup, you can import them to your `assets/css/app.css` and `assets/js/app.js` files:

```css
/* assets/css/app.css */
@import "noora/noora.css";
```

```javascript
// assets/js/app.js
import Noora from "noora";

let liveSocket = new LiveSocket("/live", Socket, {
  // Your existing socket setup
  hooks: { ...Noora },
});
```

## Usage

Noora provides a set of Phoenix components that you can use in your LiveView templates.  
To see a list of available components, check the [documentation](https://hexdocs.pm/noora/).
