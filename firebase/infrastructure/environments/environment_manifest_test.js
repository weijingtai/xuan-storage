const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');

const environmentsDirectory = __dirname;
const manifestPath = path.join(
  environmentsDirectory,
  'firebase-environments.json',
);
const readmePath = path.join(environmentsDirectory, 'README.md');

test('manifest schema and environment set are explicit and closed', () => {
  assert.ok(fs.existsSync(manifestPath), 'environment manifest must exist');

  const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
  assert.equal(manifest.schemaVersion, 1);
  assert.deepEqual(Object.keys(manifest.environments).sort(), [
    'development',
    'production',
    'staging',
    'test',
  ]);
});

test('development and test use the LAN Firebase Emulator Suite', () => {
  assert.ok(fs.existsSync(manifestPath), 'environment manifest must exist');

  const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
  const expectedPorts = {
    auth: 9099,
    firestore: 8080,
    storage: 9199,
    functions: 5001,
    pubsub: 8085,
    ui: 4000,
    hub: 4400,
    logging: 4500,
  };

  for (const environmentName of ['development', 'test']) {
    const environment = manifest.environments[environmentName];
    assert.equal(environment.projectId, 'demo-xuan');
    assert.deepEqual(environment.emulator, {
      host: '192.168.0.165',
      ports: expectedPorts,
      allowAllRules: true,
    });
  }
});

test('staging and production use isolated Firebase projects without emulators', () => {
  assert.ok(fs.existsSync(manifestPath), 'environment manifest must exist');

  const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
  assert.deepEqual(manifest.environments.staging, {
    projectId: 'xuan-staging',
    emulator: null,
  });
  assert.deepEqual(manifest.environments.production, {
    projectId: 'xuan-production',
    emulator: null,
  });
});

test('allow-all rules are confined to development and test', () => {
  assert.ok(fs.existsSync(manifestPath), 'environment manifest must exist');

  const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
  const allowAllEnvironments = Object.entries(manifest.environments)
    .filter(([, environment]) => environment.emulator?.allowAllRules === true)
    .map(([environmentName]) => environmentName)
    .sort();

  assert.deepEqual(allowAllEnvironments, ['development', 'test']);
});

test('README documents the external LAN deployment and safety boundary', () => {
  assert.ok(fs.existsSync(readmePath), 'environment README must exist');

  const readme = fs.readFileSync(readmePath, 'utf8');
  for (const requiredText of [
    'firebase-emulator',
    'rootful Podman',
    'docker.io/andreysenov/firebase-tools:latest',
    '/opt/podman/firebase/config/',
    '/opt/podman/firebase/functions/',
    '/opt/podman/firebase/data/',
    'does not modify the remote deployment',
    'must not be treated as evidence that production Security Rules are safe',
    'All 8 services listen on `0.0.0.0` across 8 ports.',
    'Authentication | `9099` | HTTP 200; `ready=true`',
    'Firestore | `8080` | HTTP 200',
    'Storage | `9199` | HTTP 501 at the root path is expected',
    'Functions | `5001` | `helloWorld` returns JSON',
    'Pub/Sub | `8085` | HTTP 200',
    'Emulator UI | `4000` | HTTP 200',
    'Hub | `4400` | HTTP 200',
    'Logging | `4500` | HTTP 426 at the WebSocket endpoint is expected',
    'firebase-emulator-nomad',
    '`functions/node_modules` is persisted',
    'real Functions source can be hot-reloaded',
    'Nomad job restarts and container rebuilds do not lose data',
    'must remain behind a trusted LAN boundary or firewall',
    'must never be exposed to the public internet or an untrusted network',
    'allow-all rules let any client that can reach the emulator read and write development and test data',
  ]) {
    assert.match(readme, new RegExp(requiredText.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')));
  }
});
