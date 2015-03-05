--[[
Copyright 2015 Rackspace

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS-IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
--]]

require('luvit')(function(...)
  local Statsd = require('./statsd').Statsd
  local package = require('./package')
  local JSON = require('json')

  local options = {
    host = '127.0.0.1',
    port = 8125
  }

  print(string.format('luvit-statsd %s\n', package.version))
  print(string.format('Listening on %s:%d', options.host, options.port))

  local s = Statsd:new(options)
  s:bind()
  s:run()

  s:on('metrics', function(metrics)
    print(JSON.stringify(metrics))
  end)
end)

