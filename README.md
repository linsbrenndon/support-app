🧰 Ferramentas de Suporte Técnico - PowerShell GUI

Uma ferramenta visual em PowerShell para auxiliar técnicos de suporte na manutenção e diagnóstico de computadores com Windows. O script usa XAML para criar uma interface gráfica com diversas funções integradas, organizadas em abas.
🖼️ Interface Visual

A interface contém 4 abas principais:
Sistema

Rede

Impressoras

Diagnóstico


🚀 Funcionalidades

✅ Abas e Ações

🖥️ Sistema

Reiniciar o computador
Melhorar desempenho (limpeza de arquivos e verificação SFC)
Verificar espaço em disco
Verificar atualizações do Windows
Backup rápido do registro
Desinstalar programas com filtro

🌐 Rede

Flush DNS
Limpar cache DNS do navegador (Chrome e Firefox)
Exibir informações completas de rede
Resetar configurações de rede
Ativar/desativar proxy
Teste de velocidade (download e upload)

🖨️ Impressoras

Correções para erros comuns de impressora:
0x0000011b
0x00000bcb
0x00000709
Reiniciar o serviço de spooler de impressão

🔍 Diagnóstico

Exibir top 10 processos por uso de CPU
Gerar relatório detalhado de hardware (sistema, CPU, discos)

📦 Requisitos

PowerShell 5.1 ou superior
Sistema operacional Windows
Execução de scripts habilitada:

    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

🛠️ Como Executar

Clone ou baixe este repositório.
Abra o PowerShell como administrador.
Execute o script:
    
    .\Ferramentas-Suporte.ps1

🔐 Permissões

Algumas funções exigem permissões de administrador, como:

Reinício do sistema
Reset da rede
Modificações no registro (correções de impressora)

📎 Observações

A função de desinstalação de programas utiliza Win32_Product, que pode ser lenta e forçar reinstalação de alguns softwares. Use com cautela.
O teste de velocidade usa URLs públicos (Fast.com e HttpBin.org). Requer conexão com a internet.
