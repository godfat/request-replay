
require 'request-replay'

class RequestReplay::Proxy
  def initialize host, options={}
    @host, @options = host, options
    # since we're hijacking, we don't manage connections
    (@options[:add_headers] ||= {})['Connection'] ||= 'close'
  end

  def call env
    replay(rewrite_env(env), env['rack.hijack'].call)
    [200, {}, []]
  end

  def replay env, io
    RequestReplay.new(env, @host, @options).start do |sock|
      IO.copy_stream(sock, io)
    end
  ensure
    io.close
  end

  def rewrite_env env
    if rewrite = @options[:rewrite_env]
      rewrite.call(env)
    else
      env
    end
  end
end
