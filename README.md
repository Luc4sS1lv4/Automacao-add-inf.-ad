# Script de Atualização de E-mails no Active Directory (AD)

Este repositório contém um script PowerShell para automatizar a atualização do campo de e-mail dos usuários no Active Directory (AD), utilizando como base um arquivo `.CSV` com as informações dos colaboradores.

## Objetivo

Automatizar o preenchimento do campo `EmailAddress` no AD com base em dados externos, garantindo padronização, redução de falhas manuais e preparando o ambiente para integrações via LDAP.

## Estrutura Esperada do CSV

O script requer um arquivo `.CSV` com a seguinte estrutura:

| Coluna       | Descrição                         | Exemplo                        |
|--------------|-----------------------------------|--------------------------------|
| First_Name   | Primeiro nome do colaborador      | Lucas                          |
| Last_Name    | Último nome ou sobrenome          | Santos                         |
| Email        | E-mail corporativo a ser inserido | lucas.santos@empresa.com       |

## Requisitos

- PowerShell 5.1 ou superior
- Módulo `ActiveDirectory` instalado
- Permissões administrativas no domínio
- Conectividade com o controlador de domínio
- Permissão de leitura e escrita no AD

## Execução

1. Clone o repositório:
   ```bash
   git clone https://github.com/Luc4sS1lv4/Automacao-add-inf.-ad/
