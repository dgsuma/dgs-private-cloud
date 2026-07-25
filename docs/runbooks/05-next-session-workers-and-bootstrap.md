
## 5. Review the new documents

```powershell
Get-ChildItem `
    .\docs\runbooks\04-talos-image-and-control-plane-vm.md,
    .\docs\runbooks\05-next-session-workers-and-bootstrap.md,
    .\docs\decisions\0004-talos-kubernetes-phase1-architecture.md |
    Select-Object Name,Length,LastWriteTime

git status
git diff --check
git diff --stat