
require 'bacon'

Bacon.summary_on_exit

module Kernel
  def eq? rhs
    self == rhs
  end
end

require 'replay-request'

describe ReplayRequest do
  host = 'localhost'
  port = 1024 + rand(2**16 - 1024)
  serv = TCPServer.new('localhost', port)
  hopt = "#{host}:#{port}"
  env  = {'PATH_INFO' => '/', 'QUERY_STRING' => 'q=1',
          'HTTP_HOST' => 'localhost',
          'HTTP_PORK' => 'BEEF'     }

  verify = lambda do |response, expected|
    sock = serv.accept
    sock.read     .should.eq(expected)
    sock.write(expected)
    sock.close
    response.value.should.eq(expected)
  end

  request = lambda do |env1, headers={}|
    Thread.new(ReplayRequest.new(
                 env.merge(env1), hopt, headers)) do |replay|
      replay.start{ |sock| sock.close_write; sock.read }
    end
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
end
