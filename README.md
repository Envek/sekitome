# Sekitome

A small pure Rack application to answer simple question: was this username seen in last X seconds or not (usually used for throttling).


## Task

The service receives one case insensitive GET parameter: `username`. If this parameter wasn't received during the last minute, service returns JSON:

```json
{“result”: “OK”}
```

If this username was received during the last minute, service returns JSON:

```json
{“result”: “<username> throttled”}
```

## Solution

### Service

API is written on Ruby as Rack application. Pure Rack applications are very lightweight and fast, can be run in any compatible application server (I chose fast threaded [Puma]).

### Database

Redis is fast and battle-tested key-value in-memory database which persists data on disk. Also it has ability to expire keys and that's why it's chosen as database for this service.


## Launch

### Manually

You will need to have installed:

 - Recent MRI [Ruby] version (recommended: 2.3)
 - Recent [Redis] (2.6+, recommended: 3.2)

Follow these simple steps:

 1. Launch [Redis] somewhere accessible from this machine and construct an URL to access it, like `redis://127.0.0.1:6379/0`

 2. Install required gems by executing `bundle install` in this directory.

 3. Launch service with command like:

        env 'REDIS_URL=redis://localhost/0' rackup -s puma -p 3000 -O "Threads=0:${MAX_THREADS:-16}"

 4. Access API endpoint on URL like this: http://localhost:3000/?username=Envek

 5. Access one more time.

 6. …

 7. PROFIT!


## Testing

    env 'REDIS_URL=redis://localhost/0' bundle exec ruby test/integration.rb


## Configuration

Next environment variables will change behavior of this application:

 - `REDIS_URL` (required) — URL to connect to Redis.
 - `THROTTLE_TIMEOUT` — A number of seconds after which username will be forgot. Default is 60 (1 minute).
 - `MAX_THREADS` — maximum number of threads to be used by [Puma] application server, also affects size of connection pool to [Redis] accordingly. Default is 16.


## Operations

### Surviving restarts

 - For deploying new versions of code Puma Phased Restart usage should be considered: https://github.com/puma/puma#normal-vs-hot-vs-phased-restart

 - [Redis] should be configured to use Append-Only File (AOF), to avoid data loss after unexpected restarts. See the docs for details: https://redis.io/topics/persistence

## About the name

A word _sekitome_ is a verbal noun from japanese verb _sekitomeru_ (堰き止める) with direct meaning of _to dam (a river)_ and figurative meaning of _to impede, delay, slow down_. Close enough to meaning of _throttling_ I believe.


## License

Can be freely used, distributed, and modified under the terms of the [MIT License]. See the [LICENSE](LICENSE) file.


[Ruby]: https://www.ruby-lang.org/ (A dynamic, open source programming language with a focus on simplicity and productivity. It has an elegant syntax that is natural to read and easy to write.)
[Rack]: https://rack.github.io/ (Rack: a Ruby Webserver Interface)
[Puma]: http://puma.io/ (A modern, concurrent web server for Ruby)
[Redis]: https://redis.io/ (Redis is an open source (BSD licensed), in-memory data structure store, used as a database, cache and message broker)
[MIT License]: https://opensource.org/licenses/MIT (A short and simple permissive license with conditions only requiring preservation of copyright and license notices)
