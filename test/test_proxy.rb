

require 'request-replay/test'

describe RequestReplay::Proxy do
  behaves_like :test

  request = lambda do |env, buf, options={}|
    mock(buf).close
    Thread.new{
      begin
        RequestReplay::Proxy.new(@hopt, options).call(env)
        buf.string
      rescue => e
        p e
      end
    }
  end

  after do
    Muack.verify
  end

  should 'basic' do
    expected = <<-HTTP
GET /?q=1 HTTP/1.1\r
Host: localhost\r
Pork: BEEF\r
Connection: close\r
\r
    HTTP

    buf = StringIO.new
    env = {'rack.hijack' => mock.call{ env['rack.hijack_io'] = buf }.object}.
          merge(@env)

    @verify[request[env, buf], expected]
  end

  should 'add_headers' do
    expected = <<-HTTP
GET /?q=1 HTTP/1.1\r
Host: ex.com\r
Pork: BEEF\r
Connection: close\r
\r
    HTTP

    buf = StringIO.new
    env = {'rack.hijack' => mock.call{ env['rack.hijack_io'] = buf }.object}.
          merge(@env)

    @verify[request[env, buf, :add_headers => {'Host' => 'ex.com'}], expected]
  end

  should 'rewrite_env' do
    expected = <<-HTTP
GET /a?q=1 HTTP/1.1\r
Host: localhost\r
Pork: BEEF\r
Connection: close\r
\r
    HTTP

    buf = StringIO.new
    env = {'rack.hijack' => mock.call{ env['rack.hijack_io'] = buf }.object}.
          merge(@env)
    rewrite_env = lambda{ |env| env['PATH_INFO'] = '/a'; env }
    @verify[request[env, buf, :rewrite_env => rewrite_env], expected]
  end
end
