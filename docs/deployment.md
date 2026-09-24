
### Step 12: Push ke Semua Branch

```powershell
# Push development
git checkout development
git add .
git commit -m "docs: update README root untuk monorepo"
git push origin development

# Sync ke deployment
git checkout deployment
git merge development
git push origin deployment

# Sync ke main
git checkout main
git merge development
git push origin main