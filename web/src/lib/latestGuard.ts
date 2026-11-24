/** Penjaga "permintaan terbaru": respons dari permintaan yang sudah tersusul diabaikan. */
export function createLatestGuard() {
  let latest = 0;
  return {
    next(): number {
      latest += 1;
      return latest;
    },
    isCurrent(ticket: number): boolean {
      return ticket === latest;
    },
  };
}
