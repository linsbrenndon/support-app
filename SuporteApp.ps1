Add-Type -AssemblyName PresentationFramework

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Menu do Suporte Técnico" Height="530" Width="650"
        WindowStartupLocation="CenterScreen">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="25"/>
        </Grid.RowDefinitions>

        <TabControl Grid.Row="0">
            <TabItem Header="Sistema">
                <StackPanel Margin="10">
                    <Button Name="btnReiniciar" Content="Reiniciar Computador" Margin="5"/>
                    <Button Name="btnLentidao" Content="Melhorar Desempenho (Limpeza e SFC)" Margin="5"/>
                    <Button Name="btnEspacoDisco" Content="Verificar Espaço em Disco" Margin="5"/>
                    <Button Name="btnAtualizacao" Content="Verificar Atualizações do Windows" Margin="5"/>
                    <Button Name="btnBackupRegistro" Content="Backup Rápido do Registro" Margin="5"/>
                    <Button Name="btnDesinstalar" Content="Desinstalar Programas" Margin="5"/>
                </StackPanel>
            </TabItem>
            <TabItem Header="Rede">
                <StackPanel Margin="10">
                    <Button Name="btnFlush" Content="Flush DNS" Margin="5"/>
                    <Button Name="btnFlushNavegador" Content="Limpar Cache DNS Navegador" Margin="5"/>
                    <Button Name="btnIpAll" Content="Exibir Informações de Rede" Margin="5"/>
                    <Button Name="btnResetRede" Content="Resetar Configurações de Rede" Margin="5"/>
                    <Button Name="btnProxy" Content="Configurar Proxy (On/Off)" Margin="5"/>
                    <Button Name="btnSpeedTest" Content="Teste de Rede" Margin="5"/>
                </StackPanel>
            </TabItem>
            <TabItem Header="Impressoras">
                <StackPanel Margin="10">
                    <Button Name="btnErro11b" Content="Corrigir erro 0x0000011b" Margin="5"/>
                    <Button Name="btnErro0bcb" Content="Corrigir erro 0x00000bcb" Margin="5"/>
                    <Button Name="btnErro709" Content="Corrigir erro 0x00000709" Margin="5"/>
                    <Button Name="btnSpooler" Content="Reiniciar Spooler de Impressão" Margin="5"/>
                </StackPanel>
            </TabItem>
            <TabItem Header="Diagnóstico">
                <StackPanel Margin="10">
                    <Button Name="btnProcessos" Content="Visualizar Processos em Execução" Margin="5"/>
                    <Button Name="btnHardware" Content="Relatório de Hardware" Margin="5"/>
                </StackPanel>
            </TabItem>
        </TabControl>

        <TextBlock Name="txtStatus" Grid.Row="1" Margin="10,0" Foreground="LightGray" FontSize="12"/>

        <ProgressBar Name="progressBar" Grid.Row="2" Height="20" Margin="10,0,10,10"
                     Minimum="0" Maximum="100" Visibility="Collapsed"/>
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader ([xml]$xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Barra e status
$ProgressBar = $window.FindName("progressBar")
$StatusText = $window.FindName("txtStatus")

function Mostrar-Barra($texto = "Processando...") {
    $ProgressBar.Dispatcher.Invoke([action]{
        $ProgressBar.Value = 0
        $ProgressBar.Visibility = "Visible"
        $StatusText.Text = $texto
    })
}
function Atualizar-Barra($valor) {
    $ProgressBar.Dispatcher.Invoke([action]{
        $ProgressBar.Value = $valor
    })
}
function Esconder-Barra {
    $ProgressBar.Dispatcher.Invoke([action]{
        $ProgressBar.Visibility = "Collapsed"
        $StatusText.Text = ""
    })
}

function Desativar-Todos-Botoes {
    $window.Dispatcher.Invoke([action]{
        foreach ($btn in $window.FindName("btnReiniciar").Parent.Children) {
            if ($btn -is [System.Windows.Controls.Button]) {
                $btn.IsEnabled = $false
            }
        }
    })
}
function Ativar-Todos-Botoes {
    $window.Dispatcher.Invoke([action]{
        foreach ($btn in $window.FindName("btnReiniciar").Parent.Children) {
            if ($btn -is [System.Windows.Controls.Button]) {
                $btn.IsEnabled = $true
            }
        }
    })
}

# Função melhorada de limpeza + progresso simulado
function Melhorar-Desempenho {
    Desativar-Todos-Botoes
    Mostrar-Barra "Iniciando limpeza e verificação SFC..."

    # Simulação simples de progresso para exibir
    for ($i = 0; $i -le 100; $i += 10) {
        Atualizar-Barra $i
        Start-Sleep -Milliseconds 300
    }

    # Executa limpeza real em background
    Start-Job -ScriptBlock {
        Start-Process explorer.exe -ArgumentList $env:TEMP
        Start-Process explorer.exe -ArgumentList "$env:SystemRoot\SoftwareDistribution\Download"
        Start-Process explorer.exe -ArgumentList "$env:LocalAppData\Microsoft\Windows\Explorer"
        Start-Process explorer.exe -ArgumentList "C:\Windows\Prefetch"

        sfc /scannow | Out-Null

        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:SystemRoot\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:LocalAppData\Microsoft\Windows\Explorer\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
    } | Wait-Job | Out-Null

    Esconder-Barra
    Ativar-Todos-Botoes
    [System.Windows.MessageBox]::Show("Operação concluída.","Sucesso",[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Information)
}

# Janela de input para desinstalar sem Microsoft.VisualBasic
function Show-UninstallWindow {
    [xml]$inputXAML = @"
<Window xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation' Title='Desinstalar Programa' Height='160' Width='400' WindowStartupLocation='CenterScreen' ResizeMode='NoResize'>
    <Grid Margin='10'>
        <Grid.RowDefinitions>
            <RowDefinition Height='Auto'/>
            <RowDefinition Height='Auto'/>
            <RowDefinition Height='Auto'/>
        </Grid.RowDefinitions>
        <TextBlock Text='Digite parte do nome do programa para desinstalar:' Margin='5'/>
        <TextBox Name='txtPrograma' Grid.Row='1' Margin='5'/>
        <StackPanel Grid.Row='2' Orientation='Horizontal' HorizontalAlignment='Right' Margin='5'>
            <Button Name='btnOK' Content='OK' Width='75' Margin='5'/>
            <Button Name='btnCancelar' Content='Cancelar' Width='75' Margin='5'/>
        </StackPanel>
    </Grid>
</Window>
"@

    $reader = New-Object System.Xml.XmlNodeReader $inputXAML
    $win = [Windows.Markup.XamlReader]::Load($reader)
    $txt = $win.FindName("txtPrograma")
    $btnOK = $win.FindName("btnOK")
    $btnCancelar = $win.FindName("btnCancelar")

    $result = $null

    $btnOK.Add_Click({
        $result = $txt.Text
        $win.Close()
    })
    $btnCancelar.Add_Click({
        $result = $null
        $win.Close()
    })

    $win.ShowDialog() | Out-Null
    return $result
}

function Desinstalar-Programa-UI {
    $programa = Show-UninstallWindow
    if ($programa) {
        $apps = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*$programa*" }
        if ($apps) {
            foreach ($app in $apps) {
                $res = $app.Uninstall()
                if ($res.ReturnValue -eq 0) {
                    [System.Windows.MessageBox]::Show("Programa '$($app.Name)' desinstalado com sucesso.","Desinstalar")
                } else {
                    [System.Windows.MessageBox]::Show("Falha ao desinstalar '$($app.Name)'.","Desinstalar")
                }
            }
        } else {
            [System.Windows.MessageBox]::Show("Programa não encontrado.","Desinstalar")
        }
    }
}

# Associar eventos
$window.FindName("btnReiniciar").Add_Click({ Restart-Computer -Force })
$window.FindName("btnLentidao").Add_Click({ Melhorar-Desempenho })
$window.FindName("btnEspacoDisco").Add_Click({
    $drives = Get-PSDrive -PSProvider FileSystem | ForEach-Object {
        [PSCustomObject]@{
            Nome = $_.Name
            UsadoGB = [math]::Round(($_.Used / 1GB),2)
            LivreGB = [math]::Round(($_.Free / 1GB),2)
            TotalGB = [math]::Round((($_.Used + $_.Free) / 1GB),2)
        }
    }
    $msg = $drives | Format-Table -AutoSize | Out-String
    [System.Windows.MessageBox]::Show($msg,"Espaço em Disco")
})
$window.FindName("btnAtualizacao").Add_Click({
    try {
        Install-Module PSWindowsUpdate -Force -Scope CurrentUser -ErrorAction SilentlyContinue | Out-Null
        Import-Module PSWindowsUpdate -ErrorAction Stop
        $updates = Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot -ErrorAction Stop
        if ($updates) {
            $msg = "Atualizações disponíveis:`n" + ($updates | Out-String)
        } else {
            $msg = "Nenhuma atualização disponível."
        }
    } catch {
        $msg = "Erro ao verificar atualizações: $_"
    }
    [System.Windows.MessageBox]::Show($msg,"Atualizações do Windows")
})
$window.FindName("btnBackupRegistro").Add_Click({
    $backupPath = "$env:USERPROFILE\Desktop\Backup_Registro_$(Get-Date -Format yyyyMMdd_HHmmss).reg"
    reg export "HKLM\SYSTEM\CurrentControlSet" $backupPath /y | Out-Null
    [System.Windows.MessageBox]::Show("Backup salvo em: $backupPath","Backup do Registro")
})
$window.FindName("btnDesinstalar").Add_Click({ Desinstalar-Programa-UI })

function Testar-VelocidadeRede {
    try {
        Add-Type -AssemblyName System.Windows.Forms
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        $downloadUrl = "https://fast.com/app-ed402d.js"
        $tempDownload = [System.IO.Path]::GetTempFileName()
        $webClient = New-Object System.Net.WebClient
        $swDownload = [System.Diagnostics.Stopwatch]::StartNew()
        $webClient.DownloadFile($downloadUrl, $tempDownload)
        $swDownload.Stop()
        $downloadSize = (Get-Item $tempDownload).Length
        Remove-Item $tempDownload -Force
        $downloadMbps = [Math]::Round((($downloadSize * 8) / $swDownload.Elapsed.TotalSeconds) / 1MB, 2)

        $uploadUrl = "https://httpbin.org/post"
        $webClient = New-Object System.Net.WebClient
        $dummyData = [System.Text.Encoding]::UTF8.GetBytes(("X" * 1MB))
        $swUpload = [System.Diagnostics.Stopwatch]::StartNew()
        $webClient.UploadData($uploadUrl, "POST", $dummyData) | Out-Null
        $swUpload.Stop()
        $uploadMbps = [Math]::Round(((1MB * 8) / $swUpload.Elapsed.TotalSeconds) / 1MB, 2)

        $mensagem = "`n↓ Download: $downloadMbps Mbps`n↑ Upload: $uploadMbps Mbps"
        [System.Windows.Forms.MessageBox]::Show($mensagem, "Teste de Velocidade", 'OK', 'Information')

    } catch {
        [System.Windows.Forms.MessageBox]::Show("Erro ao testar velocidade: $_", "Erro", 'OK', 'Error')
    }
}

$window.FindName("btnFlush").Add_Click({
    ipconfig /flushdns | Out-Null
    [System.Windows.MessageBox]::Show("Cache DNS limpo.","Flush DNS")
})
$window.FindName("btnFlushNavegador").Add_Click({
    $chromeCache = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
    if (Test-Path $chromeCache) {
        Remove-Item -Path "$chromeCache\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
    $firefoxCache = "$env:APPDATA\Mozilla\Firefox\Profiles"
    if (Test-Path $firefoxCache) {
        Get-ChildItem $firefoxCache -Recurse -Include cache2 | ForEach-Object {
            Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    [System.Windows.MessageBox]::Show("Cache DNS dos navegadores limpo.","Limpar Cache DNS Navegador")
})
$window.FindName("btnIpAll").Add_Click({
    $info = ipconfig /all | Out-String
    [System.Windows.MessageBox]::Show($info,"Informações de Rede")
})
$window.FindName("btnResetRede").Add_Click({
    netsh int ip reset | Out-Null
    netsh winsock reset | Out-Null
    ipconfig /release | Out-Null
    ipconfig /renew | Out-Null
    [System.Windows.MessageBox]::Show("Configurações de rede resetadas.","Resetar Rede")
})
$window.FindName("btnProxy").Add_Click({
    if ($global:proxyState) {
        netsh winhttp reset proxy | Out-Null
        $global:proxyState = $false
        [System.Windows.MessageBox]::Show("Proxy desativado.","Proxy")
    } else {
        netsh winhttp set proxy proxy-server="http=proxy.exemplo.com:8080" | Out-Null
        $global:proxyState = $true
        [System.Windows.MessageBox]::Show("Proxy ativado.","Proxy")
    }
})

$window.FindName("btnSpeedTest").Add_Click({ Testar-VelocidadeRede })

$window.FindName("btnErro11b").Add_Click({
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0 /f | Out-Null
    [System.Windows.MessageBox]::Show("Erro 0x0000011b corrigido.","Correção")
})
$window.FindName("btnErro0bcb").Add_Click({
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v RestrictDriverInstallationToAdministrators /t REG_DWORD /d 0 /f | Out-Null
    [System.Windows.MessageBox]::Show("Erro 0x00000bcb corrigido.","Correção")
})
$window.FindName("btnErro709").Add_Click({
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcUseNamedPipeProtocol /t REG_DWORD /d 1 /f | Out-Null
    [System.Windows.MessageBox]::Show("Erro 0x00000709 corrigido.","Correção")
})
$window.FindName("btnSpooler").Add_Click({
    net stop spooler | Out-Null
    Start-Sleep -Seconds 3
    net start spooler | Out-Null
    [System.Windows.MessageBox]::Show("Spooler reiniciado com sucesso.","Spooler")
})

$window.FindName("btnProcessos").Add_Click({
    $processos = Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, Id, CPU | Format-Table | Out-String
    [System.Windows.MessageBox]::Show($processos,"Top Processos por CPU")
})
$window.FindName("btnHardware").Add_Click({
    $sys = Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer, Model, @{Name="RAM(GB)";Expression={[math]::Round($_.TotalPhysicalMemory/1GB,2)}}
    $cpu = Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, MaxClockSpeed
    $disco = Get-CimInstance Win32_DiskDrive | Select-Object Model, @{Name="Tamanho(GB)";Expression={[math]::Round($_.Size/1GB,2)}}

    $msg = "Sistema:`n" + ($sys | Format-List | Out-String)
    $msg += "`nProcessador:`n" + ($cpu | Format-List | Out-String)
    $msg += "`nDiscos:`n" + ($disco | Format-Table | Out-String)

    [System.Windows.MessageBox]::Show($msg,"Relatório de Hardware")
})

# Exibir janela
$window.ShowDialog() | Out-Null
