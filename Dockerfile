# To build: docker build -t moltres . 
# To build container: docker run -itd --name phoenix moltres
# After starting the container, run the following: 
# - unminimize
# - sudo apt install man-db manpages-posix
# - pg_ctlcluster 14 main start
# To stop postgresql: pg_ctlcluster 14 main stop

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
&& git config --global credential.https://github.com/.usehttppath true

# --- Phoenix ---
# Switch user before installing elixir/ruby on rails tutorial requirements or postgresql will be unhappy
# RUN adduser merlin
# RUN adduser merlin sudo
# RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
# USER merlin
# WORKDIR /home/merlin

# Install postgresql
RUN apt -y install postgresql-14 postgresql-contrib-14
# Create db cluster
RUN pg_ctlcluster 14 main start
RUN echo pg_lsclusters
#RUN createuser --superuser postgres

# Install nodejs
RUN apt -y install nodejs npm

# Install Phoenix
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix archive.install hex --force phx_new



# elixir/ruby on rails tutorial wants user to install brew, but we are going to use apt instead since we are not on macos
# https://www.softcover.io/read/aa18bc18/phoenix_tutorial_book/ch1_from_zero_to_deploy
# RUN curl -fsSL -o install.sh https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
# RUN yes 'yes' | bash install.sh
# RUN (echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /root/.profile
# RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"
# RUN brew install coreutils automake autoconf openssl@1.1 libyaml readline libxslt libtool unixodbc icu4c asdf
#
# RUN sudo apt -y install libssl-dev libreadline-dev coreutils automake autoconf openssl libyaml-dev libxslt1-dev libtool unixodbc libicu-dev
# RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1 \
# &&  echo ". $HOME/.asdf/asdf.sh" >> ~/.bashrc
# RUN source ~/.bashrc
# ENV PATH="~/.asdf/bin:${PATH}"
# RUN asdf plugin-add postgres https://github.com/smashedtoatoms/asdf-postgres.git
# RUN asdf install postgres 14.0
# RUN asdf global postgres 14.0
# ENV PATH="~/.asdf/installs/postgres/14.0/bin:${PATH}"
# RUN pg_ctl -D ~/.asdf/installs/postgres/14.0/data -l logfile start
# RUN createuser --superuser postgres
# RUN asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git
# RUN asdf install elixir 1.12.3-otp-24 \
# &&  asdf global elixir 1.12.3-otp-24
# RUN asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
# RUN gnupgimport="${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring"
# RUN bash -c $gnupgimport
# RUN asdf install nodejs 16.12.0 \
# &&  asdf global nodejs 16.12.0
# RUN mix local.hex
# RUN mix archive.install hex phx_new
