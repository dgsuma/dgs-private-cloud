$ErrorActionPreference = "Stop"

Write-Host "Checking Phase 1 workstation tools..." -ForegroundColor Cyan

git --version
gh --version
kubectl version --client
talosctl version --client
flux --version
sops --version
age --version
age-keygen --version

Write-Host "`nAll required commands executed successfully." -ForegroundColor Green
