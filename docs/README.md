## Installing packages

### Bash

```bash
ver='v0.0.0'; app='example'; curl -sL 'https://pkgstore.ru/bash.install.sh' | bash -s -- "${app}" "${ver}"
```

### PowerShell

```powershell
$Ver = 'v0.0.0'; $App = 'example'; Invoke-Command -ScriptBlock $([scriptblock]::Create((Invoke-WebRequest -Uri 'https://pkgstore.ru/pwsh.install.txt').Content)) -ArgumentList ($args + @($App, $Ver))
```
