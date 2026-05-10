# Load Balancer Client

Flutter Web dashboard for the load balancer demo.

```sh
flutter pub get
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8081
```

Use the Nginx base URL field to target `http://localhost`,
`http://127.0.0.1`, or a LAN IP where Nginx is exposed.

Nginx sends a CORS response header for the demo, so the Flutter development
server can call the existing `GET /` endpoint from a different port.
