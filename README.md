# agdg-cli
Cliente CLI para o tópico geral do agdg no 4chan.

Programinha simples para ler os fios do /agdg/ direto no terminal.

# Funcionalidades

- [X] Ler fios
- [X] Link de arquivos
- [X] Baixar todos os arquivos

Você pode usar sem precisar baixar, basta chamar o script pela internet.
```powershell
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ussaohelcim/agdg-cli/main/agdg.ps1'))
```