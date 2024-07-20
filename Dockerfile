FROM ghcr.io/fraunhofer-iem/technical-lag-calculator:main

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]