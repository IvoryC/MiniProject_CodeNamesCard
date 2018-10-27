FROM rocker/shiny

# Download the Miniprojects code
RUN wget --no-check-certificate https://github.com/IvoryC/MiniProject_CodeNamesCard/archive/master.zip && \
    unzip master.zip && \
    rm master.zip && \
    cp -R ./MiniProject_CodeNamesCard-master/* /srv/shiny-server/ && \
    rm /srv/shiny-server/index.html && \
    mv /srv/shiny-server/docker/index.html /srv/shiny-server/.

EXPOSE 3838

CMD ["/usr/bin/shiny-server.sh"]
