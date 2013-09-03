
require 'socket'
require 'stringio'

class ReplayRequest
  autoload :Middleware, 'replay-request/middleware'

  NEWLINE      = "\r\n"
  HTTP_VERSION = 'HTTP/1.1'

  def initialize env, host, addhead={}
    @env, (@host, @port), @addhead = env, host.split(':', 2), addhead
    if env['rack.input']
      env['rack.input'].rewind
      @buf = StringIO.new
      IO.copy_stream(env['rack.input'], @buf)
      @buf.rewind
    end
  end

  def start
    write_request
    write_headers
    write_payload
    yield(sock) if block_given?
  ensure
    sock.close
  end

  def write_request
    sock.write("#{request}#{NEWLINE}")
  end

  def write_headers
    sock.write("#{headers}#{NEWLINE}#{NEWLINE}")
  end

  def write_payload
    return unless @buf
    IO.copy_stream(@buf, sock)
  end

  def request
    "#{@env['REQUEST_METHOD']} #{request_path} #{HTTP_VERSION}"
  end

  def headers
    headers_hash.map{ |name, value| "#{name}: #{value}" }.join(NEWLINE)
  end

  def request_path
    "/#{@env['PATH_INFO']}?#{@env['QUERY_STRING']}".
      sub(%r{^//}, '/').sub(/\?$/, '')
  end

  def headers_hash
    @headers_hash ||=
      @env.inject({}){ |r, (k, v)|
        r[capitalize_headers(k[5..-1])] = v if k.start_with?('HTTP_')
        r
      }.merge('Content-Type'   => @env['CONTENT_TYPE'  ],
              'Content-Length' => @env['CONTENT_LENGTH']).
        merge(@addhead).
        select{ |_, v| v }
  end

  def capitalize_headers header
    header.downcase.gsub(/[a-z]+/){ |s| s.capitalize }.tr('_', '-')
  end

  def sock
    @sock ||= TCPSocket.new(@host, Integer(@port || 80))
  end
end
