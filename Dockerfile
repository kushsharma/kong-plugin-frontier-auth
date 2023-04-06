FROM kong:3.2.2
USER root

# Copy Plugins to directory where kong expects plugin rocks
COPY ./src/ /opt/custom/kong/plugins/

# https://github.com/luarocks/luarocks/wiki/Creating-a-rock
RUN cd /opt/custom/kong/plugins/ && luarocks make kong-plugin-frontier-auth-0.1.0-1.rockspec
RUN cd /opt/custom/kong/plugins/ && luarocks make kong-plugin-route-override-0.1.0-1.rockspec

# reset back the defaults
USER kong