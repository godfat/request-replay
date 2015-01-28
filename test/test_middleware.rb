
require 'request-replay/test'

describe RequestReplay::Middleware do
  paste :test

  would 'PUT' do
    hopt = @hopt
    app = Rack::Builder.app do
      use RequestReplay::Middleware, hopt
      run lambda{ |_| [200, {}, []] }
    end

    app.call(@env.merge('REQUEST_METHOD' => 'PUT'))
    begin
      sock = @serv.accept
      sock.read.should.eq <<-HTTP
PUT /?q=1 HTTP/1.1\r
Host: localhost\r
Pork: BEEF\r
\r
    HTTP
    ensure
      sock.close
    end
  end

  would 'retain original env' do
    hopt = @hopt
    e = @env.dup

    app = Rack::Builder.app do
      use RequestReplay::Middleware, hopt
      run lambda{ |env|
        env['PATH_INFO'] = '/bad'
        [200, {}, []]
      }
    end

    app.call(e)
    begin
      sock = @serv.accept
      sock.read.should.eq <<-HTTP
GET /?q=1 HTTP/1.1\r
Host: localhost\r
Pork: BEEF\r
\r
    HTTP
    ensure
      sock.close
    end
  end

  would 'rewrite_env' do
    hopt = @hopt
    app = Rack::Builder.app do
      use RequestReplay::Middleware, hopt, :rewrite_env => lambda{ |env|
        if env['HTTP_HOST'].start_with?('api.')
          env['PATH_INFO'] = "/api#{env['PATH_INFO']}"
        end
        env
      }, :add_headers => {'Host' => 'eg.com'}
      run lambda{ |_| [200, {}, []] }
    end

    app.call(@env.merge('HTTP_HOST' => 'api.localhost'))
    begin
      sock = @serv.accept
      sock.read.should.eq <<-HTTP
GET /api/?q=1 HTTP/1.1\r
Host: eg.com\r
Pork: BEEF\r
\r
    HTTP
    ensure
      sock.close
    end
  end
end
