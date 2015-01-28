# request-replay [![Build Status](https://secure.travis-ci.org/godfat/request-replay.png?branch=master)](http://travis-ci.org/godfat/request-replay) [![Coverage Status](https://coveralls.io/repos/godfat/request-replay/badge.png)](https://coveralls.io/r/godfat/request-replay)

by Lin Jen-Shin ([godfat](http://godfat.org))

## LINKS:

* [github](https://github.com/godfat/request-replay)
* [rubygems](https://rubygems.org/gems/request-replay)
* [rdoc](http://rdoc.info/github/godfat/request-replay)

## DESCRIPTION:

Replay the request via Rack env

## REQUIREMENTS:

* Tested with MRI (official CRuby), Rubinius and JRuby.

## INSTALLATION:

    gem install request-replay

## SYNOPSIS:

You might want to use this as middleware to replay the request:

Note that the first argument is where it should make the request,
and the second argument is what's additional headers we want to
overwrite in the original request.

``` ruby
require 'request-replay'
use RequestReplay::Middleware, 'localhost:8080',
    :add_headers => {'Host' => 'example.com'},
    :read_wait   => 5,
    # We could also rewrite the env
    :rewrite_env => lambda{ |env|
                      if env['HTTP_HOST'].start_with?('api.')
                        env['PATH_INFO'] = "/api/#{env['PATH_INFO']}"
                      end
                      env
                    }
run lambda{ |env| [200, {}, [env.inspect]] }
```

You could also use `RequestReplay::Proxy` as a reverse proxy. Note that
this only works on Rack servers which support [Rack Hijacking][].

[Rack Hijacking]: http://rack.rubyforge.org/doc/SPEC.html

``` ruby
require 'request-replay'
run RequestReplay::Proxy.new(
  'example.com', :add_headers => {'Host' => 'example.com'},
                 # We could also rewrite the env
                 :rewrite_env => lambda{ |env|
                   if env['HTTP_HOST'].start_with?('api.')
                     env['PATH_INFO'] = "/api/#{env['PATH_INFO']}"
                   end
                   env
                 })
```

## CONTRIBUTORS:

* Jim Wang (@yyjim)
* Lin Jen-Shin (@godfat)

## LICENSE:

Apache License 2.0

Copyright (c) 2013-2014, Lin Jen-Shin (godfat)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
