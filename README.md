# docker-redis

> A docker base to build a container for Redis based on Alpine Linux

This container is intended to build a base for providing a Redis database to an application stack.

### Start container

The container can be easily started with `docker-compose` command.

Note that the container itself won't be very useful by itself. The default port `6379` is only
exposed to linked containers. Meaning a connection with a client to the database is not possible with the default configuration.

```
docker-compose up -d
```

**Note:** You will get a warning that external secrets are not supported by docker-compose. The container will ignore this and setup redis unprotected. For a production deployment a stack should be deployed. The secret will then be taken into account and redis will be setup accordingly. You can also set a password in `config/redis.conf requirepass` but this is not recommended for production.

Join a swarm
```
docker swarm init
```

Setup docker secret for the service
```
echo "some_password" | docker secret create com.ragedunicorn.redis.password -
```

Deploy stack
```
docker stack deploy --compose-file=docker-compose.yml [stackname]
```

### Stop container

To stop all services from the docker-compose file

```
docker-compose down
```

## Dockery

In the dockery folder are some scripts that help out avoiding retyping long docker commands but are mostly intended for playing around with the container. For production use docker-compose should be used.

#### Build image

The build script builds an image with a defined name

```
sh dockery/dbuild.sh
```

#### Run container

Runs the built container. If the container was already run once it will `docker start` the already present container instead of using `docker run`

```
sh dockery/drun.sh
```

#### Attach container

Attaching to the container after it is running

```
sh dockery/dattach.sh
```

#### Stop container

Stopping the running container

```
sh dockery/dstop.sh
```

## Configuration

Most of the configuration can be changed in the `redis.conf` configuration file. The configuration is copied into the container on buildtime. After a change to the file the container must be rebuilt.

## persistence

With the default `redis.conf` basic snapshotting is activated and saved to `/data` as a volume.
To configure this in more depth see `config/redis.conf` and modify snapshotting and append only mode.

For a full explanation see the redis documentation for persistence
- https://redis.io/topics/persistence

## Development

To debug the container and get more insight into the container use the `docker-compose-dev.yml`
configuration. This will also allow external clients to connect to the database. By default the port `6379` will be publicly exposed.

```
docker-compose -f docker-compose-dev.yml up -d
```

By default the launchscript `/docker-entrypoint.sh` will not be used to start the Redis process. Instead the container will be setup to keep `stdin_open` open and allocating a pseudo `tty`. This allows for connecting to a shell and work on the container. Redis itself can be started with `./docker-entrypoint.sh [user] [config-path]`.

## Links

Alpine packages database
- https://pkgs.alpinelinux.org/packages

## License

Copyright (c) 2017 Michael Wiesendanger

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
