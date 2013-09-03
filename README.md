# request-replay [![Build Status](https://secure.travis-ci.org/godfat/request-replay.png?branch=master)](http://travis-ci.org/godfat/request-replay)

by Lin Jen-Shin ([godfat](http://godfat.org))

## LINKS:

* [github](https://github.com/godfat/request-replay)
* [rubygems](https://rubygems.org/gems/request-replay)
* [rdoc](http://rdoc.info/github/godfat/request-replay)

## DESCRIPTION:

Replay the request via Rack env

## REQUIREMENTS:

* Tested with MRI (official CRuby) 1.9.3, 2.0.0, Rubinius and JRuby.

## INSTALLATION:

    gem install request-replay

## SYNOPSIS:

You might want to use this as middleware to replay the request:

Note that the first argument is where it should make the request,
and the second argument is what's additional headers we want to
overwrite in the original request.

``` ruby
require 'request-replay'
use RequestReplay::Middleware, 'localhost:8080', 'Host' => 'example.com'
run lambda{ |env| [200, {}, [env.inspect]] }
```

It's effectively the same as:

``` ruby
require 'request-replay'
use Class.new{
  def initialize app, host, headers={}
    @app, @host, @headers = app, host, headers
  end

  def call env
    # We don't want to read the socket in a thread, so create it in main
    # thread, and send the data in a thread as we don't care the responses
    Thread.new(RequestReplay.new(env, @host, @headers), &:start)
    @app.call(env)
  end
}, 'localhost:8080', 'Host' => 'example.com'
run lambda{ |env| [200, {}, [env.inspect]] }
```

## CONTRIBUTORS:

* Lin Jen-Shin (@godfat)

## LICENSE:

Apache License 2.0

Copyright (c) 2013, Lin Jen-Shin (godfat)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
