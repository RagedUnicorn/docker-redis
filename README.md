# docker-redis

> A docker base image to build a container for Redis based on Alpine Linux

This image is intended to build a base for providing a Redis database to an application stack.

## Version

* Redis 4

For an exact version see `Dockerfile`

## Using the image

#### Start container

The container can be easily started with `docker-compose` command.

**Note:** that the container itself won't be very useful by itself. The default port `6379` is only
exposed to linked containers. Meaning a connection with a client to the database is not possible with the default configuration.

```
docker-compose up -d
```

#### Stop container

To stop all services from the docker-compose file

```
docker-compose down
```

### Creating a stack

To create a stack the specific `docker-compose.stack.yml` file can be used. It requires that you already built the image that is consumed by the stack or that it is available in a reachable docker repository.

```
docker-compose build --no-cache
```

**Note:** You will get a warning that external secrets are not supported by docker-compose if you try to use this file with docker-compose.

#### Join a swarm

```
docker swarm init
```

#### Create secrets
```
echo "some_password" | docker secret create com.ragedunicorn.redis.app_password -
```

#### Deploy stack
```
docker stack deploy --compose-file=docker-compose.stack.yml [stackname]
```

For a production deployment a stack should be deployed. The secret will then be taken into account and redis will be setup accordingly. You can also set a password in `config/redis.conf requirepass` but this is not recommended for production.

## Dockery

In the dockery folder are some scripts that help out avoiding retyping long docker commands but are mostly intended for playing around with the container. For production use docker-compose or docker stack should be used.

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

#### Build Args

The image allows for certain arguments being overridden by build args.

`REDIS_USER, REDIS_GROUP, REDIS_APP_PASSWORD`

They all have a default value and don't have to be overridden. For details see the Dockerfile.

## Persistence

With the default `redis.conf` basic snapshotting is activated and saved to `/data` as a volume.
To configure this in more depth see `config/redis.conf` and modify snapshotting and append only mode.

For a full explanation see the redis documentation for persistence
- https://redis.io/topics/persistence

### Changing Data Directory

The data directory can be overwritten by changing the `REDIS_DATA_DIR` environmental variable. Additionally to changing this variable the same folder needs to be set in the `redis.conf` configuration.

Search for `working directory` and change the dir value to the same as the environment variable.

```
dir /data
```

To check whether the data directory is working as expected startup the redis server and the shut it down. If redis complains about not being able to shutdown because it cannot save the dump double check the paths.

```
Saving the final RDB snapshot before exiting.
Failed opening the RDB file dump.rdb (in server root dir /) for saving: Permission denied
Error trying to save the DB, can't exit.
SIGTERM received but errors trying to shut down the server, check the logs for more information
```

While a successfully configured working directory shutdown looks like this.

```
User requested shutdown...
Saving the final RDB snapshot before exiting.
DB saved on disk
Removing the pid file.
Redis is now ready to exit, bye bye...
```

Checking the configured data directory should contain a file called `dump.rdb`.

**Note:** Also make sure to update any docker-compose files and their volumes accordingly.

## Healthcheck

The production and the stack image supports a simple healthcheck whether the container is healthy or not. This can be configured inside `docker-compose.yml` or `docker-compose.stack.yml`

## Test

To do basic tests of the structure of the container use the `docker-compose.test.yml` file.

`docker-compose -f docker-compose.test.yml up`

For more info see [container-test](https://github.com/RagedUnicorn/docker-container-test).

Tests can also be run by category such as command, fileExistence and metadata tests by starting single services in `docker-compose.test.yml`

```
# basic file existence tests
docker-compose -f docker-compose.test.yml up container-test
# command tests
docker-compose -f docker-compose.test.yml up container-test-command
# metadata tests
docker-compose -f docker-compose.test.yml up container-test-metadata
```

The same tests are also available for the development image.

```
# basic file existence tests
docker-compose -f docker-compose.test.yml up container-dev-test
# command tests
docker-compose -f docker-compose.test.yml up container-dev-test-command
# metadata tests
docker-compose -f docker-compose.test.yml up container-dev-test-metadata
```

## Development

To debug the container and get more insight into the container use the `docker-compose.dev.yml` configuration. This will also allow external clients to connect to the database. By default the port `6379` will be publicly exposed.

```
docker-compose -f docker-compose.dev.yml up -d
```

By default the launchscript `/docker-entrypoint.sh` will not be used to start the Redis process. Instead the container will be setup to keep `stdin_open` open and allocating a pseudo `tty`. This allows for connecting to a shell and work on the container. A shell can be opened inside the container with `docker attach [container-id]`. Redis itself can be started with `./docker-entrypoint.sh`.

## Links

Alpine packages database
- https://pkgs.alpinelinux.org/packages

## License

Copyright (C) 2019 Michael Wiesendanger

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
