# Deployment Guide <br/> Email Delivery Microservice

Email delivery microservice can be used in different deployment scenarios.

* [Standalone Process](#process)
* [Seneca Plugin](#seneca)

## <a name="process"></a> Standalone Process

The simplest way to deploy the microservice is to run it as a standalone process. 
This microservice is implemented in JavaScript and requires installation of Node.js. 
You can get it from the official site at https://nodejs.org/en/download

**Step 1.** Download microservices by following [instructions](Download.md)

**Step 2.** Add **config.json** file to the root of the microservice folder and set configuration parameters. 
See [Configuration Guide](Configuration.md) for details.

**Step 3.** Start the microservice using the command:

```bash
node run
```

## <a name="seneca"></a> Seneca Plugin

The SysLog microservice can also be used as a Seneca plugin.
To learn more about Seneca microservices framework to go http://senecajs.org

**Step 1.** Include dependency into **package.json** file:

```javascript
{
    ...
    "dependencies": {
        ....
        "pip-services-email-node": "^1.0.0",
        ...
    }
}
```

Then install dependencies using **npm**

```javascript
# Install dependencies
npm install

# Update existing dependencies
npm update
```

**Step 2.** Load seneca plugin within your code. 

Configuration parameters for the plugin are identical to the microservice configuration.
See [Configuration Guide](Configuration.md) for details.

```javascript
var seneca = require('seneca')();

var config = {
    logger: { 
        level: 'debug' 
    },
    controller: {
        message: {
            from: "Somebody <somebody@gmail.com>"
        },
        connection: {
            service: "Gmail",
            host: "smtp.gmail.com",
            secureConnection: true,
            port: 465
        },
        credentials: {
            username: "somebody@gmail.com",
            password: "pass123"
        }
    }
};

var plugin = require('pip-services-email-node').EmailSenecaPlugin;

seneca.use(plugin, config);
```

You can use the microservice by calling seneca commands directly as described in [Seneca Protocol](SenecaProtocolV1.md)
or by using [EmailSenecaClient](https://github.com/pip-services-users/pip-clients-email-node/NodeClientApiV1.md/#client_seneca)