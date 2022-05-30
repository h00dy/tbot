# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :tbot, TbotWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "h1fb/6WcV5FJcER1l1kAGdqc2JNGMhDY33eQMfs6NZm5X4C1zdAxplg6hZlvJ3nA",
  render_errors: [view: TbotWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Tbot.PubSub,
  live_view: [signing_salt: "Xw/yiWb1"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
