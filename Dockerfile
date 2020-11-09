FROM debian:testing-slim
ENV TZ America/Edmonton
ENV DEBIAN_FRONTEND noninteractive

# Install required packages for application using apt
RUN apt update && apt upgrade -y && apt install -yq csh bash g++ gcc git cron procps rsyslog \
 postgresql-client postgresql-client-common \
 postgis libgdal-dev binutils libproj-dev gdal-bin proj-bin \
 unixodbc-dev libffi-dev postfix sudo bsd-mailx \
 build-essential libssl-dev ca-certificates libpq-dev libpangoft2-1.0-0 \
 libldap2-dev libsasl2-dev slapd ldap-utils tox lcov valgrind \
 python3 python3-dev python3-pip python3-venv vim wget locales \
 xvfb chromium chromium-driver graphviz pandoc libgdal-dev \
 uwsgi uwsgi-plugin-python3 \
 python-mpltoolkits.basemap python-mpltoolkits.basemap-data \
 sssd-krb5 sssd-krb5-common nis autofs nfs-common \
 gettext task-chinese-s
 
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 2

WORKDIR /site
COPY requirements.txt /site/requirements.txt
RUN /usr/bin/python -m venv /site/env
RUN . /site/env/bin/activate && python -m pip install --user --upgrade pip && \
python -m pip install -U Cython wheel numpy pandas
RUN . /site/env/bin/activate && python -m pip install -U -r /site/requirements.txt
RUN . /site/env/bin/activate && python -m pip uninstall -y shapely && python -m pip install shapely --no-binary shapely

# Set-up Xvfb for any headless web requirements
RUN echo "#!/bin/sh" > /site/Xvfb.start
RUN echo "/usr/bin/Xvfb :88 -ac -screen 0 1366x768x16 &" >> /site/Xvfb.start
RUN echo "export DISPLAY=88.0" >> /site/Xvfb.start
RUN chmod +x /site/Xvfb.start

# Set hostname to xxxx.localhost
RUN echo -e "$(hostname -i)\t$(hostname) $(hostname).localhost" >> /etc/hosts
RUN echo 'export PS1="\\[$(tput setaf 1)\\]\\u@\\h:\\w CORTEX-PROD# \\[$(tput sgr0)\\]"' >> ~/.bashrc
