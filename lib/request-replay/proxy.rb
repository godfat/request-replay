
require 'request-replay'

class RequestReplay::Proxy
  def initialize host, options={}
    @host, @options = host, options
    # since we're hijacking, we don't manage connections
    (@options[:add_headers] ||= {})['Connection'] ||= 'close'
  end

  def call env
    Thread.new(env['rack.hijack'].call) do |io|
      RequestReplay.new(rewrite_env(env), @host, @options).start do |sock|
        IO.copy_stream(sock, io)
        io.close
      end
    end
    [200, {}, []]
  end

  def rewrite_env env
    if rewrite = @options[:rewrite_env]
      rewrite.call(env)
    else
      env
    end
  end
end
