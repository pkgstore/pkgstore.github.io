## Installing packages

### Bash

### PowerShell

```powershell
$Ver = 'v0.0.0'; $App = 'example'; Invoke-Command -ScriptBlock $([scriptblock]::Create((Invoke-WebRequest -Uri 'https://pkgstore.ru/pwsh.install.txt').Content)) -ArgumentList ($args + @($App,$Ver))
```
