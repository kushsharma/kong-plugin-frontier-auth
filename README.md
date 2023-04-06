# Kong plugins

Use `src/kong/plugins/frontier-auth` plugin for frontier token based authentication request enrichment.

### TODO
- Add unit/integration tests for frontier-auth plugin

### Notes
- Use `docker-compose up` to start kong and konga(kong ui) in dbless mode
- `declarative/kong.yml` contains kong proxy routing configurations
- By default kong proxy is available at `:6000` and admin api it `:6001`
- Kong ui is available at `:6002`