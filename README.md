lua-benchmarker
==

A micro benchmarker for lua code.

Synopsis
--

```lua
local benchmarker = require 'benchmarker'

benchmarker.new({
    ["insert append"] = function ()
        local arr = {}
        for i=1,1000 do
            table.insert(arr, i)
        end
    end,
    ["index append"] = function ()
        local arr = {}
        for i=1,1000 do
            arr[i] = i
        end
    end,
}):warmup(10):run_within_time(1):timethese():cmpthese()
```

then it shows:

```
starting warming up: 10

Score:

index append:  1 wallclock secs ( 1.05 usr +  0.00 sys =  1.05 CPU) @ 51124.51/s (n=53695)
insert append:  1 wallclock secs ( 1.06 usr +  0.00 sys =  1.06 CPU) @ 9185.70/s (n=9760)

Comparison chart:

                    Rate  index append  insert append
   index append  51125/s            --           457%
  insert append   9186/s          -82%             --
```

Please refer also to the [example](./example).

Methods
--

### `benchmarker` package

#### `.new({functions})`

A constructor. This method instantiates a benchmarker instance. This method receives a table of target functions.

e.g.

```lua
benchmarker.new({
    ["procedure 1"] = function ()
        -- do something
    end,
    ["procedure 2"] = function ()
        -- do something
    end,
    ...
})
```

#### `:warmup(ntimes)`

This method executes target functions `n` times. This warming up phase doesn't affect the result.

This method returns the self.

#### `:timeit(ntimes, func)`

This method executes a chunk of given function and sees how long it goes.

This method returns `result` instance that contains the score.

#### `:countit(timelimit, func)`

This method shows how many times a chunk of the function runs in a given time limit.

This method returns `result` and `err`. `result` contains the score.

#### `:run(ntimes)`

This method executes `timeit()` for each function that is given by constructor.

The return value of this method is `result` instance that contains scores for each function.

#### `:run_within_time(timelimit)`

This method executes `countit()` for each function that is given by constructor.

This method returns `result` and `err`. `result` instance that contains scores for each function.

### `result` package

#### `result:timethese()`

This method prints score with execution time.

#### `result:cmpthese()`

This method prints score as a comparison chart.

Installation
--

This package is provided by luarocks:

```
$ luarocks install benchmarker
```

Copyright
--

This library was made with reference to the following:

- [https://metacpan.org/source/XSAWYERX/perl-5.28.0/lib/Benchmark.pm](https://metacpan.org/source/XSAWYERX/perl-5.28.0/lib/Benchmark.pm)
- [https://github.com/tokuhirom/nanobench](https://github.com/tokuhirom/nanobench)

License
--

```
This software is Copyright (c) 2018 by moznion <moznion@gmail.com>.

This is free software, licensed under:

  The Artistic License 1.0
```

