
require 'request-replay'

class RequestReplay::Proxy
  def initialize host, options={}
    @host, @options = host, options
  end

  def call env
    env['rack.hijack'].call
    RequestReplay.new(rewrite_env(env), @host, @options).start do |sock|
      IO.copy_stream(sock, env['rack.hijack_io'])
      env['rack.hijack_io'].close
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
