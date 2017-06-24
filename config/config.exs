use Mix.Config

config :payjp,
  locale: "ja",
  httpoison_options: [
    timeout: 30000,
    recv_timeout: 80000,
  ]