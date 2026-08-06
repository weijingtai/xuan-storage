# storage-theme-drift

把 S5a 的内存版主题存储（`InMemoryThemeResourceStore`）落地为 drift (SQLite) 实现，让主题在进程重启后仍然存在；内存版作为 reference 实现与测试 fake 保留不动。
