
require 'bacon'
require 'muack'

Bacon.summary_on_exit
include Muack::API

module Kernel
  def eq? rhs
    self == rhs
  end
end

require 'request-replay'
require 'rack'

describe RequestReplay do
  host = 'localhost'.freeze
  port = 1024 + rand(2**16 - 1024)
  serv = TCPServer.new('localhost', port)
  hopt = "#{host}:#{port}".freeze
  env  = {'REQUEST_METHOD' => 'GET',
          'PATH_INFO' => '/', 'QUERY_STRING' => 'q=1',
          'HTTP_HOST' => 'localhost',
          'HTTP_PORK' => 'BEEF'     }.freeze

  verify = lambda do |response, expected|
    sock = serv.accept
    sock.read     .should.eq(expected)
    sock.write(expected)
    sock.close
    response.value.should.eq(expected)
  end

  request = lambda do |env1, headers={}, read_wait=nil|
    Thread.new(RequestReplay.new(env.merge(env1), hopt,
                                 :add_headers => headers,
                                 :read_wait   => read_wait)) do |replay|
      replay.start(&:read)
    end
  end

  after do
    Muack.verify
  end

  should 'GET' do
    verify[request[{'REQUEST_METHOD' => 'GET'}, 'Host' => 'ex.com'], <<-HTTP]
GET /?q=1 HTTP/1.1\r
Host: ex.com\r
Pork: BEEF\r
\r
    HTTP
  end

  should 'POST' do
    verify[request['REQUEST_METHOD' => 'POST',
                   'QUERY_STRING'   => ''    , # test no query string
                   'PATH_INFO'      => ''    , # test no path info
                   'rack.input' => StringIO.new("PAYLOAD\r\n\r\n")], <<-HTTP]
POST / HTTP/1.1\r
Host: localhost\r
Pork: BEEF\r
\r
PAYLOAD\r
\r
    HTTP
  end

  should 'read_wait' do
    read_wait = 5
    mock(IO).select(satisfy{ |rs| rs.size == 1 &&
                                  rs[0].kind_of?(IO) },
                    [], [], read_wait)

    verify[request[{}, {}, read_wait], <<-HTTP]
GET /?q=1 HTTP/1.1\r
Host: localhost\r
Pork: BEEF\r
\r
    HTTP
  end

  should 'puts error' do
    any_instance_of(TCPSocket) do |sock|
      mock(sock).read{ raise 'ERROR' }
    end

    errors = StringIO.new
    begin
      request['rack.errors' => errors].value
    ensure
      serv.accept.close
    end
    errors.string.should.start_with? '[RequestReplay] Error:'
  end

  describe RequestReplay::Middleware do
    should 'PUT' do
      app = Rack::Builder.app do
        use RequestReplay::Middleware, hopt
        run lambda{ |env| [200, {}, []] }
      end

      app.call(env.merge('REQUEST_METHOD' => 'PUT'))
      begin
        sock = serv.accept
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

    should 'retain original env' do
      e = env.dup

      app = Rack::Builder.app do
        use RequestReplay::Middleware, hopt
        run lambda{ |env|
          env['PATH_INFO'] = '/bad'
          [200, {}, []]
        }
      end

      app.call(e)
      begin
        sock = serv.accept
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

    should 'rewrite_env' do
      app = Rack::Builder.app do
        use RequestReplay::Middleware, hopt, :rewrite_env => lambda{ |env|
          if env['HTTP_HOST'].start_with?('api.')
            env['PATH_INFO'] = "/api#{env['PATH_INFO']}"
          end
          env
        }, :add_headers => {'Host' => 'eg.com'}
        run lambda{ |env| [200, {}, []] }
      end

      app.call(env.merge('HTTP_HOST' => 'api.localhost'))
      begin
        sock = serv.accept
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
end
