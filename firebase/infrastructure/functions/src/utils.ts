import * as crypto from 'crypto';

export function hashPayload(data: unknown): string {
  return crypto.createHash('sha256').update(JSON.stringify(data)).digest('hex');
}

export function nowISO(): string {
  return new Date().toISOString();
}
