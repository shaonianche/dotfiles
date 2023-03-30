Set-Location $(Get-Location) && Set-Location ..
git add --all
git commit -m "changes on $(date)"
git pull --rebase
git push
