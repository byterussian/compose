FROM python:3.6

RUN set -ex; \
    apt-get update -qq; \
    apt-get install -y \
        locales \
        curl \
        python-dev \
        git

RUN curl -fsSL -o dockerbins.tgz "https://download.docker.com/linux/static/stable/x86_64/docker-17.12.0-ce.tgz" && \
    SHA256=692e1c72937f6214b1038def84463018d8e320c8eaf8530546c84c2f8f9c767d; \
    echo "${SHA256}  dockerbins.tgz" | sha256sum -c - && \
    tar xvf dockerbins.tgz docker/docker --strip-components 1 && \
    mv docker /usr/local/bin/docker && \
    chmod +x /usr/local/bin/docker && \
    rm dockerbins.tgz

# Python3 requires a valid locale
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8

RUN useradd -d /home/user -m -s /bin/bash user
WORKDIR /code/

RUN pip install tox==2.1.1

ADD requirements.txt /code/
ADD requirements-dev.txt /code/
ADD .pre-commit-config.yaml /code/
ADD setup.py /code/
ADD tox.ini /code/
ADD compose /code/compose/
RUN tox --notest

ADD . /code/
RUN chown -R user /code/

ENTRYPOINT ["/code/.tox/py36/bin/docker-compose"]
