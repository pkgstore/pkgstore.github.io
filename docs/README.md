# Package Store

## Installing packages

### Bash

### PowerShell

```powershell
$App = 'example'; $Ver = 'v0.1.0'; Invoke-Command -ScriptBlock $([scriptblock]::Create((Invoke-WebRequest -Uri 'https://pkgstore.github.io/pwsh.install.txt').Content)) -ArgumentList ($args + @($App,$Ver))
```
