
require 'bacon'
require 'muack'

require 'request-replay'
require 'rack'

Bacon.summary_on_exit
Bacon::Context.__send__(:include, Muack::API)

module Kernel
  def eq? rhs
    self == rhs
  end
end

shared :test do
  @host = 'localhost'.freeze
  @port = 1024 + rand(2**16 - 1024)
  @serv = TCPServer.new('localhost', @port)
  @hopt = "#{@host}:#{@port}".freeze
  @env  = {'REQUEST_METHOD' => 'GET',
           'PATH_INFO' => '/', 'QUERY_STRING' => 'q=1',
           'HTTP_HOST' => 'localhost',
           'HTTP_PORK' => 'BEEF'     }.freeze

  @verify = lambda do |response, expected|
    sock = @serv.accept
    sock.read     .should.eq(expected)
    sock.write(expected)
    sock.close
    response.value.should.eq(expected)
  end
end
