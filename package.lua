return {
  name = "virgo-agent-toolkit/statsd",
  version = "0.1.0",
  dependencies = {
    "luvit/luvit@2",
    "luvit/tap@0.1",
    "rphillips/async@0.0.2",
  },
  files = {
    "*.lua",
    "!tests",
    "!lit-*",
  },
}
