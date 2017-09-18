# pep-Kong

## pep-Kong

PEP-Kong is a lua plugin for Kong, a open-source API gateway.
PEP stand for 'Policy Enforcement Point'.
PEP-Kong extract information about the user from its JWT token and send these
 Information, together with HTTP request method and URL, to a PDP.
 If the PDP verdict negate the access, pep-Kong throw a 'forbidden' page for the user.
 Otherwise, if the PDP permits the access, pep-Kong let the request pass.

### installation
The docker container take care of plugin installation.
So, skip this step if you are running PEP-Kong with docker.

Build the plugin. Move to the directory with the rockspec file and run the command:

  luarocks make

Edit Kong configuration file at /etc/Kong/kong.conf. Add the following line.

	custom_plugins = pepkong

If Kong is running, reload to apply the changes.
	Kong reload

### Running


PEP-Kong expects a running PDP with a REST-JSON API.
The component  [PDP-ws](https://github.com/dojot/pdp-ws) is fully compatible with PEP-Kong

PEP-Kong expects JWT authentication. The JWT must have a field named 'profile', representing the user role.
The component [auth](https://github.com/dojot/auth) generate PEP-Kong compatible JWT tokens.

PEP-Kong don't validate JWT signature. Kong have a nice pré-installed plugin for this task: [ JWT-Kong](https://getkong.org/plugins/jwt/)

Now, you should configure what endpoints PEP-Kong (and JWT-Kong) should guard.
If you are using PEP-Kong with Dojot, run the configuration script  ''./kong.config.sh' located on the [docker-compose](https://github.com/dojot/docker-compose) repository
