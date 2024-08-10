FROM alpine

# basic flask environment
RUN apk add --no-cache bash git nginx uwsgi uwsgi-python py2-pip \
    && pip2 install --upgrade pip \
    && pip2 install flask

# application folder
ENV APP_DIR /app
ENV FLASK_APP app.py

# app dir
RUN mkdir ${APP_DIR} \
    && chown -R nginx:nginx ${APP_DIR} \
    && chmod 777 /run/ -R \
    && chmod 777 /root/ -R
VOLUME [${APP_DIR}]
WORKDIR ${APP_DIR}

# copy config files into filesystem
COPY nginx.conf /etc/nginx/nginx.conf
COPY app.ini /app.ini
COPY entrypoint.sh /entrypoint.sh

RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*
COPY ./cert.pem /usr/local/share/ca-certificates/mycert.pem
COPY ./key.pem /usr/local/share/ca-certificates/mykey.pem
COPY ./ssl_password_file.pass /etc/keys/global.pass
RUN update-ca-certificates

COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt
EXPOSE 5000
ENTRYPOINT ["/entrypoint.sh"]
