/**
 * 环境 manifest 校验器（Phase 6 fail-closed 门禁）。
 *
 * 可复用：environment_manifest_test.js 与 environment_drift_gate_test.js
 * 均通过 validateManifest() 断言非法 manifest 被拒绝。
 *
 * 规则（PRD §5.4 / DISPATCH §6 Phase 6）：
 * - schemaVersion 必须为 1；functionsRegion 必须为 'us-central1'；
 * - 环境集必须恰为 { development, test, staging, production }；
 * - 每个环境必须含非空 projectId；
 * - development/test：emulator 必须存在且含 host + 四核心端口
 *   （auth/firestore/storage/functions，端口为正整数且互异）；allowAllRules 可为 true；
 * - staging/production：emulator 必须为 null（零 emulator host）；
 * - allowAllRules 只允许出现在 development/test。
 */
'use strict';

const CORE_PORTS = ['auth', 'firestore', 'storage', 'functions'];
const REQUIRED_ENVIRONMENTS = ['development', 'test', 'staging', 'production'];

/**
 * @param {unknown} raw 待校验的 manifest（JSON.parse 结果）
 * @returns {{ ok: boolean; errors: string[] }}
 */
function validateManifest(raw) {
  const errors = [];

  if (!raw || typeof raw !== 'object') {
    return { ok: false, errors: ['manifest 不是对象'] };
  }
  const manifest = /** @type {any} */ (raw);

  if (manifest.schemaVersion !== 1) {
    errors.push(`schemaVersion 必须为 1，实际 ${String(manifest.schemaVersion)}`);
  }
  if (manifest.functionsRegion !== 'us-central1') {
    errors.push(
      `functionsRegion 必须为 us-central1，实际 ${String(manifest.functionsRegion)}`,
    );
  }

  const envNames = Object.keys(manifest.environments ?? {}).sort();
  const expected = [...REQUIRED_ENVIRONMENTS].sort();
  if (JSON.stringify(envNames) !== JSON.stringify(expected)) {
    errors.push(`环境集必须恰为 ${expected.join('/')}，实际 ${envNames.join('/')}`);
  }

  for (const name of REQUIRED_ENVIRONMENTS) {
    const env = manifest.environments?.[name];
    if (!env || typeof env !== 'object') {
      errors.push(`${name} 环境缺失`);
      continue;
    }
    if (typeof env.projectId !== 'string' || env.projectId.length === 0) {
      errors.push(`${name}.projectId 必须为非空字符串`);
    }

    const isDevOrTest = name === 'development' || name === 'test';
    if (isDevOrTest) {
      const emu = env.emulator;
      if (!emu || typeof emu !== 'object' || emu === null) {
        errors.push(`${name}.emulator 必须存在（LAN Emulator）`);
      } else {
        if (typeof emu.host !== 'string' || emu.host.length === 0) {
          errors.push(`${name}.emulator.host 必须为非空字符串`);
        }
        const ports = emu.ports ?? {};
        const seen = new Set();
        for (const service of CORE_PORTS) {
          const p = ports[service];
          if (!Number.isInteger(p) || p <= 0 || p > 65535) {
            errors.push(`${name}.emulator.ports.${service} 必须为合法端口`);
          } else if (seen.has(p)) {
            errors.push(`${name}.emulator.ports 端口重复: ${service}=${p}`);
          } else {
            seen.add(p);
          }
        }
      }
    } else {
      // staging / production：零 emulator host
      if (env.emulator !== null && env.emulator !== undefined) {
        errors.push(`${name}.emulator 必须为 null（零 emulator host）`);
      }
    }
  }

  // allowAllRules 只允许 development/test
  for (const [name, env] of Object.entries(manifest.environments ?? {})) {
    const allowAll = env?.emulator?.allowAllRules === true;
    if (allowAll && name !== 'development' && name !== 'test') {
      errors.push(`${name} 不得启用 allowAllRules`);
    }
  }

  return { ok: errors.length === 0, errors };
}

module.exports = { validateManifest, CORE_PORTS, REQUIRED_ENVIRONMENTS };
