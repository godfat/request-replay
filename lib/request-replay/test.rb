
require 'pork/auto'
require 'muack'

require 'request-replay'
require 'rack'

copy :test do
  include Muack::API
  extend  Muack::API

  before do
    @host = 'localhost'.freeze
    @serv = TCPServer.new(0)
    @port = @serv.addr[1]
    @hopt = "#{@host}:#{@port}".freeze
    @env  = {'REQUEST_METHOD' => 'GET',
             'PATH_INFO' => '/', 'QUERY_STRING' => 'q=1',
             'HTTP_HOST' => 'localhost',
             'HTTP_PORK' => 'BEEF'     }.freeze
  end

  def verify response, expected
    sock = @serv.accept
    if expected.start_with?('POST')
      sock.readline("\r\n\r\n") + sock.readline("\r\n\r\n")
    else
      sock.readline("\r\n\r\n")
    end.should.eq(expected)
    sock.write(expected)
    sock.close
    response.value.should.eq(expected)
  end
end
