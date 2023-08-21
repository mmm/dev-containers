# Notes on Dev Containers

So... dev container options:
- use VSCode "Dev Containers"
- use Docker Desktop "Dev Environments"
- manually use docker (or docker-compose) to run dev containers however you want

(likely in easiest-to-hardest but inflexible-to-flexible order)

Perhaps we should stick an option for GitHub CodeSpaces... dunno.

These all use volumes to have the local development directory mounted inside of
the container.

You need to pay a little attention to the user that's running in the container.
By default it's `root` which means any files written by the container are owned
by `root` which can be problematic.  Normally files written to your laptop are
owned by your user account.  This is why the `useradd` crap is in the Dockerfile
below.


## VSCode Dev Containers

:shrug:


## Docker Desktop Dev Environments

:shrug:


## Manual

You can put together a `Dockefile` that looks something like:
```Dockerfile
FROM python:3.11

ARG USERNAME=user-name-goes-here
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user (this might only work for debian-based linux distros)
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME

WORKDIR /workspace

COPY requirements.txt .
RUN pip install -r requirements.txt

VOLUME /workspace
CMD ["bash"]
```

which builds using
```
docker build -t my-cool-dev-container .
```

and then run that puppy using something like:
```bash
docker run -it --rm -v `pwd`:/workspace my-cool-dev-container bash
```

or maybe if you need some extra config files, or wanna force a different user, or...
```bash
docker run -it --rm -v `pwd`:/workspace -v $HOME/.config/gcloud/application_default_credentials.json:/workspace/.config/gcloud/application_default_credentials.json --user "$(id -u):$(id -g)" ghpc bash
```

You can then run your app (flask assumes `app.py` in the working dir):
```
docker run -it --rm -v `pwd`:/workspace my-cool-dev-container flask run --host 0.0.0.0 --reload
```

or you can specify the specific app to run:
```
docker run -it --rm -v `pwd`:/workspace my-cool-dev-container env FLASK_APP=/workspace/app.py flask run --host 0.0.0.0 --reload
```
or run it in the background w/ `-d`, etc etc...


## Docker Compose

Of course docker compose is the better way to go:
```docker-compose.yml
```

In the past, we did stuff with long-running containers like:
```
docker-compose exec my-cool-dev-container env FLASK_APP=/workspace/app.py flask run --host 0.0.0.0
```
but could easily just stick that in the `CMD` for the service
```
docker-compose exec my-cool-dev-container env FLASK_APP=/workspace/app.py flask run --host 0.0.0.0
```
but there's generally no need for dev containers to run forever... kinda
depends on what exactly you're trying to do.
