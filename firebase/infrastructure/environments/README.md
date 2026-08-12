# Firebase environments

`firebase-environments.json` is the source of truth for selecting Firebase
projects and emulator endpoints in this repository.

| Environment | Firebase project | Runtime target |
| --- | --- | --- |
| Development | `demo-xuan` | LAN Emulator Suite at `192.168.0.165` |
| Test | `demo-xuan` | LAN Emulator Suite at `192.168.0.165` |
| Staging | `xuan-staging` | Managed Firebase services; no emulator |
| Production | `xuan-production` | Managed Firebase services; no emulator |

## LAN Emulator Suite

The development and test environments share a Firebase Emulator Suite deployed
by the Nomad job `firebase-emulator`. It runs through rootful Podman using the
image `docker.io/andreysenov/firebase-tools:latest` in the
`firebase-emulator-nomad` container.

All 8 services listen on `0.0.0.0` across 8 ports.

| Service | Port | Health check |
| --- | ---: | --- |
| Authentication | `9099` | HTTP 200; `ready=true` |
| Firestore | `8080` | HTTP 200 |
| Storage | `9199` | HTTP 501 at the root path is expected |
| Functions | `5001` | `helloWorld` returns JSON |
| Pub/Sub | `8085` | HTTP 200 |
| Emulator UI | `4000` | HTTP 200 |
| Hub | `4400` | HTTP 200 |
| Logging | `4500` | HTTP 426 at the WebSocket endpoint is expected |

The remote host persists its emulator files at:

- Configuration and rules: `/opt/podman/firebase/config/`
- Functions source and dependencies: `/opt/podman/firebase/functions/`
- Exported emulator data: `/opt/podman/firebase/data/`

Within the Functions mount, `functions/node_modules` is persisted and real Functions source can be hot-reloaded. The mounted configuration, source, dependencies, and exported data mean Nomad job restarts and container rebuilds do not lose data.

This repository only records how clients select that environment; it does not modify the remote deployment or any files under `/opt/podman/firebase/`.

## Safety boundary

The Emulator Suite must remain behind a trusted LAN boundary or firewall and must never be exposed to the public internet or an untrusted network. Its allow-all rules let any client that can reach the emulator read and write development and test data.

Allow-all rules are permitted only for the `development` and `test` emulator
environments. The LAN emulator is a development convenience and must not be treated as evidence that production Security Rules are safe. Staging and production must continue to use their own reviewed and tested Security Rules.
