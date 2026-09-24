import { useCallback, useEffect, useState } from 'react';
import type { Package, PackageFormData } from '../types/package';
import {
  fetchPackages,
  createPackage,
  updatePackage,
  togglePackageActive,
} from '../lib/api/packages';

export function usePackages() {
  const [packages, setPackages] = useState<Package[]>([]);
  const [includeInactive, setIncludeInactive] = useState(false);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await fetchPackages(includeInactive);
      setPackages(data);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Gagal memuat data');
    } finally {
      setLoading(false);
    }
  }, [includeInactive]);

  useEffect(() => {
    load();
  }, [load]);

  const create = useCallback(
    async (data: PackageFormData) => {
      setSaving(true);
      try {
        await createPackage(data);
        await load();
      } finally {
        setSaving(false);
      }
    },
    [load]
  );

  const update = useCallback(
    async (id: string, data: Partial<PackageFormData>) => {
      setSaving(true);
      try {
        await updatePackage(id, data);
        await load();
      } finally {
        setSaving(false);
      }
    },
    [load]
  );

  const toggleActive = useCallback(
    async (id: string, isActive: boolean) => {
      try {
        await togglePackageActive(id, isActive);
        await load();
      } catch (e) {
        throw e;
      }
    },
    [load]
  );

  const filtered = search.trim()
    ? packages.filter((p) =>
        p.package_name.toLowerCase().includes(search.toLowerCase())
      )
    : packages;

  return {
    packages: filtered,
    includeInactive,
    setIncludeInactive,
    search,
    setSearch,
    loading,
    saving,
    error,
    reload: load,
    create,
    update,
    toggleActive,
  };
}