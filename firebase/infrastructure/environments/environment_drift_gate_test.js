/**
 * Phase 6 drift gate：manifest（环境权威）↔ runtime/deploy 配置一致性 + fail-closed。
 *
 * 覆盖（DISPATCH §6 Phase 6.7 / Gate 6）：
 * 1. manifest ↔ .firebaserc（default/staging/production alias）drift；
 * 2. manifest.functionsRegion ↔ functions/src 所有 callable region（region smoke）；
 * 3. fail-closed：非法 manifest（schemaVersion/未知环境/缺 projectId/端口缺失/
 *    重复端口/staging 带 emulator/生产 allowAll）必须被 validateManifest 拒绝；
 * 4. 四核心端口（auth/firestore/storage/functions）必须齐备且互异。
 */
'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');
const { validateManifest, CORE_PORTS } = require('./validate-manifest');

const environmentsDirectory = __dirname;
const infrastructureDirectory = path.resolve(environmentsDirectory, '..');
const manifestPath = path.join(
  environmentsDirectory,
  'firebase-environments.json',
);
const firebasercPath = path.join(infrastructureDirectory, '.firebaserc');
const functionsSrcDirectory = path.join(
  infrastructureDirectory,
  'functions/src',
);

function readManifest() {
  return JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
}

test('manifest 自身通过 validateManifest（权威配置合法）', () => {
  const { ok, errors } = validateManifest(readManifest());
  assert.equal(ok, true, errors.join('; '));
});

test('manifest ↔ .firebaserc：staging/production/default alias 无 drift', () => {
  const manifest = readManifest();
  const firebaserc = JSON.parse(fs.readFileSync(firebasercPath, 'utf8'));
  const projects = firebaserc.projects;

  assert.equal(
    projects.default,
    manifest.environments.development.projectId,
    '.firebaserc default 必须等于 manifest development.projectId（LAN Emulator 项目）',
  );
  assert.equal(
    projects.staging,
    manifest.environments.staging.projectId,
    '.firebaserc staging 必须等于 manifest staging.projectId',
  );
  assert.equal(
    projects.production,
    manifest.environments.production.projectId,
    '.firebaserc production 必须等于 manifest production.projectId',
  );
});

test('region smoke：functions/src 所有 callable 均为 asia-east1（manifest.functionsRegion）', () => {
  const manifest = readManifest();
  const region = manifest.functionsRegion;

  const files = fs
    .readdirSync(functionsSrcDirectory)
    .filter((f) => f.endsWith('.ts'));
  assert.ok(files.length > 0, 'functions/src 必须存在 TS 文件');

  let callableCount = 0;
  for (const file of files) {
    const content = fs.readFileSync(
      path.join(functionsSrcDirectory, file),
      'utf8',
    );
    const matches = content.matchAll(/onCall\(\s*\{\s*region:\s*'([^']+)'/g);
    for (const m of matches) {
      callableCount += 1;
      assert.equal(
        m[1],
        region,
        `${file} 中 callable region 必须为 ${region}，实际 ${m[1]}`,
      );
    }
  }
  assert.ok(callableCount >= 1, 'functions/src 必须至少含一个 callable');
});

test('fail-closed：非法 manifest 全部被拒绝（不默许）', () => {
  const base = readManifest();

  // 1. schemaVersion 未知
  const badSchema = structuredClone(base);
  badSchema.schemaVersion = 2;
  assert.equal(validateManifest(badSchema).ok, false, 'schemaVersion=2 必须拒绝');

  // 2. 未知环境集
  const badEnvs = structuredClone(base);
  delete badEnvs.environments.production;
  assert.equal(validateManifest(badEnvs).ok, false, '缺 production 必须拒绝');

  // 3. 缺 projectId
  const badProject = structuredClone(base);
  delete badProject.environments.staging.projectId;
  assert.equal(validateManifest(badProject).ok, false, '缺 projectId 必须拒绝');

  // 4. development 缺核心端口
  const badPorts = structuredClone(base);
  delete badPorts.environments.development.emulator.ports.functions;
  assert.equal(
    validateManifest(badPorts).ok,
    false,
    'development 缺 functions 端口必须拒绝',
  );

  // 5. 端口重复
  const dupPorts = structuredClone(base);
  dupPorts.environments.development.emulator.ports.storage =
    dupPorts.environments.development.emulator.ports.firestore;
  assert.equal(
    validateManifest(dupPorts).ok,
    false,
    'development 端口重复必须拒绝',
  );

  // 6. staging 带 emulator（零 emulator host 被违反）
  const stagingEmu = structuredClone(base);
  stagingEmu.environments.staging.emulator = {
    host: '192.168.0.165',
    ports: { auth: 9099, firestore: 8080, storage: 9199, functions: 5001 },
  };
  assert.equal(
    validateManifest(stagingEmu).ok,
    false,
    'staging 不得含 emulator',
  );

  // 7. 生产 allowAllRules
  const prodAllowAll = structuredClone(base);
  prodAllowAll.environments.production.emulator = {
    host: '192.168.0.165',
    ports: { auth: 9099, firestore: 8080, storage: 9199, functions: 5001 },
    allowAllRules: true,
  };
  assert.equal(
    validateManifest(prodAllowAll).ok,
    false,
    'production 不得 allowAllRules',
  );
});

test('四核心端口在 development/test 中齐备且互异', () => {
  const manifest = readManifest();
  for (const name of ['development', 'test']) {
    const ports = manifest.environments[name].emulator.ports;
    const values = CORE_PORTS.map((s) => ports[s]);
    assert.ok(
      values.every((p) => Number.isInteger(p) && p > 0),
      `${name} 核心端口必须为正整数`,
    );
    assert.equal(new Set(values).size, CORE_PORTS.length, `${name} 核心端口互异`);
  }
});
