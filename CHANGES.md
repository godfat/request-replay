# CHANGES

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
