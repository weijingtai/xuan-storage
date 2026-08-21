/**
 * Phase 6 drift gate：manifest（环境权威）↔ runtime/deploy 配置一致性 + fail-closed。
 *
 * 覆盖（DISPATCH §6 Phase 6.7 / Gate 6）：
 * 1. manifest ↔ .firebaserc（default/staging/production alias）drift；
 * 2. manifest.functionsRegion ↔ Python 侧 REGION 常量 + 调用点不得写死区域（region smoke）；
 *    ⚠ 2026-08-21：TS 版已归档退场，本项改为扫 functions-py。旧版扫 functions/src/*.ts，
 *      TS 归档后该断言守的是空壳，看着绿但与线上实现无关。
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
const pythonHandlersDirectory = path.join(
  infrastructureDirectory,
  'functions-py/xuan/handlers',
);
const pythonConfigPath = path.join(
  infrastructureDirectory,
  'functions-py/xuan/config.py',
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

test('region smoke：Python 侧 REGION 常量 == manifest.functionsRegion', () => {
  const manifest = readManifest();
  const config = fs.readFileSync(pythonConfigPath, 'utf8');

  const m = config.match(/^REGION\s*=\s*"([^"]+)"/m);
  assert.ok(m, 'config.py 必须定义 REGION 常量');
  assert.equal(
    m[1],
    manifest.functionsRegion,
    `config.py 的 REGION 必须等于 manifest.functionsRegion（${manifest.functionsRegion}）`,
  );
});

test('region smoke：所有 callable 必须走 REGION 常量，不得写死区域字面量', () => {
  const files = fs
    .readdirSync(pythonHandlersDirectory)
    .filter((f) => f.endsWith('.py'));
  assert.ok(files.length > 0, 'functions-py/xuan/handlers 必须存在 Python 文件');

  let callableCount = 0;
  for (const file of files) {
    const content = fs.readFileSync(
      path.join(pythonHandlersDirectory, file),
      'utf8',
    );
    // @https_fn.on_call(...) 的参数部分
    const matches = content.matchAll(/@https_fn\.on_call\(([^)]*)\)/g);
    for (const match of matches) {
      callableCount += 1;
      const args = match[1];
      assert.match(
        args,
        /region\s*=\s*REGION\b/,
        `${file} 中的 on_call 必须写 region=REGION，实际参数：${args.trim()}`,
      );
    }
  }
  assert.ok(callableCount >= 1, 'handlers 必须至少含一个 callable');
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
