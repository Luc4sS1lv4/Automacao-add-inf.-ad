# Importa o módulo do AD 
Import-Module ActiveDirectory

# Caminho para o CSV
$docuser = Import-Csv "C:\Users\teste\Downloads\Email.csv"

# Função para remover acentos e substituir "ç" por "c"
function Remove-Acentos {
    param([string]$texto)

    # Substitui manualmente o ç/Ç
    $texto = $texto -replace "ç", "c" -replace "Ç", "C"

    # Remove acentos usando Normalization
    $normalized = $texto.Normalize([Text.NormalizationForm]::FormD)
    $semAcento = -join ($normalized.ToCharArray() | Where-Object {
        [Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne 'NonSpacingMark'
    })

    return $semAcento
}

# Obtém DN da raiz do domínio (para busca recursiva)
$rootDN = (Get-ADDomain -Server "caminho do servidor").DistinguishedName

# Coleta todos os logins do AD em letras minúsculas (para validação rápida)
$loginsMinusculos = Get-ADUser -Filter * -Server "caminho do servidor" -Properties SamAccountName |
    Select-Object -ExpandProperty SamAccountName |
    ForEach-Object { $_.ToLower() }

# Lista para armazenar usuários não encontrados
$usuariosNaoEncontrados = @()

foreach ($user in $docuser) {
    # Remove espaços, acentos e caracteres especiais dos nomes
    $Nome = Remove-Acentos($user.First_Name.Trim().Replace(" ", ""))
    $Ultimo_Nome = Remove-Acentos($user.Last_Name.Trim().Replace(" ", ""))
    $Login = "$Nome.$Ultimo_Nome".ToLower()
    $email = $user.Email
    $encontrado = $false

    if ($loginsMinusculos -contains $Login) {
        # Busca usuário diretamente a partir da OU raiz (busca recursiva)
        $adUser = Get-ADUser -Filter "SamAccountName -eq '$Login'" -SearchBase $rootDN "caminho do servidor" -Properties EmailAddress -ErrorAction SilentlyContinue

        if ($adUser) {
            if ([string]::IsNullOrEmpty($adUser.EmailAddress)) {
                Set-ADUser -Identity $adUser -EmailAddress $email "caminho do servidor"
                Write-Host -ForegroundColor Green "✔ Email de $Login atualizado para $email"
            } else {
                Write-Host -ForegroundColor Cyan "ℹ Email de $Login já está preenchido: $($adUser.EmailAddress)"
            }
            $encontrado = $true
        }
    } else {
        Write-Host -ForegroundColor Yellow "⚠ Login $Login não existe no domínio (lista de logins do AD)"
    }

    if (-not $encontrado) {
        Write-Host -ForegroundColor Yellow "⚠ Usuário $Login não encontrado no domínio"
        $usuariosNaoEncontrados += [pscustomobject]@{
            NomeCompleto = "$($user.First_Name) $($user.Last_Name)"
            Login        = $Login
            Email        = $email
            Motivo       = "Login não encontrado no AD ou sem objeto correspondente"
        }
    }
}

# Exporta relatório de logins não encontrados, se houver
if ($usuariosNaoEncontrados.Count -gt 0) {
    $caminhoRelatorio = "C:\scripts\usuarios_nao_encontrados.csv"
    $usuariosNaoEncontrados | Export-Csv -Path $caminhoRelatorio -NoTypeInformation -Encoding UTF8
    Write-Host -ForegroundColor Red "⚠ Relatório salvo em: $caminhoRelatorio"
} else {
    Write-Host -ForegroundColor Green "🎉 Todos os usuários foram encontrados com sucesso!"
}
