# [WIP] MSN SYS

A modern lightweight mission system used to support TV events. It provides MDTs a working system to defend while also simplifying White Cell monitoring and execution.

## Components
 - dashboard (controller)
 - MX CPE
 - MX API
 - MX Data Server
 - MSN API
 - MSN Data Server

### Dashboard (`./dashboard`)

This exposes a dashboard UI (`5173` by default) that hosts the web app.

The valid routes are:
 - `/` - Displays links to the two available dashboards
 - `/msn` - Mission dashboard
 - `/mx` - Maintenance dashboard
 - `/control` - Control UI for both dashboards

The host that connects to the webapp then connects to the two API servers via websockets. To recieve data for the dashboards and send commands to the api servers. 

There is a catch all view for all other routes that discourages participants from enumerating the url paths.

### MSN API Server (`./msn_api_server`)

This starts a websocket server (`8888`) that registers clients in `dashboard` and `controller` groups. Controllers can issue commands to the API server, while Dashboards may receive data as a result of websocket commands.

Data servers also can connect to the `8888` websocket server at `/check-in` to register with the API server and start receiving data.
### MSN Data Server (`./msn-data-server`)

This server exposes a couple REST endpoints to send/receive data (`8008` by default).

  - GET `/` will return the content of `./data.json`
    - If the server hosts an intel endpoint it will also host mission data
  - POST `/` will write the request content to `./log`
  - POST `/updateMsn` will write the request content to `./data.json`

Also contains a websocket client to register with the API

### MX API Server (`./mx-api-dashboard`)

This starts a websocket server (`8888` by default) that registers clients in `dashboard` and `controller` groups. Controllers can issue commands to the API server, while Dashboards may receive data as a result of websocket commands.

Data servers also can connect to the `8888` websocket server at `/check-in` to register with the API server and start receiving data.

### MX Data Server (`./mx-data-server`)

This server exposes a couple REST endpoints to send/receive data (`8008` by default).

  - GET `/` will return the content of `./data.json`
  - POST `/` will write the request content to `./log`

  Also contains a websocket client to register with the API

# DOCKER NOTES
  The computers viewing the dashboard need access to API Containers!
  In your computers `hosts` file please add `msn-api` and `mx-api` as `127.0.0.1` 