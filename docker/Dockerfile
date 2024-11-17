FROM debian:bullseye

COPY ./docker/server-provision.sh .
COPY ./docker/supervisord.conf /etc/supervisor/supervisord.conf

RUN chmod +x server-provision.sh

RUN ./server-provision.sh

EXPOSE 22 80 443

ENTRYPOINT ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]