
require 'request-replay'

class RequestReplay::Middleware
  def initialize app, host, headers={}
    @app, @host, @headers = app, host, headers
  end

  def call env
    # We don't want to read the socket in a thread, so create it in main
    # thread, and send the data in a thread as we don't care the responses
    Thread.new(RequestReplay.new(env, @host, @headers), &:start)
    @app.call(env)
  end
end
