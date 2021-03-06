# CHANGES

## request-replay 0.7.1 -- 2014-03-30

* Add a default header: `Connection: close` for RequestReplay::Proxy since
  we're not going to reuse the connection anyway. There's no way to return
  the socket back to the web server after hijacking according to Rack's SPEC.
  This should fix some weird issues with web pages with a lot of images.

## request-replay 0.7.0 -- 2014-03-30

* Fixed a bug where nginx with sendfile on might not send a full file back.
* Introduced RequestReplay::Proxy which could serve as a reverse proxy.

## request-replay 0.6.3 -- 2013-10-07

* Fixed an issue where Rack::Request does not try to rewind rack.input for
  form POST. We rewind for them. Thanks @yyjim
* Extracted more constants. Might boost performance a bit.

## request-replay 0.6.2 -- 2013-10-01

* Added :rewrite_env option for rewriting env for specific use.

## request-replay 0.6.1 -- 2013-10-01

* Print error messages to env['rack.errors']
* Fixed a bug where the underlying Rack app might be modifying
  the original env, making request-replay cannot reliably rebuild
  the request.

## request-replay 0.6.0 -- 2013-10-01

* Added :read_wait option for waiting for the remote server responding.
* Changed the API a bit. Now pass :add_headers for adding some extra
  headers to the replaying request. Useful for passing another Host or
  a special User-Agent.

## request-replay 0.5.0 -- 2013-09-04

* Birthday!
