
require 'request-replay'

class RequestReplay::Middleware
  def initialize app, host, options={}
    @app, @host, @options = app, host, options
  end

  def call env
    # We don't want to read the socket in a thread, so create it in main
    # thread, and send the data in a thread as we don't care the responses
    Thread.new(RequestReplay.new(env, @host, @options), &:start)
    @app.call(env)
  end
end
