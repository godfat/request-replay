
require 'request-replay/test'

describe RequestReplay do
  paste :test

  def request env, headers={}, read_wait=nil
    Thread.new(RequestReplay.new(@env.merge(env), @hopt,
                                 :add_headers => headers,
                                 :read_wait   => read_wait)) do |replay|
      replay.start(&:read)
    end
  end

  after do
    Muack.verify
  end

  would 'GET' do
    @verify[request({'REQUEST_METHOD' => 'GET'}, 'Host' => 'ex.com'), <<-HTTP]
GET /?q=1 HTTP/1.1\r
Host: ex.com\r
Pork: BEEF\r
\r
    HTTP
  end

  would 'POST' do
    @verify[request('REQUEST_METHOD' => 'POST',
                    'QUERY_STRING'   => ''    , # test no query string
                    'PATH_INFO'      => ''    , # test no path info
                    'rack.input' => StringIO.new("PAYLOAD\r\n\r\n")), <<-HTTP]
POST / HTTP/1.1\r
Host: localhost\r
Pork: BEEF\r
\r
PAYLOAD\r
\r
    HTTP
  end

  would 'read_wait' do
    read_wait = 5
    mock(IO).select(satisfy{ |rs| rs.size == 1 &&
                                  rs[0].kind_of?(IO) },
                    [], [], read_wait)

    @verify[request({}, {}, read_wait), <<-HTTP]
GET /?q=1 HTTP/1.1\r
Host: localhost\r
Pork: BEEF\r
\r
    HTTP
  end

  would 'puts error' do
    any_instance_of(TCPSocket) do |sock|
      mock(sock).read{ raise 'ERROR' }
    end

    errors = StringIO.new
    begin
      request('rack.errors' => errors).value
    ensure
      @serv.accept.close
    end
    errors.string.should.start_with? '[RequestReplay] Error:'
  end

  would 'not affect Rack::Request' do
    input = StringIO.new('a=0&b=1')
    e     = {'rack.input' => input, 'REQUEST_METHOD' => 'POST'}
    t     = request(e)
    @serv.accept.close
    t.join
    Rack::Request.new(e).POST.should.eq('a' => '0', 'b' => '1')
  end
end
