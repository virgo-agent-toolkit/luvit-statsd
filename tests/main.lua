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


local function createMetrics()
  local counters = {}
  local gauges = {}
  local timers = {}
  local timer_counters = {}
  local sets = {}
  local pctThreshold = nil
  local metrics = {
    counters = counters,
    gauges = gauges,
    timers = timers,
    timer_counters = timer_counters,
    sets = sets,
    pctThreshold = pctThreshold
  }
  return metrics
end

require('tap')(function(test)
  local Statsd = require('..').Statsd
  local misc = require('../misc')

  test('test counters has stats count', function(expect)
    local sd = Statsd:new()
    local metrics = createMetrics()
    metrics.counters['a'] = 2
    sd:_processMetrics(metrics, expect(function(metrics)
      assert(metrics.counters['a'] == 2)
    end))
  end)

  test('test has correct rate', function(expect)
    local sd = Statsd:new({metrics_interval = 100})
    local metrics = createMetrics()
    metrics.counters['a'] = 2
    sd:_processMetrics(metrics, expect(function(metrics)
      assert(metrics.counter_rates['a'] == 20)
    end))
  end)

  test('test handle empty', function(expect)
    local sd = Statsd:new({metrics_interval = 100})
    local metrics = createMetrics()
    metrics.timers['a'] = {}
    metrics.timer_counters['a'] = 0
    sd:_processMetrics(metrics, expect(function(metrics)
      assert(metrics.counter_rates['a'] == nil)
    end))
  end)

  test('test handle empty', function(expect)
    local sd = Statsd:new({metrics_interval = 100})
    local metrics = createMetrics()
    metrics.timers['a'] = {}
    metrics.timer_counters['a'] = 0
    sd:_processMetrics(metrics, expect(function(metrics)
      assert(metrics.counter_rates['a'] == nil)
    end))
  end)

  test('test single time', function(expect)
    local sd = Statsd:new({metrics_interval = 100})
    local metrics = createMetrics()
    metrics.timers['a'] = {100}
    metrics.timer_counters['a'] = 1
    sd:_processMetrics(metrics, expect(function(metrics)
      local timer_data = metrics.timer_data['a']
      assert(0 == timer_data.std)
      assert(100 == timer_data.upper)
      assert(100 == timer_data.lower)
      assert(1 == timer_data.count)
      assert(10 == timer_data.count_ps)
      assert(100 == timer_data.sum)
      assert(100 == timer_data.median)
      assert(100 == timer_data.mean)
    end))
  end)

  test('test multiple times', function(expect)
    local sd = Statsd:new({metrics_interval = 100})
    local metrics = createMetrics()
    metrics.timers['a'] = {100, 200, 300}
    metrics.timer_counters['a'] = 3
    sd:_processMetrics(metrics, expect(function(metrics)
      local timer_data = metrics.timer_data['a']
      assert(81.65 == misc.round(timer_data.std, 2))
      assert(300 == timer_data.upper)
      assert(100 == timer_data.lower)
      assert(3 == timer_data.count)
      assert(30 == timer_data.count_ps)
      assert(600 == timer_data.sum)
      assert(200 == timer_data.mean)
      assert(200 == timer_data.median)
    end))
  end)

  test('test timers single time single percentile', function(expect)
    local sd = Statsd:new({metrics_interval = 100})
    local metrics = createMetrics()
    metrics.timers['a'] = {100}
    metrics.timer_counters['a'] = 1
    metrics.pctThreshold = { 90 }
    sd:_processMetrics(metrics, expect(function(metrics)
      local timer_data = metrics.timer_data['a']
      assert(100 == timer_data.mean_90)
      assert(100 == timer_data.upper_90)
      assert(100 == timer_data.sum_90)
    end))
  end)

  test('test timers single time multiple percentiles', function(expect)
    local sd = Statsd:new({metrics_interval = 100})
    local metrics = createMetrics()
    metrics.timers['a'] = {100}
    metrics.timer_counters['a'] = 1
    metrics.pctThreshold = { 90, 80 }
    sd:_processMetrics(metrics, expect(function(metrics)
      local timer_data = metrics.timer_data['a']
      assert(100 == timer_data.mean_90)
      assert(100 == timer_data.upper_90)
      assert(100 == timer_data.sum_90)
      assert(100 == timer_data.mean_80)
      assert(100 == timer_data.upper_80)
      assert(100 == timer_data.sum_80)
    end))
  end)

  test('test timers multiple times single percentiles', function(expect)
    local sd = Statsd:new({metrics_interval = 100})
    local metrics = createMetrics()
    metrics.timers['a'] = {100, 200, 300}
    metrics.timer_counters['a'] = 3
    metrics.pctThreshold = { 90 }
    sd:_processMetrics(metrics, expect(function(metrics)
      local timer_data = metrics.timer_data['a']
      assert(200 == timer_data.mean_90)
      assert(300 == timer_data.upper_90)
      assert(600 == timer_data.sum_90)
    end))
  end)

  test('test timers multiple times multiple percentiles', function(expect)
    local sd = Statsd:new({metrics_interval = 100})
    local metrics = createMetrics()
    metrics.timers['a'] = {100, 200, 300}
    metrics.timer_counters['a'] = 3
    metrics.pctThreshold = { 90, 80 }
    sd:_processMetrics(metrics, expect(function(metrics)
      local timer_data = metrics.timer_data['a']
      assert(200 == timer_data.mean_90)
      assert(300 == timer_data.upper_90)
      assert(600 == timer_data.sum_90)
      assert(150 == timer_data.mean_80)
      assert(200 == timer_data.upper_80)
      assert(300 == timer_data.sum_80)
    end))
  end)

  test('test timers sampled times', function(expect)
    local sd = Statsd:new({metrics_interval = 100})
    local metrics = createMetrics()
    metrics.timers['a'] = {100, 200, 300}
    metrics.timer_counters['a'] = 50
    metrics.pctThreshold = { 90, 80 }
    sd:_processMetrics(metrics, expect(function(metrics)
      local timer_data = metrics.timer_data['a']
      assert(50 == timer_data.count)
      assert(500 == timer_data.count_ps)
      assert(200 == timer_data.mean_90)
      assert(300 == timer_data.upper_90)
      assert(600 == timer_data.sum_90)
      assert(150 == timer_data.mean_80)
      assert(200 == timer_data.upper_80)
      assert(300 == timer_data.sum_80)
    end))
  end)

  test('test timers single time single top percentile', function(expect)
    local sd = Statsd:new({metrics_interval = 100})
    local metrics = createMetrics()
    metrics.timers['a'] = {100}
    metrics.timer_counters['a'] = 1
    metrics.pctThreshold = { -10 }
    sd:_processMetrics(metrics, expect(function(metrics)
      local timer_data = metrics.timer_data['a']
      assert(100 == timer_data.mean_top10)
      assert(100 == timer_data.lower_top10)
      assert(100 == timer_data.sum_top10)
    end))
  end)

  test('test timers multiple times single top percentile', function(expect)
    local sd = Statsd:new({metrics_interval = 100})
    local metrics = createMetrics()
    metrics.timers['a'] = {10, 10, 10, 10, 10, 10, 10, 10, 100, 200}
    metrics.timer_counters['a'] = 10
    metrics.pctThreshold = { -20 }
    sd:_processMetrics(metrics, expect(function(metrics)
      local timer_data = metrics.timer_data['a']
      assert(150 == timer_data.mean_top20);
      assert(100 == timer_data.lower_top20);
      assert(300 == timer_data.sum_top20);
    end))
  end)

  test('test statsd metrics exist', function(expect)
    local sd = Statsd:new({metrics_interval = 100})
    local metrics = createMetrics()
    sd:_processMetrics(metrics, expect(function(metrics)
      assert(metrics.statsd_metrics.processing_time ~= nil)
    end))
  end)
end)
