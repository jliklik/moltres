# To build: docker build -t moltres . 
# To build container: docker run -itd --name phoenix moltres

# After starting the container, run the following: 
# - pg_ctlcluster 14 main start
# To stop postgresql: 
# - pg_ctlcluster 14 main stop
# To start up postgres:
# - pg_ctlcluster 14 main start
# Check postgres connection status:
# - pg_isready
# Change postgres user password (must be done from non root directory):
# - sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
# Restart postgresql: 
# - sudo service postgresql restart


# Custom setup for phoenix development
FROM hexpm/elixir:1.14.5-erlang-26.1.1-ubuntu-jammy-20230126
ARG DEBIAN_FRONTEND=noninteractive

LABEL maintainer="jlik"
SHELL ["/bin/bash", "-c"] 

# --- Basics ---
RUN apt-get update

# Install git
RUN apt -y install wget curl git make build-essential gdb vim sudo

# Set up git credential store on Linux
RUN apt -y install libsecret-1-0 libsecret-1-dev
RUN make /usr/share/doc/git/contrib/credential/libsecret
RUN git config --global credential.helper /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret
# Make sure you set the git config to your own user name and email after
RUN git config --global user.name "Jian Lik Ng" \
&& git config --global user.email "jlik.lik@gmail.com" \
&& git config --global credential.useHttpPath true

# --- Phoenix ---
# Create new user merlin
ARG USERNAME=merlin
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set the default user. Omit if you want to keep the default as root.
USER $USERNAME

# Install postgresql
# --- No longer necessary, will run postgresql in another container
# RUN apt -y install postgresql-14 postgresql-contrib-14

# Install nodejs
RUN sudo apt -y install nodejs npm

# Install Phoenix
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix archive.install hex --force phx_new

# Dockerfile is based on phoenix tutorial here:
# https://www.softcover.io/read/aa18bc18/phoenix_tutorial_book/ch1_from_zero_to_deploy
