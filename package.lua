return {
  name = "virgo-agent-toolkit/statsd",
  version = "0.1.0",
  dependencies = {
    "luvit/luvit@1.9.4",
    "rphillips/async@0.0.2",
  },
  files = {
    "*.lua",
    "!tests",
    "!lit-*",
  },
}
