# pep-Kong

## pep-Kong

PEP-Kong is a lua plugin for Kong, an open-source API gateway.
PEP stands for 'Policy Enforcement Point'.
PEP-Kong extracts information about the user from its JWT token and sends those,
 together with HTTP request method and URL, to a PDP.
 If the PDP verdict denies the access, pep-Kong throws a 'forbidden' page for the user.
 Otherwise, if the PDP permits the access, pep-Kong lets the request pass.

### installation
The docker container takes care of plugin installation.
So, skip this step if you are running PEP-Kong with docker.

Build the plugin. Move to the repository root directory and run the command:

```shell
luarocks make
```

Edit Kong configuration file.

```shell
echo "custom_plugins = pepkong" >> /etc/Kong/kong.conf
```
If Kong is running, reload to apply the changes.
```shell
kong reload
```

### Running


PEP-Kong expects a running PDP with a REST-JSON API.
The component  [PDP-ws](https://github.com/dojot/pdp-ws) is fully compatible with PEP-Kong

PEP-Kong expects JWT authentication. The JWT must have a field named 'profile', representing the user role.
The component [auth](https://github.com/dojot/auth) generates PEP-Kong compatible JWT tokens.

PEP-Kong  doesn't validate JWT signature. Kong have a nice pre-installed plugin for this task: [ JWT-Kong](https://getkong.org/plugins/jwt/)

Now, you should configure what endpoints PEP-Kong (and JWT-Kong) should guard.
If you are using PEP-Kong with Dojot, run the configuration script  
```shell
./kong.config.sh
```
located on the [docker-compose]
(https://github.com/dojot/docker-compose) repository

otherwise, please refer to kong's own documentation: [here](https://getkong.org/plugins/jwt/) and [here](https://getkong.org/docs/0.11.x/plugin-development/plugin-configuration/)
PEP-kong plugin have only one parameter: 'pdpUrl', the parameter expects an http URL for a running PDP.
