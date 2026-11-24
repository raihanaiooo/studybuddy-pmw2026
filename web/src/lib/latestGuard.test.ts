import { describe, expect, it } from 'vitest';
import { createLatestGuard } from './latestGuard';

describe('createLatestGuard', () => {
  it('hanya permintaan terbaru yang dianggap berlaku', () => {
    const guard = createLatestGuard();
    const first = guard.next();
    expect(guard.isCurrent(first)).toBe(true);
    const second = guard.next();
    expect(guard.isCurrent(first)).toBe(false);
    expect(guard.isCurrent(second)).toBe(true);
  });

  it('respons lama yang datang terlambat diabaikan', () => {
    const guard = createLatestGuard();
    const applied: string[] = [];
    const a = guard.next();
    const b = guard.next();
    if (guard.isCurrent(b)) applied.push('b');
    if (guard.isCurrent(a)) applied.push('a');
    expect(applied).toEqual(['b']);
  });
});
