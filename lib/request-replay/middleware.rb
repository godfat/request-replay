
require 'request-replay'

class RequestReplay::Middleware
  def initialize app, host, options={}
    @app, @host, @options = app, host, options
  end

  def call env
    # Unfortunately, we need to dup env because other middleware might be
    # modifying it and make RequestReplay not able to get the original env.
    rr_env = if rewrite = @options[:rewrite_env]
               rewrite.call(env.dup)
             else
              env.dup
             end

    # We don't want to read the socket in a thread, so create it in main
    # thread, and send the data in a thread as we don't care the responses.
    Thread.new(RequestReplay.new(rr_env, @host, @options), &:start)
    @app.call(env)
  end
end
