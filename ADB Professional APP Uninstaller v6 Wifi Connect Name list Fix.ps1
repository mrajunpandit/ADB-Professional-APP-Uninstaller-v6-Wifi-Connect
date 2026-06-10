# Ensure Windows PowerShell 5.1
if ($PSVersionTable.PSEdition -ne "Desktop") {
    Write-Host -ForegroundColor Red "This script requires Windows PowerShell 5.1. Current edition: $($PSVersionTable.PSEdition)"
    exit
}

Add-Type -AssemblyName PresentationFramework

# XAML GUI
$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        x:Name="MainWindow" Title="ADB App Manager" Height="760" Width="900" MinWidth="760" MinHeight="560"
        Background="#2D3748" Foreground="#E2E8F0" WindowStartupLocation="CenterScreen">
    <Window.Resources>
        <Style x:Key="BtnBase" TargetType="Button">
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
        </Style>
        <Style x:Key="BtnPrimary" TargetType="Button" BasedOn="{StaticResource BtnBase}">
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="Background" Value="#2563EB"/>
            <Setter Property="BorderBrush" Value="#1D4ED8"/>
            <Setter Property="Padding" Value="18,10"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="bd" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="8" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="bd" Property="Background" Value="#1D4ED8"/>
                                <Setter TargetName="bd" Property="BorderBrush" Value="#1E40AF"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="bd" Property="Background" Value="#1E40AF"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="bd" Property="Opacity" Value="0.55"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <Style x:Key="BtnDanger" TargetType="Button" BasedOn="{StaticResource BtnBase}">
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="Background" Value="#DC2626"/>
            <Setter Property="BorderBrush" Value="#B91C1C"/>
            <Setter Property="Padding" Value="18,10"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="bd" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="8" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="bd" Property="Background" Value="#B91C1C"/>
                                <Setter TargetName="bd" Property="BorderBrush" Value="#991B1B"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="bd" Property="Background" Value="#991B1B"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="bd" Property="Opacity" Value="0.55"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <Style x:Key="BtnSecondary" TargetType="Button" BasedOn="{StaticResource BtnBase}">
            <Setter Property="Padding" Value="14,8"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="bd" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="8" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="bd" Property="Opacity" Value="0.88"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="bd" Property="Opacity" Value="0.55"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <Style x:Key="BtnOutline" TargetType="Button" BasedOn="{StaticResource BtnBase}">
            <Setter Property="Padding" Value="12,6"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="bd" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="8" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="bd" Property="Opacity" Value="0.9"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>
    <Grid Margin="10">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Wi-Fi Connect Strip (Row 0) - Step 1: Pair  |  Step 2: Connect -->
        <Border Grid.Row="0" x:Name="WifiBorder" CornerRadius="8" Padding="10,8" Margin="0,0,0,8"
                Background="#1A202C" BorderThickness="1" BorderBrush="#4A5568">
            <StackPanel>
                <!-- Step 1: Pair (Android 11+) -->
                <Grid Margin="0,0,0,6">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="Auto"/>
                        <ColumnDefinition Width="Auto"/>
                        <ColumnDefinition Width="140"/>
                        <ColumnDefinition Width="Auto"/>
                        <ColumnDefinition Width="72"/>
                        <ColumnDefinition Width="Auto"/>
                        <ColumnDefinition Width="72"/>
                        <ColumnDefinition Width="Auto"/>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    <TextBlock Grid.Column="0" Text="Step 1 - Pair (Android 11+):" FontWeight="SemiBold" FontSize="12"
                               Foreground="#63B3ED" VerticalAlignment="Center" Margin="0,0,12,0"/>
                    <TextBlock Grid.Column="1" Text="IP:" Foreground="#A0AEC0" VerticalAlignment="Center" Margin="0,0,4,0" FontSize="12"/>
                    <TextBox x:Name="WifiIpBox" Grid.Column="2" Height="26" VerticalContentAlignment="Center"
                             Background="#2D3748" Foreground="#E2E8F0" BorderBrush="#4A5568"
                             Text="192.168.1." FontSize="12" Padding="4,0"/>
                    <TextBlock Grid.Column="3" Text="Pair Port:" Foreground="#A0AEC0" VerticalAlignment="Center" Margin="8,0,4,0" FontSize="12"/>
                    <TextBox x:Name="WifiPairPortBox" Grid.Column="4" Height="26" VerticalContentAlignment="Center"
                             Background="#2D3748" Foreground="#E2E8F0" BorderBrush="#4A5568"
                             Text="" FontSize="12" Padding="4,0" ToolTip="Pairing port shown in Developer Options > Wireless Debugging > Pair with code"/>
                    <TextBlock Grid.Column="5" Text="Code:" Foreground="#A0AEC0" VerticalAlignment="Center" Margin="8,0,4,0" FontSize="12"/>
                    <TextBox x:Name="WifiPairCodeBox" Grid.Column="6" Height="26" VerticalContentAlignment="Center"
                             Background="#2D3748" Foreground="#E2E8F0" BorderBrush="#4A5568"
                             Text="" FontSize="12" Padding="4,0" MaxLength="6" ToolTip="6-digit pairing code shown on the device"/>
                    <Button x:Name="WifiPairBtn" Grid.Column="7" Style="{StaticResource BtnPrimary}"
                            Content="Pair" Height="28" Padding="12,4" Margin="8,0,0,0"
                            ToolTip="Pair the device wirelessly (Android 11+). USB not required after first pair."/>
                    <TextBlock x:Name="WifiStatusLabel" Grid.Column="9" VerticalAlignment="Center"
                               FontSize="12" FontWeight="SemiBold" Margin="8,0,0,0"
                               Text="[USB]" Foreground="#68D391"/>
                    <Button x:Name="ThemeToggleBtn" Grid.Column="10" Style="{StaticResource BtnOutline}" Content="Light mode"
                            Width="100" Height="28" Margin="10,0,0,0"/>
                </Grid>
                <!-- Divider -->
                <Rectangle Height="1" Fill="#4A5568" Margin="0,0,0,6"/>
                <!-- Step 2: Connect -->
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="Auto"/>
                        <ColumnDefinition Width="Auto"/>
                        <ColumnDefinition Width="72"/>
                        <ColumnDefinition Width="Auto"/>
                        <ColumnDefinition Width="Auto"/>
                        <ColumnDefinition Width="Auto"/>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>
                    <TextBlock Grid.Column="0" Text="Step 2 - Connect:" FontWeight="SemiBold" FontSize="12"
                               Foreground="#68D391" VerticalAlignment="Center" Margin="0,0,12,0"/>
                    <TextBlock Grid.Column="1" Text="Port:" Foreground="#A0AEC0" VerticalAlignment="Center" Margin="0,0,4,0" FontSize="12"/>
                    <TextBox x:Name="WifiPortBox" Grid.Column="2" Height="26" VerticalContentAlignment="Center"
                             Background="#2D3748" Foreground="#E2E8F0" BorderBrush="#4A5568"
                             Text="5555" FontSize="12" Padding="4,0" ToolTip="Connect port shown in Developer Options > Wireless Debugging (main screen)"/>
                    <Button x:Name="WifiConnectBtn" Grid.Column="3" Style="{StaticResource BtnPrimary}"
                            Content="Connect" Height="28" Padding="12,4" Margin="8,0,0,0"
                            ToolTip="Connect to the device over Wi-Fi using the IP and Port above."/>
                    <Button x:Name="WifiDisconnectBtn" Grid.Column="4" Style="{StaticResource BtnSecondary}"
                            Content="Disconnect" Height="28" Padding="10,4" Margin="6,0,0,0"/>
                    <Button x:Name="WifiRefreshBtn" Grid.Column="5" Style="{StaticResource BtnOutline}"
                            Content="Refresh" Height="28" Padding="10,4" Margin="6,0,0,0"/>
                </Grid>
            </StackPanel>
        </Border>
        <Grid Grid.Row="1" Margin="0,0,0,10">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>
            <TextBlock x:Name="SearchBoxLabel" Grid.Column="0" Text="Search Box" VerticalAlignment="Center"
                       Margin="0,0,10,0" Foreground="#E2E8F0"/>
            <TextBox x:Name="SearchBox" Grid.Column="1" Height="30" VerticalContentAlignment="Center"
                     Background="#4A5568" Foreground="#E2E8F0" BorderBrush="#718096"
                     ToolTip="Search user and system apps by name or package"/>
        </Grid>
        <StackPanel Grid.Row="2" Orientation="Horizontal" Margin="0,0,0,10" HorizontalAlignment="Center">
            <RadioButton x:Name="UserRadio" Content="User Apps" Margin="10,0" IsChecked="True" Foreground="#E2E8F0"/>
            <RadioButton x:Name="SystemRadio" Content="System Apps" Margin="10,0" Foreground="#E2E8F0"/>
            <RadioButton x:Name="AllRadio" Content="All Apps" Margin="10,0" Foreground="#E2E8F0"/>
            <Button x:Name="SelectAllBtn" Style="{StaticResource BtnSecondary}" Content="Select All"
                    Margin="10,0" Width="110" Height="34"/>
        </StackPanel>
        <Grid Grid.Row="3">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="240"/>
            </Grid.ColumnDefinitions>
            <ScrollViewer x:Name="AppScrollViewer" Grid.Column="0" VerticalScrollBarVisibility="Auto"
                          Background="#1A202C" Margin="0,0,8,0">
                <StackPanel x:Name="AppListPanel" />
            </ScrollViewer>
            <Border x:Name="SelectionPanelBorder" Grid.Column="1" BorderThickness="1" CornerRadius="4" Padding="8">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>
                    <TextBlock x:Name="SelectedSummaryText" Grid.Row="0" FontWeight="Bold" Margin="0,0,0,8"
                               Text="Selected: 0"/>
                    <TextBlock x:Name="SelectedUserHeader" Grid.Row="1" Text="User Apps (0)" FontWeight="SemiBold" Margin="0,0,0,4"/>
                    <ScrollViewer Grid.Row="2" VerticalScrollBarVisibility="Auto" Margin="0,0,0,8">
                        <StackPanel x:Name="SelectedUserPanel"/>
                    </ScrollViewer>
                    <TextBlock x:Name="SelectedSystemHeader" Grid.Row="3" Text="System Apps (0)" FontWeight="SemiBold" Margin="0,0,0,4"/>
                    <ScrollViewer Grid.Row="4" VerticalScrollBarVisibility="Auto">
                        <StackPanel x:Name="SelectedSystemPanel"/>
                    </ScrollViewer>
                </Grid>
            </Border>
        </Grid>
        <StackPanel Grid.Row="4" Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,12,0,0">
            <Button x:Name="DisableBtn" Style="{StaticResource BtnPrimary}" MinWidth="210" Height="42"
                    Margin="6,0" Content="Disable Selected Apps"/>
            <Button x:Name="UninstallBtn" Style="{StaticResource BtnDanger}" MinWidth="210" Height="42"
                    Margin="6,0" Content="Uninstall Selected Apps"/>
        </StackPanel>
    </Grid>
</Window>
"@

# Load XAML
try {
    [xml]$xamlXml = $xaml
    $reader = New-Object System.Xml.XmlNodeReader $xamlXml
    $window = [Windows.Markup.XamlReader]::Load($reader)
    Write-Host -ForegroundColor Green "GUI loaded successfully."
} catch {
    Write-Host -ForegroundColor Red "Failed to load XAML: $($_.Exception.Message)"
    [System.Windows.MessageBox]::Show("Failed to load GUI: $($_.Exception.Message)", "XAML Error")
    exit
}

# Get UI elements
$searchBox = $window.FindName("SearchBox")
$appListPanel = $window.FindName("AppListPanel")
$appScrollViewer = $window.FindName("AppScrollViewer")
$disableBtn = $window.FindName("DisableBtn")
$uninstallBtn = $window.FindName("UninstallBtn")
$userRadio = $window.FindName("UserRadio")
$systemRadio = $window.FindName("SystemRadio")
$allRadio = $window.FindName("AllRadio")
$searchBoxLabel = $window.FindName("SearchBoxLabel")
$selectAllBtn = $window.FindName("SelectAllBtn")
$themeToggleBtn = $window.FindName("ThemeToggleBtn")
$selectionPanelBorder = $window.FindName("SelectionPanelBorder")
$selectedSummaryText = $window.FindName("SelectedSummaryText")
$selectedUserHeader = $window.FindName("SelectedUserHeader")
$selectedSystemHeader = $window.FindName("SelectedSystemHeader")
$selectedUserPanel = $window.FindName("SelectedUserPanel")
$selectedSystemPanel = $window.FindName("SelectedSystemPanel")
# Wi-Fi controls
$wifiBorder        = $window.FindName("WifiBorder")
$wifiIpBox         = $window.FindName("WifiIpBox")
$wifiPortBox       = $window.FindName("WifiPortBox")
$wifiPairPortBox   = $window.FindName("WifiPairPortBox")
$wifiPairCodeBox   = $window.FindName("WifiPairCodeBox")
$wifiPairBtn       = $window.FindName("WifiPairBtn")
$wifiConnectBtn    = $window.FindName("WifiConnectBtn")
$wifiDisconnectBtn = $window.FindName("WifiDisconnectBtn")
$wifiRefreshBtn    = $window.FindName("WifiRefreshBtn")
$wifiStatusLabel   = $window.FindName("WifiStatusLabel")

# Theme helpers
$themeConfigPath = Join-Path $env:APPDATA "ADBAppManager\theme.txt"
$brushConverter = [System.Windows.Media.BrushConverter]::new()

function ConvertTo-Brush([string]$Color) {
    return $brushConverter.ConvertFromString($Color)
}

function Set-ThemedSecondaryButton($Button, $Bg, $HoverBg, $Border, $Fg) {
    $normalBrush = ConvertTo-Brush $Bg
    $hoverBrush = ConvertTo-Brush $HoverBg
    $Button.Background = $normalBrush
    $Button.BorderBrush = ConvertTo-Brush $Border
    $Button.Foreground = ConvertTo-Brush $Fg
    if (-not $Button.Tag -or $Button.Tag -isnot [hashtable] -or -not $Button.Tag._UiHooked) {
        $meta = @{ _UiHooked = $true; _NormalBg = $null; _HoverBg = $null }
        $Button.Tag = $meta
        $Button.Add_MouseEnter({
            param($sender, $e)
            if ($null -ne $sender.Tag._HoverBg) { $sender.Background = $sender.Tag._HoverBg }
        })
        $Button.Add_MouseLeave({
            param($sender, $e)
            if ($null -ne $sender.Tag._NormalBg) { $sender.Background = $sender.Tag._NormalBg }
        })
    }
    $Button.Tag._NormalBg = $normalBrush
    $Button.Tag._HoverBg = $hoverBrush
}

$Themes = @{
    Dark = @{
        WindowBg = "#2D3748"; Foreground = "#E2E8F0"
        InputBg = "#4A5568"; InputBorder = "#718096"
        ListBg = "#1A202C"; SidePanelBg = "#1A202C"; SidePanelBorder = "#4A5568"
        MutedText = "#A0AEC0"
        SecondaryBtn = "#475569"; SecondaryBtnHover = "#334155"; SecondaryBtnBorder = "#64748B"; SecondaryBtnFg = "#F8FAFC"
        OutlineBtn = "#374151"; OutlineBtnHover = "#4B5563"; OutlineBtnBorder = "#6B7280"; OutlineBtnFg = "#F1F5F9"
        ToggleLabel = "Light mode"
    }
    Light = @{
        WindowBg = "#F7FAFC"; Foreground = "#1A202C"
        InputBg = "#FFFFFF"; InputBorder = "#CBD5E0"
        ListBg = "#EDF2F7"; SidePanelBg = "#EDF2F7"; SidePanelBorder = "#CBD5E0"
        MutedText = "#718096"
        SecondaryBtn = "#E2E8F0"; SecondaryBtnHover = "#CBD5E1"; SecondaryBtnBorder = "#94A3B8"; SecondaryBtnFg = "#1E293B"
        OutlineBtn = "#FFFFFF"; OutlineBtnHover = "#F1F5F9"; OutlineBtnBorder = "#CBD5E0"; OutlineBtnFg = "#334155"
        ToggleLabel = "Dark mode"
    }
}

$script:CurrentTheme = "Dark"

function Get-SavedTheme {
    if (Test-Path $themeConfigPath) {
        $saved = (Get-Content $themeConfigPath -Raw).Trim()
        if ($saved -eq "Light" -or $saved -eq "Dark") { return $saved }
    }
    return "Dark"
}

function Save-Theme([string]$Name) {
    $dir = Split-Path $themeConfigPath -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Set-Content -Path $themeConfigPath -Value $Name -Encoding UTF8
}

function Set-Theme([string]$Name) {
    if (-not $Themes.ContainsKey($Name)) { $Name = "Dark" }
    $script:CurrentTheme = $Name
    $t = $Themes[$Name]
    $fg = ConvertTo-Brush $t.Foreground

    $window.Background = ConvertTo-Brush $t.WindowBg
    $window.Foreground = $fg

    $searchBox.Background = ConvertTo-Brush $t.InputBg
    $searchBox.Foreground = $fg
    $searchBox.BorderBrush = ConvertTo-Brush $t.InputBorder
    $searchBox.CaretBrush = $fg
    $searchBoxLabel.Foreground = $fg

    $appScrollViewer.Background = ConvertTo-Brush $t.ListBg

    foreach ($rb in @($userRadio, $systemRadio, $allRadio)) { $rb.Foreground = $fg }

    Set-ThemedSecondaryButton $selectAllBtn $t.SecondaryBtn $t.SecondaryBtnHover $t.SecondaryBtnBorder $t.SecondaryBtnFg
    Set-ThemedSecondaryButton $themeToggleBtn $t.OutlineBtn $t.OutlineBtnHover $t.OutlineBtnBorder $t.OutlineBtnFg
    $themeToggleBtn.Content = $t.ToggleLabel

    foreach ($cb in $checkboxes) { $cb.Foreground = $fg }

    $selectionPanelBorder.Background = ConvertTo-Brush $t.SidePanelBg
    $selectionPanelBorder.BorderBrush = ConvertTo-Brush $t.SidePanelBorder
    foreach ($el in @($selectedSummaryText, $selectedUserHeader, $selectedSystemHeader)) {
        $el.Foreground = $fg
    }
    # Wi-Fi strip theming
    $wifiBorder.Background   = ConvertTo-Brush $t.ListBg
    $wifiBorder.BorderBrush  = ConvertTo-Brush $t.InputBorder
    foreach ($tb in @($wifiIpBox, $wifiPortBox, $wifiPairPortBox, $wifiPairCodeBox)) {
        $tb.Background  = ConvertTo-Brush $t.InputBg
        $tb.Foreground  = $fg
        $tb.BorderBrush = ConvertTo-Brush $t.InputBorder
    }
    Set-ThemedSecondaryButton $wifiDisconnectBtn $t.SecondaryBtn $t.SecondaryBtnHover $t.SecondaryBtnBorder $t.SecondaryBtnFg
    Set-ThemedSecondaryButton $wifiRefreshBtn    $t.OutlineBtn   $t.OutlineBtnHover   $t.OutlineBtnBorder   $t.OutlineBtnFg
    Update-SelectionPanel

    Save-Theme $Name
}

# ADB setup
$adbPath = $null
if ($env:ADB_PATH -and (Test-Path $env:ADB_PATH)) { $adbPath = $env:ADB_PATH }
elseif (Get-Command adb -ErrorAction SilentlyContinue) { $adbPath = (Get-Command adb).Source }
elseif (Test-Path "C:\platform-tools\adb.exe") { $adbPath = "C:\platform-tools\adb.exe" }
else { $adbPath = "C:\platform-tools\adb.exe" }
if (-not (Test-Path $adbPath)) {
    Write-Host -ForegroundColor Red "ADB not found at $adbPath"
    [System.Windows.MessageBox]::Show("ADB not found at $adbPath. Install ADB from https://developer.android.com/studio/releases/platform-tools.", "ADB Error")
    exit
}
Write-Host -ForegroundColor Green "ADB found at $adbPath"

# Start ADB server and check device
function Test-AdbDevice {
    return [bool](& $adbPath devices 2>&1 | Select-String -Pattern "\tdevice$")
}

try {
    & $adbPath start-server 2>&1 | Out-Null
    if (-not (Test-AdbDevice)) {
        & $adbPath kill-server 2>&1 | Out-Null
        & $adbPath start-server 2>&1 | Out-Null
    }
    $adbVersion = & $adbPath version 2>&1
    Write-Host -ForegroundColor Green "ADB version: $adbVersion"
    if (-not (Test-AdbDevice)) {
        Write-Host -ForegroundColor Red "No device connected."
        [System.Windows.MessageBox]::Show("No device connected via USB.`n`nYou can still connect via Wi-Fi using the panel at the top of the app.", "No USB Device")
        # Do NOT exit - allow Wi-Fi connection
    } else {
        $deviceCheck = & $adbPath devices 2>&1 | Select-String -Pattern "\tdevice$"
        Write-Host -ForegroundColor Green "Device connected: $deviceCheck"
        $androidVersion = & $adbPath shell getprop ro.build.version.release
        Write-Host -ForegroundColor Green "Device Android version: $androidVersion"
    }
} catch {
    Write-Host -ForegroundColor Red "ADB setup error: $($_.Exception.Message)"
    [System.Windows.MessageBox]::Show("ADB setup failed: $($_.Exception.Message)", "ADB Error")
    exit
}

# App names
$appNames = @{
"com.miui.screenrecorder" = "MIUI Screen Recorder"
"com.android.cts.priv.ctsshim" = "CTS Shim Priv"
"com.android.internal.display.cutout.emulation.corner" = "Corner Cutout Emulation"
"com.google.android.ext.services" = "Google Ext Services"
"com.android.internal.display.cutout.emulation.double" = "Double Cutout Emulation"
"com.android.providers.telephony" = "Telephony Provider"
"com.android.dynsystem" = "Dynamic System Updates"
"com.miui.powerkeeper" = "MIUI Power Keeper"
"com.goodix.fingerprint" = "Goodix Fingerprint"
"com.truecaller" = "Truecaller"
"com.google.android.googlequicksearchbox" = "Google Search"
"com.miui.fm" = "MIUI FM Radio"
"com.android.providers.calendar" = "Calendar Provider"
"org.telegram.messenger" = "Telegram"
"com.android.providers.media" = "Media Provider"
"com.milink.service" = "Mi Link Service"
"com.touchtype.swiftkey" = "SwiftKey"
"com.phonepe.app" = "PhonePe"
"com.qti.service.colorservice" = "Qualcomm Color Service"
"com.android.theme.icon.square" = "Square Icon Theme"
"com.google.android.onetimeinitializer" = "Google One Time Init"
"com.google.android.ext.shared" = "Google Ext Shared"
"com.android.internal.systemui.navbar.gestural_wide_back" = "Gestural Wide Back Navigation"
"com.xiaomi.powerchecker" = "Xiaomi Power Checker"
"com.xiaomi.account" = "Xiaomi Account"
"com.niksoftware.snapseed" = "Snapseed"
"com.android.wallpapercropper" = "Wallpaper Cropper"
"com.android.theme.color.cinnamon" = "Cinnamon Color Theme"
"miui.systemui.plugin" = "MIUI System UI Plugin"
"com.xiaomi.mi_connect_service" = "Mi Connect Service"
"com.xiaomi.micloud.sdk" = "Mi Cloud SDK"
"com.android.theme.icon_pack.rounded.systemui" = "Rounded System UI Icon Pack"
"com.myairtelapp" = "Airtel Thanks"
"com.android.updater" = "System Updater"
"com.android.externalstorage" = "External Storage"
"com.qualcomm.uimremoteclient" = "Qualcomm UIM Remote Client"
"com.android.htmlviewer" = "HTML Viewer"
"com.miui.securityadd" = "MIUI Security Add"
"com.whatsapp" = "WhatsApp"
"com.qualcomm.qti.uceShimService" = "Qualcomm UCE Shim Service"
"com.android.companiondevicemanager" = "Companion Device Manager"
"com.miui.gallery" = "MIUI Gallery"
"com.idfcfirstbank.optimus" = "IDFC FIRST Bank"
"com.android.mms.service" = "MMS Service"
"com.tradingview.tradingviewapp" = "TradingView"
"com.miui.msa.global" = "MIUI MSA Global"
"com.android.providers.downloads" = "Downloads Provider"
"com.longcheertel.midtest" = "Longcheer MID Test"
"com.android.networkstack.inprocess" = "Network Stack"
"com.miui.securitycenter" = "MIUI Security Center"
"com.android.theme.icon_pack.rounded.android" = "Rounded Android Icon Pack"
"vendor.qti.hardware.cacert.server" = "Qualcomm CA Cert Server"
"com.openai.chatgpt" = "ChatGPT"
"com.qualcomm.qti.telephonyservice" = "Qualcomm Telephony Service"
"com.android.theme.icon_pack.circular.themepicker" = "Circular Theme Picker Icon Pack"
"com.google.android.overlay.gmsgsaconfig" = "Google GMSA Config Overlay"
"vendor.qti.iwlan" = "Qualcomm iWLAN"
"com.google.android.configupdater" = "Google Config Updater"
"com.microsoft.office.excel" = "Microsoft Excel"
"com.android.systemui.icon.overlay" = "System UI Icon Overlay"
"com.qualcomm.qti.optinoverlay" = "Qualcomm Opt-in Overlay"
"com.google.android.overlay.modules.permissioncontroller" = "Google Permission Controller Overlay"
"com.android.soundrecorder" = "Sound Recorder"
"com.qualcomm.uimremoteserver" = "Qualcomm UIM Remote Server"
"com.qti.confuridialer" = "Qualcomm Confuri Dialer"
"com.miui.guardprovider" = "MIUI Guard Provider"
"com.longcheertel.modemlog" = "Longcheer Modem Log"
"com.google.ar.core" = "Google AR Core"
"com.google.ar.lens" = "Google Lens"
"com.android.providers.downloads.ui" = "Downloads UI"
"com.android.vending" = "Google Play Store"
"com.android.pacprocessor" = "PAC Processor"
"com.android.simappdialog" = "SIM App Dialog"
"com.miui.backup" = "MIUI Backup"
"com.android.settings.overlay.miui" = "MIUI Settings Overlay"
"com.miui.notification" = "MIUI Notification"
"com.miui.micloudsync" = "Mi Cloud Sync"
"com.android.internal.display.cutout.emulation.tall" = "Tall Cutout Emulation"
"com.miui.daemon" = "MIUI Daemon"
"com.android.certinstaller" = "Certificate Installer"
"com.android.theme.color.black" = "Black Color Theme"
"com.android.carrierconfig" = "Carrier Config"
"com.google.android.marvin.talkback" = "TalkBack"
"com.android.theme.color.green" = "Green Color Theme"
"com.android.theme.color.ocean" = "Ocean Color Theme"
"com.android.theme.color.space" = "Space Color Theme"
"com.wapi.wapicertmanage" = "WAPI Cert Manage"
"com.android.internal.systemui.navbar.threebutton" = "Three Button Navigation"
"com.qti.qualcomm.datastatusnotification" = "Qualcomm Data Status Notification"
"android" = "Android System"
"in.upstox.app" = "Upstox"
"com.android.systemui.notch.overlay" = "Notch Overlay"
"com.android.contacts" = "Contacts"
"com.qualcomm.qti.callfeaturessetting" = "Qualcomm Call Features Setting"
"com.qualcomm.wfd.service" = "Qualcomm Wi-Fi Display Service"
"android.miui.overlay" = "MIUI Android Overlay"
"com.miui.vsimcore" = "MIUI VSim Core"
"com.miui.securitycore" = "MIUI Security Core"
"com.android.theme.icon_pack.rounded.launcher" = "Rounded Launcher Icon Pack"
"com.qti.qualcomm.deviceinfo" = "Qualcomm Device Info"
"com.snapwork.hdfc" = "HDFC Bank"
"com.android.egg" = "Android Easter Egg"
"com.android.mms" = "Messaging"
"com.android.mtp" = "MTP Host"
"com.android.ons" = "Opportunistic Network Service"
"com.android.stk" = "SIM Toolkit"
"com.android.backupconfirm" = "Backup Confirm"
"se.dirac.acs" = "Dirac Audio Control Service"
"com.xiaomi.simactivate.service" = "Xiaomi SIM Activate Service"
"com.instagram.android" = "Instagram"
"com.goodix.gftest" = "Goodix Fingerprint Test"
"com.miui.phrase" = "MIUI Phrase"
"com.microsoft.office.onenote" = "Microsoft OneNote"
"com.pinterest" = "Pinterest"
"com.android.internal.systemui.navbar.twobutton" = "Two Button Navigation"
"com.android.provision" = "Device Provision"
"org.codeaurora.ims" = "Qualcomm IMS"
"com.android.statementservice" = "Statement Service"
"com.msf.angelmobile" = "Angel Mobile"
"com.android.hotspot2" = "Hotspot 2.0"
"com.google.android.gm" = "Gmail"
"android.overlay.target" = "Android Overlay Target"
"com.miui.system" = "MIUI System"
"com.ixigo.train.ixitrain" = "ixigo Trains"
"com.miui.cleaner" = "MIUI Cleaner"
"com.android.settings.intelligence" = "Settings Intelligence"
"com.android.calendar" = "Calendar"
"com.miui.global.packageinstaller" = "MIUI Package Installer"
"com.android.internal.systemui.navbar.gestural_extra_wide_back" = "Gestural Extra Wide Back Navigation"
"com.google.android.permissioncontroller" = "Google Permission Controller"
"com.miui.systemui.devices.overlay" = "MIUI System UI Devices Overlay"
"com.miui.compass" = "MIUI Compass"
"org.chromium.webapk.aeef5545352a39978_v2" = "WebAPK aeef5545352a39978"
"com.google.android.setupwizard" = "Google Setup Wizard"
"com.miui.rom" = "MIUI ROM"
"com.qualcomm.qcrilmsgtunnel" = "Qualcomm QCRIL Message Tunnel"
"com.android.providers.settings" = "Settings Provider"
"com.android.sharedstoragebackup" = "Shared Storage Backup"
"com.xiaomi.location.fused" = "Xiaomi Fused Location"
"com.android.printspooler" = "Print Spooler"
"com.miui.misound" = "MIUI MiSound"
"com.android.theme.icon_pack.filled.settings" = "Filled Settings Icon Pack"
"com.android.dreams.basic" = "Basic Dreams"
"com.google.android.overlay.modules.ext.services" = "Google Ext Services Overlay"
"com.android.incallui" = "InCall UI"
"com.android.systemui.gesture.line.overlay" = "System UI Gesture Line Overlay"
"com.fido.xiaomi.uafclient" = "FIDO Xiaomi UAF Client"
"com.duokan.phone.remotecontroller" = "Duokan Remote Controller"
"com.android.se" = "Secure Element"
"com.android.inputdevices" = "Input Devices"
"com.qualcomm.qti.biometrics.fingerprint.service" = "Qualcomm Biometrics Fingerprint Service"
"com.google.android.apps.wellbeing" = "Digital Wellbeing"
"com.fido.asm" = "FIDO ASM"
"com.miui.documentsuioverlay" = "MIUI Documents UI Overlay"
"com.android.bips" = "Built-in Print Service"
"com.qti.dpmserviceapp" = "Qualcomm DPM Service"
"com.android.theme.icon_pack.circular.settings" = "Circular Settings Icon Pack"
"com.fingerprints.extension.service" = "Fingerprints Extension Service"
"com.android.fileexplorer" = "File Explorer"
"com.qti.xdivert" = "Qualcomm XDivert"
"com.exness.android.go" = "Exness Go"
"com.xiaomi.mircs" = "Xiaomi MiRCS"
"com.android.systemui.overlay.miui" = "MIUI System UI Overlay"
"com.google.android.overlay.gmsconfig" = "Google GMS Config Overlay"
"com.google.android.apps.bard" = "Google Bard"
"com.google.android.apps.maps" = "Google Maps"
"com.google.android.modulemetadata" = "Google Module Metadata"
"com.dreamplug.androidapp" = "CRED"
"com.miui.cloudbackup" = "MIUI Cloud Backup"
"com.microsoft.office.word" = "Microsoft Word"
"net.one97.paytm" = "Paytm"
"com.mobile.cbiepassbook" = "CBI e-Passbook"
"com.android.cellbroadcastreceiver" = "Cell Broadcast Receiver"
"com.google.android.webview" = "Android WebView"
"com.android.theme.icon.teardrop" = "Teardrop Icon Theme"
"com.opera.browser" = "Opera Browser"
"com.google.android.contactkeys" = "Google Contact Keys"
"com.android.server.telecom" = "Telecom Server"
"com.google.android.syncadapters.contacts" = "Google Contacts Sync"
"com.android.keychain" = "Keychain"
"com.android.camera" = "Camera"
"com.android.chrome" = "Google Chrome"
"com.xiaomi.xmsf" = "Xiaomi Service Framework"
"com.android.theme.icon_pack.filled.systemui" = "Filled System UI Icon Pack"
"com.google.android.packageinstaller" = "Google Package Installer"
"com.miui.mishare.connectivity" = "MIUI MiShare Connectivity"
"com.google.android.gms" = "Google Play Services"
"com.google.android.gsf" = "Google Services Framework"
"com.qualcomm.qti.qtisystemservice" = "Qualcomm QTI System Service"
"com.android.calllogbackup" = "Call Log Backup"
"com.google.android.partnersetup" = "Google Partner Setup"
"android.aosp.overlay" = "AOSP Overlay"
"com.aimp.player" = "AIMP"
"com.xiaomi.xmsfkeeper" = "Xiaomi XMSF Keeper"
"com.android.localtransport" = "Local Transport"
"org.chromium.webapk.a9f09f6c8ec6ea0a3_v2" = "WebAPK a9f09f6c8ec6ea0a3"
"com.android.carrierdefaultapp" = "Carrier Default App"
"com.dsi.ant.server" = "ANT Server"
"ai.x.grok" = "Grok"
"com.qualcomm.qti.remoteSimlockAuth" = "Qualcomm Remote SIM Lock Auth"
"com.xiaomi.finddevice" = "Xiaomi Find Device"
"com.android.theme.font.notoserifsource" = "Noto Serif Source Font"
"com.android.theme.icon_pack.filled.android" = "Filled Android Icon Pack"
"com.android.proxyhandler" = "Proxy Handler"
"com.qualcomm.qti.workloadclassifier" = "Qualcomm Workload Classifier"
"com.mobikwik_new" = "MobiKwik"
"com.android.theme.icon_pack.circular.systemui" = "Circular System UI Icon Pack"
"com.mi.android.globalFileexplorer" = "MIUI Global File Explorer"
"org.chromium.webapk.a274aec14566922b0_v2" = "WebAPK a274aec14566922b0"
"org.videolan.vlc" = "VLC Media Player"
"com.miui.wmsvc" = "MIUI WM Service"
"com.google.android.overlay.modules.permissioncontroller.forframework" = "Google Permission Controller Framework Overlay"
"com.xiaomi.misettings" = "MIUI Settings"
"com.google.android.printservice.recommendation" = "Google Print Service Recommendation"
"com.google.android.syncadapters.calendar" = "Google Calendar Sync"
"com.miui.cloudservice" = "MIUI Cloud Service"
"com.android.managedprovisioning" = "Managed Provisioning"
"com.miui.hybrid.accessory" = "MIUI Hybrid Accessory"
"com.fingerprints.sensortesttool" = "Fingerprint Sensor Test Tool"
"com.kotak811mobilebankingapp.instantsavingsupiscanandpayrecharge" = "Kotak 811 Mobile Banking"
"com.tencent.soter.soterserver" = "Tencent Soter Server"
"com.google.android.documentsui" = "Documents UI"
"com.android.dreams.phototable" = "Photo Table Dreams"
"com.miui.audiomonitor" = "MIUI Audio Monitor"
"com.miui.touchassistant" = "MIUI Touch Assistant"
"com.android.providers.partnerbookmarks" = "Partner Bookmarks Provider"
"com.android.smspush" = "SMS Push"
"com.miui.calculator" = "MIUI Calculator"
"com.android.wallpaper.livepicker" = "Live Wallpaper Picker"
"com.miui.cloudservice.sysbase" = "MIUI Cloud Service Sysbase"
"com.android.systemui.navigation.bar.overlay" = "System UI Navigation Bar Overlay"
"com.microsoft.copilot" = "Microsoft Copilot"
"com.xiaomi.bluetooth" = "Xiaomi Bluetooth"
"com.android.theme.icon.squircle" = "Squircle Icon Theme"
"com.longcheertel.AutoTest" = "Longcheer Auto Test"
"com.android.storagemanager" = "Storage Manager"
"com.wdstechnology.android.kryten" = "WDS Kryten"
"com.miui.analytics" = "MIUI Analytics"
"com.android.bookmarkprovider" = "Bookmark Provider"
"com.android.settings" = "Settings"
"com.qualcomm.qti.cne" = "Qualcomm CNE"
"com.qualcomm.qti.ims" = "Qualcomm IMS Service"
"com.qualcomm.qti.smq" = "Qualcomm SMQ"
"com.gallery.player" = "Gallery Player"
"com.miui.weather2" = "MIUI Weather"
"com.google.android.apps.nbu.paisa.user" = "Google Pay"
"com.android.theme.icon_pack.filled.launcher" = "Filled Launcher Icon Pack"
"com.android.networkstack.permissionconfig" = "Network Stack Permission Config"
"com.google.android.projection.gearhead" = "Android Auto"
"com.qualcomm.location" = "Qualcomm Location"
"com.xiaomi.scanner" = "MIUI Scanner"
"com.binance.dev" = "Binance"
"com.google.android.apps.turbo" = "Device Health Services"
"com.xiaomi.calendar" = "Xiaomi Calendar"
"com.android.cts.ctsshim" = "CTS Shim"
"com.miui.yellowpage" = "MIUI Yellow Page"
"com.duokan.phone.remotecontroller.peel.plugin" = "Peel Remote Controller Plugin"
"com.android.theme.icon_pack.circular.launcher" = "Circular Launcher Icon Pack"
"com.caf.fmradio" = "CAF FM Radio"
"com.miui.systemui.carriers.overlay" = "MIUI System UI Carriers Overlay"
"com.miui.systemui.overlay.devices.android" = "MIUI System UI Devices Overlay"
"com.qualcomm.qti.services.secureui" = "Qualcomm Secure UI Services"
"com.xiaomi.bluetooth.overlay" = "Xiaomi Bluetooth Overlay"
"org.chromium.webapk.ab49e9545d9586855_v2" = "WebAPK ab49e9545d9586855"
"com.android.vpndialogs" = "VPN Dialogs"
"com.longcheertel.cit" = "Longcheer CIT"
"com.sensibull.mobile" = "Sensibull"
"com.mi.global.shop" = "Mi Global Shop"
"com.android.phone" = "Phone"
"com.android.shell" = "Shell"
"com.android.theme.icon_pack.filled.themepicker" = "Filled Theme Picker Icon Pack"
"com.android.wallpaperbackup" = "Wallpaper Backup"
"com.android.providers.blockednumber" = "Blocked Number Provider"
"com.android.providers.userdictionary" = "User Dictionary Provider"
"org.chromium.webapk.a8d1f227dd3056c41_v2" = "WebAPK a8d1f227dd3056c41"
"com.android.emergency" = "Emergency Info"
"com.qualcomm.qti.seccamservice" = "Qualcomm Secure Camera Service"
"com.qualcomm.qti.qmmi" = "Qualcomm QMMI"
"com.google.android.gms.location.history" = "Google Location History"
"com.android.internal.systemui.navbar.gestural" = "Gestural Navigation"
"com.iexceed.ib.digitalbankingprod" = "IndusInd Bank"
"com.android.location.fused" = "Fused Location"
"com.android.theme.color.orchid" = "Orchid Color Theme"
"com.android.deskclock" = "Clock"
"com.android.systemui" = "System UI"
"com.android.theme.color.purple" = "Purple Color Theme"
"com.android.bluetoothmidiservice" = "Bluetooth MIDI Service"
"com.qualcomm.qti.confdialer" = "Qualcomm Conf Dialer"
"com.qualcomm.qti.poweroffalarm" = "Qualcomm Power Off Alarm"
"com.mi.globallayout" = "MIUI Global Layout"
"com.xiaomi.discover" = "Xiaomi Discover"
"com.android.thememanager" = "Theme Manager"
"com.android.traceur" = "Traceur"
"com.miui.fmservice" = "MIUI FM Service"
"com.android.thememanager.module" = "Theme Manager Module"
"org.chromium.webapk.a577a5a178d186be3_v2" = "WebAPK a577a5a178d186be3"
"com.lbe.security.miui" = "LBE Security MIUI"
"android.autoinstalls.config.Xiaomi.lavender" = "Xiaomi Lavender Auto Installs"
"com.android.bluetooth" = "Bluetooth"
"com.qualcomm.timeservice" = "Qualcomm Time Service"
"com.qualcomm.atfwd" = "Qualcomm AT Forwarding"
"com.android.providers.contacts" = "Contacts Provider"
"com.android.captiveportallogin" = "Captive Portal Login"
"com.android.theme.icon.roundedrect" = "Rounded Rect Icon Theme"
"com.google.android.GoogleCamera" = "Google Camera"
"com.android.internal.systemui.navbar.gestural_narrow_back" = "Gestural Narrow Back Navigation"
"com.android.theme.icon_pack.rounded.settings" = "Rounded Settings Icon Pack"
"com.android.overlay.telephony" = "Telephony Overlay"
"com.snapchat.android" = "Snapchat"
"com.miui.core" = "MIUI Core"
"com.miui.face" = "MIUI Face"
"com.miui.home" = "MIUI Home"
"com.miui.audioeffect" = "MIUI Audio Effect"



}

$checkboxes = [System.Collections.ArrayList]@()
$currentAppList = [System.Collections.ArrayList]@()
$allSelected = $false
$script:SelectedUserPkgs = @{}
$script:SelectedSystemPkgs = @{}
$script:BulkSelecting = $false
$script:CachedUserPkgs = @()
$script:CachedSystemPkgs = @()
$script:LiveAppLabels = @{}   # package -> friendly label fetched live from device

# Fetch app labels from device using dumpsys package
# Parses "nonLocalizedLabel=App Name" lines and maps them to their package
function Update-AppLabelCache {
    Write-Host -ForegroundColor Cyan "Fetching app labels from device..."
    $script:LiveAppLabels = @{}
    try {
        $raw = & $adbPath shell dumpsys package packages 2>&1
        if (-not $raw) { return }

        $currentPkg = $null
        foreach ($line in $raw) {
            $line = $line.ToString().Trim()

            # Detect package block: "Package [com.example] (...)"
            if ($line -match '^\s*Package\s+\[([^\]]+)\]') {
                $currentPkg = $Matches[1].Trim()
                continue
            }

            # Grab nonLocalizedLabel if present
            if ($currentPkg -and $line -match 'nonLocalizedLabel=(.+)') {
                $lbl = $Matches[1].Trim()
                # Skip empty, "null", pure-numeric (resource ID refs), and labels that are just the package name
                if ($lbl -and $lbl -ne 'null' -and $lbl -notmatch '^\d+$' -and $lbl -ne $currentPkg) {
                    if (-not $script:LiveAppLabels.ContainsKey($currentPkg)) {
                        $script:LiveAppLabels[$currentPkg] = $lbl
                    }
                }
            }
        }
        Write-Host -ForegroundColor Green "Fetched labels for $($script:LiveAppLabels.Count) apps."
    } catch {
        Write-Host -ForegroundColor Yellow "Could not fetch app labels: $($_.Exception.Message)"
    }
}

function Get-DisplayName([string]$PackageName) {
    # 1. Hardcoded dict (highest priority - curated names)
    if ($appNames.ContainsKey($PackageName)) { return $appNames[$PackageName] }
    # 2. Live label fetched from device
    if ($script:LiveAppLabels.ContainsKey($PackageName)) { return $script:LiveAppLabels[$PackageName] }
    # 3. Fallback: package name as-is
    return $PackageName
}

function Get-CurrentAppType {
    if ($userRadio.IsChecked) { return "User" }
    if ($systemRadio.IsChecked) { return "System" }
    return "All"
}

function Test-PackageMatchesQuery([string]$PackageName, [string]$Query) {
    if ([string]::IsNullOrWhiteSpace($Query)) { return $true }
    $displayName = Get-DisplayName $PackageName
    return "$displayName $PackageName".ToLower().Contains($Query)
}

function Get-PackageEntriesForView {
    param([string]$Query = "")
    $q = $Query.Trim().ToLower()
    $entries = [System.Collections.ArrayList]@()
    $searching = -not [string]::IsNullOrWhiteSpace($q)

    # Search always scans both user and system apps
    if ($searching) {
        foreach ($pkg in $script:CachedUserPkgs) {
            if (Test-PackageMatchesQuery $pkg $q) {
                [void]$entries.Add(@{ Package = $pkg; AppType = "User" })
            }
        }
        foreach ($pkg in $script:CachedSystemPkgs) {
            if (Test-PackageMatchesQuery $pkg $q) {
                [void]$entries.Add(@{ Package = $pkg; AppType = "System" })
            }
        }
        return $entries
    }

    if ($allRadio.IsChecked) {
        foreach ($pkg in $script:CachedUserPkgs) {
            [void]$entries.Add(@{ Package = $pkg; AppType = "User" })
        }
        foreach ($pkg in $script:CachedSystemPkgs) {
            [void]$entries.Add(@{ Package = $pkg; AppType = "System" })
        }
    } elseif ($userRadio.IsChecked) {
        foreach ($pkg in $script:CachedUserPkgs) {
            [void]$entries.Add(@{ Package = $pkg; AppType = "User" })
        }
    } else {
        foreach ($pkg in $script:CachedSystemPkgs) {
            [void]$entries.Add(@{ Package = $pkg; AppType = "System" })
        }
    }
    return $entries
}

function Update-PackageCache {
    Write-Host -ForegroundColor Cyan "Refreshing app lists from device..."

    # Check device is actually connected before running package commands
    $deviceLines = & $adbPath devices 2>&1 | Where-Object { $_ -match "\tdevice$" }
    if (-not $deviceLines) {
        Write-Host -ForegroundColor Yellow "No device connected - skipping package cache refresh."
        $script:CachedUserPkgs   = @()
        $script:CachedSystemPkgs = @()
        return
    }

    $userPkgs = ConvertFrom-PackageOutput (Run-ADBCommand @('shell', 'pm', 'list', 'packages', '-3') -AllowFailure -Quiet)
    if ($userPkgs.Count -eq 0) {
        $allPkgs  = ConvertFrom-PackageOutput (Run-ADBCommand @('shell', 'pm', 'list', 'packages') -AllowFailure -Quiet)
        $userPkgs = $allPkgs | Where-Object { $_ -notmatch '^com\.android\.' }
    }
    $sysPkgs = ConvertFrom-PackageOutput (Run-ADBCommand @('shell', 'pm', 'list', 'packages', '-s') -AllowFailure -Quiet)
    if ($sysPkgs.Count -eq 0) {
        $allPkgs = ConvertFrom-PackageOutput (Run-ADBCommand @('shell', 'pm', 'list', 'packages') -AllowFailure -Quiet)
        $sysPkgs = $allPkgs | Where-Object { $_ -match '^com\.android\.' -or $_ -notmatch '^com\.' }
    }
    $script:CachedUserPkgs   = @($userPkgs | Sort-Object -Unique)
    $script:CachedSystemPkgs = @($sysPkgs  | Sort-Object -Unique)
    Write-Host -ForegroundColor Green "Cached $($script:CachedUserPkgs.Count) user + $($script:CachedSystemPkgs.Count) system apps."

    # Fetch friendly app labels from device (fills $script:LiveAppLabels)
    Update-AppLabelCache
}

function Render-AppList {
    param([System.Collections.IEnumerable]$Entries)
    $appListPanel.Children.Clear()
    $checkboxes.Clear()
    $currentAppList.Clear()
    $script:BulkSelecting = $true
    try {
        foreach ($entry in $Entries) {
            $pkg = $entry.Package
            $appType = $entry.AppType
            $name = Get-DisplayName $pkg
            $cb = New-AppListRow $pkg $name $appType
            [void]$currentAppList.Add($pkg)
            [void]$checkboxes.Add($cb)
            [void]$appListPanel.Children.Add($cb)
        }
    } finally {
        $script:BulkSelecting = $false
    }
}

function Get-SelectionSet([string]$AppType) {
    if ($AppType -eq "User") { return $script:SelectedUserPkgs }
    return $script:SelectedSystemPkgs
}

function Test-PackageSelected([string]$PackageName, [string]$AppType) {
    return (Get-SelectionSet $AppType).ContainsKey($PackageName)
}

function Set-PackageSelected([string]$PackageName, [string]$AppType, [bool]$Selected) {
    $set = Get-SelectionSet $AppType
    if ($Selected) { $set[$PackageName] = $true } else { $set.Remove($PackageName) | Out-Null }
    if (-not $script:BulkSelecting) { Update-SelectionPanel }
}

function New-AppListRow([string]$PackageName, [string]$DisplayName, [string]$AppType) {
    $fg = ConvertTo-Brush $Themes[$script:CurrentTheme].Foreground
    $cb = New-Object Windows.Controls.CheckBox
    $showType = $allRadio.IsChecked -or (-not [string]::IsNullOrWhiteSpace($searchBox.Text))
    $typeTag = if ($showType) {
        if ($AppType -eq "System") { "[System] " } else { "[User] " }
    } else { "" }
    $cb.Content = "$typeTag$DisplayName ($PackageName)"
    $cb.Tag = @{
        Package     = $PackageName
        DisplayName = $DisplayName
        AppType     = $AppType
    }
    $cb.Foreground = $fg
    $cb.Margin = New-Object Windows.Thickness(0, 2, 0, 2)

    $cb.IsChecked = Test-PackageSelected $PackageName $AppType

    $cb.Add_Checked({
        param($s, $e)
        $info = $s.Tag
        Set-PackageSelected $info.Package $info.AppType $true
    })
    $cb.Add_Unchecked({
        param($s, $e)
        $info = $s.Tag
        Set-PackageSelected $info.Package $info.AppType $false
    })

    return $cb
}

function New-SelectionListItem([string]$PackageName) {
    $fg = ConvertTo-Brush $Themes[$script:CurrentTheme].Foreground
    $muted = ConvertTo-Brush $Themes[$script:CurrentTheme].MutedText
    $displayName = Get-DisplayName $PackageName

    $border = New-Object Windows.Controls.Border
    $border.Margin = New-Object Windows.Thickness(0, 0, 0, 6)
    $border.Padding = New-Object Windows.Thickness(6, 4, 6, 4)
    $border.CornerRadius = New-Object Windows.CornerRadius(3)
    $border.Background = ConvertTo-Brush $Themes[$script:CurrentTheme].InputBg
    $border.BorderBrush = ConvertTo-Brush $Themes[$script:CurrentTheme].InputBorder
    $border.BorderThickness = New-Object Windows.Thickness(1)

    $stack = New-Object Windows.Controls.StackPanel
    $nameBlock = New-Object Windows.Controls.TextBlock
    $nameBlock.Text = $displayName
    $nameBlock.FontSize = 12
    $nameBlock.FontWeight = [Windows.FontWeights]::SemiBold
    $nameBlock.Foreground = $fg
    $nameBlock.TextWrapping = [Windows.TextWrapping]::Wrap
    $pkgBlock = New-Object Windows.Controls.TextBlock
    $pkgBlock.Text = $PackageName
    $pkgBlock.FontSize = 10
    $pkgBlock.Foreground = $muted
    $pkgBlock.TextWrapping = [Windows.TextWrapping]::Wrap
    $pkgBlock.Margin = New-Object Windows.Thickness(0, 2, 0, 0)
    [void]$stack.Children.Add($nameBlock)
    [void]$stack.Children.Add($pkgBlock)
    $border.Child = $stack
    return $border
}

function Update-SelectionPanel {
    if ($null -eq $selectedUserPanel) { return }
    $selectedUserPanel.Children.Clear()
    $selectedSystemPanel.Children.Clear()

    $userList = @($script:SelectedUserPkgs.Keys) | Sort-Object
    $sysList = @($script:SelectedSystemPkgs.Keys) | Sort-Object
    $total = $userList.Count + $sysList.Count

    $selectedSummaryText.Text = "Selected: $total"
    $selectedUserHeader.Text = "User Apps ($($userList.Count))"
    $selectedSystemHeader.Text = "System Apps ($($sysList.Count))"

    foreach ($pkg in $userList) {
        [void]$selectedUserPanel.Children.Add((New-SelectionListItem $pkg))
    }
    foreach ($pkg in $sysList) {
        [void]$selectedSystemPanel.Children.Add((New-SelectionListItem $pkg))
    }

    if ($userList.Count -eq 0) {
        $empty = New-Object Windows.Controls.TextBlock
        $empty.Text = "No user apps selected"
        $empty.FontSize = 11
        $empty.Foreground = ConvertTo-Brush $Themes[$script:CurrentTheme].MutedText
        $empty.Margin = New-Object Windows.Thickness(0, 4, 0, 4)
        [void]$selectedUserPanel.Children.Add($empty)
    }
    if ($sysList.Count -eq 0) {
        $empty = New-Object Windows.Controls.TextBlock
        $empty.Text = "No system apps selected"
        $empty.FontSize = 11
        $empty.Foreground = ConvertTo-Brush $Themes[$script:CurrentTheme].MutedText
        $empty.Margin = New-Object Windows.Thickness(0, 4, 0, 4)
        [void]$selectedSystemPanel.Children.Add($empty)
    }
}

function ConvertFrom-PackageOutput($rawOutput) {
    if ($null -eq $rawOutput) { return @() }
    $text = (@($rawOutput) | Where-Object { $null -ne $_ } | ForEach-Object { $_.ToString() }) -join "`n"
    if ([string]::IsNullOrWhiteSpace($text)) { return @() }
    # ADB may return one line: "package:foo package:bar" - match all package: entries
    $matches = [regex]::Matches($text, 'package:\s*([^\s\r\n]+)')
    if ($matches.Count -gt 0) {
        return $matches | ForEach-Object { $_.Groups[1].Value.Trim() } | Sort-Object -Unique
    }
    return @($text -split "`n") |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -match '^\s*package:' } |
        ForEach-Object { ($_ -replace '^\s*package:\s*', '').Trim() } |
        Where-Object { $_ } |
        Sort-Object -Unique
}

# Run ADB command (argument array avoids broken .Split() on package names)
function Test-PmOutputSuccess([string]$Text) {
    if ([string]::IsNullOrWhiteSpace($Text)) { return $false }
    # Explicit success signals
    if ($Text -match '(?i)^Success\b') { return $true }
    if ($Text -match '(?i)new state:\s*disabled') { return $true }
    # Explicit failure signals - including ADB connection errors
    if ($Text -match '(?i)\bFailure\b') { return $false }
    if ($Text -match '(?i)\bSecurityException\b') { return $false }
    if ($Text -match '(?i)error:\s*closed') { return $false }
    if ($Text -match '(?i)error:\s*') { return $false }
    if ($Text -match '(?i)Exception occurred') { return $false }
    if ($Text -match '(?i)does not own package') { return $false }
    if ($Text -match '(?i)not installed for') { return $false }
    # If output has no clear success word, treat as failure (safer default)
    return $false
}

function Run-ADBCommand {
    param(
        [Parameter(Mandatory)][string[]]$Arguments,
        [switch]$AllowFailure,
        [switch]$Quiet
    )
    $argLine = ($Arguments -join ' ')
    # Prepend -s <serial> when a specific device is targeted
    $fullArgs = if ($script:ActiveSerial) { @('-s', $script:ActiveSerial) + $Arguments } else { $Arguments }
    Write-Host -ForegroundColor Cyan "Executing: $adbPath $(-join ($fullArgs -join ' '))"
    $output = & $adbPath @fullArgs 2>&1 | ForEach-Object { $_.ToString() }
    $exitCode = $LASTEXITCODE
    Write-Host -ForegroundColor Cyan "ADB output: $output"
    $text = (@($output) -join "`n").Trim()
    $failed = -not (Test-PmOutputSuccess $text) -and ($exitCode -ne 0 -or $text -match '(?i)\bFailure\b')
    if ($failed -and -not $AllowFailure) {
        Write-Host -ForegroundColor Red "ADB command failed (exit $exitCode)."
        if (-not $Quiet) {
            [System.Windows.MessageBox]::Show("ADB Error:`n$text", "Error")
        }
        return $null
    }
    return @($output)
}

# If Wi-Fi ADB connection dropped, try to reconnect once
function Repair-AdbConnection {
    $ip   = $wifiIpBox.Text.Trim()
    $port = $wifiPortBox.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($ip) -or $ip -eq "192.168.1." -or
        [string]::IsNullOrWhiteSpace($port) -or $port -notmatch '^\d+$') { return $false }
    Write-Host -ForegroundColor Yellow "Connection lost - attempting reconnect to ${ip}:${port}..."
    $out = (& $adbPath connect "${ip}:${port}" 2>&1) -join " "
    Write-Host -ForegroundColor Yellow "Reconnect result: $out"
    Start-Sleep -Milliseconds 800
    return ($out -match "connected to|already connected")
}

# System apps cannot use "adb uninstall" - remove for user 0 instead
function Uninstall-AppPackage([string]$PackageName, [string]$AppType) {
    $isSystem = ($AppType -eq "System")
    $attempts = if ($isSystem) {
        @(
            @('shell', 'pm', 'uninstall', '--user', '0', $PackageName),
            @('shell', 'pm', 'uninstall', '-k', '--user', '0', $PackageName)
        )
    } else {
        @(
            @('uninstall', $PackageName),
            @('shell', 'pm', 'uninstall', '--user', '0', $PackageName),
            @('shell', 'pm', 'uninstall', '-k', '--user', '0', $PackageName)
        )
    }
    $lastText = ""
    $reconnectTried = $false
    foreach ($args in $attempts) {
        $output = Run-ADBCommand $args -AllowFailure -Quiet
        $lastText = (@($output) -join "`n").Trim()

        # If we got "error: closed" and haven't retried yet, reconnect and retry same command
        if ($lastText -match '(?i)error:\s*closed' -and -not $reconnectTried) {
            $reconnectTried = $true
            Write-Host -ForegroundColor Yellow "'error: closed' detected - reconnecting ADB..."
            $reconnected = Repair-AdbConnection
            if ($reconnected) {
                Write-Host -ForegroundColor Cyan "Reconnected! Retrying command..."
                $output   = Run-ADBCommand $args -AllowFailure -Quiet
                $lastText = (@($output) -join "`n").Trim()
            } else {
                [System.Windows.MessageBox]::Show(
                    "ADB connection lost (error: closed) and reconnect failed.`n`nPlease click Refresh and try again.",
                    "Connection Lost"
                )
                return $null
            }
        }

        if ($null -ne $output -and (Test-PmOutputSuccess $lastText)) {
            Write-Host -ForegroundColor Green "Uninstall succeeded for $PackageName"
            return $output
        }
    }
    Write-Host -ForegroundColor Red "Uninstall failed for $PackageName : $lastText"
    $hint = if ($isSystem) {
        "System apps are removed for your user only (not deleted from the phone firmware).`nTry ""Disable Selected Apps"" if uninstall still fails."
    } else {
        "Try ""Disable Selected Apps"" for apps that cannot be fully removed."
    }
    [System.Windows.MessageBox]::Show("Could not uninstall $PackageName`n`n$lastText`n`n$hint", "Uninstall Failed")
    return $null
}

function Update-UninstallButtonLabel {
    if ($systemRadio.IsChecked) {
        $uninstallBtn.Content = "Remove for User"
        $uninstallBtn.ToolTip = "Removes system apps for your user (pm uninstall --user 0). Does not require root."
    } elseif ($allRadio.IsChecked) {
        $uninstallBtn.Content = "Uninstall / Remove Selected"
        $uninstallBtn.ToolTip = "Uninstalls user apps; removes system apps for your user."
    } else {
        $uninstallBtn.Content = "Uninstall Selected Apps"
        $uninstallBtn.ToolTip = "Uninstalls user-installed apps."
    }
}

function Apply-SearchFilter {
    $query = $searchBox.Text.Trim().ToLower()
    Write-Host -ForegroundColor Cyan "Search query: $query"
    $entries = Get-PackageEntriesForView -Query $query
    Render-AppList $entries
    Write-Host -ForegroundColor Green "Showing $($entries.Count) apps."
}

# Load apps with fallback
function Load-Apps {
    param([switch]$RefreshCache)
    Write-Host -ForegroundColor Cyan "Loading apps..."

    # Check device first - if none connected, show waiting state silently (no popup)
    $deviceLines = & $adbPath devices 2>&1 | Where-Object { $_ -match "\tdevice$" }
    if (-not $deviceLines) {
        Write-Host -ForegroundColor Yellow "No device - app list not loaded."
        # Show a friendly placeholder in the app list instead of a popup
        $appListPanel.Children.Clear()
        $checkboxes.Clear()
        $placeholder = New-Object Windows.Controls.TextBlock
        $placeholder.Text = "No device connected.  Connect via Wi-Fi (Step 1 + Step 2 above) or plug in USB, then click Refresh."
        $placeholder.Foreground = [System.Windows.Media.Brushes]::LightGray
        $placeholder.FontSize = 13
        $placeholder.TextWrapping = "Wrap"
        $placeholder.Margin = New-Object Windows.Thickness(16, 20, 16, 0)
        [void]$appListPanel.Children.Add($placeholder)
        return
    }

    if ($RefreshCache -or $script:CachedUserPkgs.Count -eq 0) {
        Update-PackageCache
    }
    if ($script:CachedUserPkgs.Count -eq 0 -and $script:CachedSystemPkgs.Count -eq 0) {
        Write-Host -ForegroundColor Red "No apps found."
        [System.Windows.MessageBox]::Show("No apps found. Check device connection and ADB authorization.", "No Apps")
        return
    }
    $query = $searchBox.Text.Trim().ToLower()
    $entries = Get-PackageEntriesForView -Query $query
    Render-AppList $entries
    Update-SelectionPanel
    Write-Host -ForegroundColor Green "Loaded $($entries.Count) apps."
}

# Apply saved theme, then load apps
Set-Theme (Get-SavedTheme)
Update-UninstallButtonLabel
Update-SelectionPanel
Load-Apps -RefreshCache

# Radio button events (single handler each - avoids duplicate Load-Apps calls)
$userRadio.Add_Checked({
    $script:allSelected = $false
    $selectAllBtn.Content = "Select All"
    Update-UninstallButtonLabel
    Load-Apps
    Write-Host -ForegroundColor Green "Switched to User Apps"
})
$systemRadio.Add_Checked({
    $script:allSelected = $false
    $selectAllBtn.Content = "Select All"
    Update-UninstallButtonLabel
    Load-Apps
    Write-Host -ForegroundColor Green "Switched to System Apps"
})
$allRadio.Add_Checked({
    $script:allSelected = $false
    $selectAllBtn.Content = "Select All"
    Update-UninstallButtonLabel
    Load-Apps
    Write-Host -ForegroundColor Green "Switched to All Apps"
})

$themeToggleBtn.Add_Click({
    $next = if ($script:CurrentTheme -eq "Dark") { "Light" } else { "Dark" }
    Set-Theme $next
})

# Search filter (user + system apps from cache)
$searchBox.Add_TextChanged({ Apply-SearchFilter })

# Get selected packages
function Get-SelectedPackages {
    $selected = @($script:SelectedUserPkgs.Keys) + @($script:SelectedSystemPkgs.Keys)
    Write-Host -ForegroundColor Cyan "Selected packages ($($selected.Count)): $selected"
    return $selected
}

# Disable apps
$disableBtn.Add_Click({
    $selected = Get-SelectedPackages
    if (-not $selected) {
        Write-Host -ForegroundColor Red "No apps selected for disable."
        [System.Windows.MessageBox]::Show("Please select at least one app.", "No Selection")
        return
    }
    $result = [System.Windows.MessageBox]::Show(
        "Disabling apps may affect device functionality. Continue?",
        "Confirm Disable",
        [System.Windows.MessageBoxButton]::YesNo,
        [System.Windows.MessageBoxImage]::Warning
    )
    if ($result -ne "Yes") { Write-Host -ForegroundColor Yellow "Disable cancelled."; return }
    foreach ($pkg in $selected) {
        $output = Run-ADBCommand @('shell', 'pm', 'disable-user', '--user', '0', $pkg)
        if ($null -eq $output) { Write-Host -ForegroundColor Red "Disable failed for $pkg"; return }
    }
    $script:SelectedUserPkgs = @{}
    $script:SelectedSystemPkgs = @{}
    [System.Windows.MessageBox]::Show("Selected apps disabled.", "Done")
    Load-Apps -RefreshCache
})

# Uninstall apps
$uninstallBtn.Add_Click({
    $selected = Get-SelectedPackages
    if (-not $selected) {
        Write-Host -ForegroundColor Red "No apps selected for uninstall."
        [System.Windows.MessageBox]::Show("Please select at least one app.", "No Selection")
        return
    }
    $hasSystem = $script:SelectedSystemPkgs.Keys.Count -gt 0
    $hasUser = $script:SelectedUserPkgs.Keys.Count -gt 0
    $confirmMsg = if ($hasSystem -and $hasUser) {
        "Mixed selection: user apps will be uninstalled; system apps removed for your user only.`nContinue?"
    } elseif ($hasSystem) {
        "System apps will be removed for your user profile only (not erased from firmware).`nYou can restore them later with: adb shell pm install-existing --user 0 <package>`n`nContinue?"
    } else {
        "Uninstalling apps may break device functionality. Continue?"
    }
    $result = [System.Windows.MessageBox]::Show(
        $confirmMsg,
        "Confirm Uninstall",
        [System.Windows.MessageBoxButton]::YesNo,
        [System.Windows.MessageBoxImage]::Warning
    )
    if ($result -ne "Yes") { Write-Host -ForegroundColor Yellow "Uninstall cancelled."; return }
    foreach ($pkg in @($script:SelectedUserPkgs.Keys)) {
        if ($null -eq (Uninstall-AppPackage $pkg "User")) { return }
    }
    foreach ($pkg in @($script:SelectedSystemPkgs.Keys)) {
        if ($null -eq (Uninstall-AppPackage $pkg "System")) { return }
    }
    $script:SelectedUserPkgs = @{}
    $script:SelectedSystemPkgs = @{}
    $doneMsg = if ($hasSystem -and -not $hasUser) {
        "Selected system apps removed for your user."
    } else {
        "Selected apps processed."
    }
    [System.Windows.MessageBox]::Show($doneMsg, "Done")
    Load-Apps -RefreshCache
})

# Select All toggle
$selectAllBtn.Add_Click({
    $script:allSelected = -not $script:allSelected
    $script:BulkSelecting = $true
    try {
        foreach ($cb in $checkboxes) {
            $cb.IsChecked = $script:allSelected
            $pkg = $cb.Tag.Package
            $set = Get-SelectionSet $cb.Tag.AppType
            if ($script:allSelected) { $set[$pkg] = $true } else { $set.Remove($pkg) | Out-Null }
        }
    } finally {
        $script:BulkSelecting = $false
    }
    Update-SelectionPanel
    $selectAllBtn.Content = if ($script:allSelected) { "Deselect All" } else { "Select All" }
    Write-Host -ForegroundColor Cyan "Select All toggled to: $script:allSelected"
})

# --- Wi-Fi ADB Functions ------------------------------------------------------

function Pair-WifiAdb {
    $ip       = $wifiIpBox.Text.Trim()
    $pairPort = $wifiPairPortBox.Text.Trim()

    # Validate IP
    if ([string]::IsNullOrWhiteSpace($ip) -or $ip -eq "192.168.1.") {
        [System.Windows.MessageBox]::Show(
            "Please enter a valid device IP address in the IP field.",
            "Wi-Fi Pair"
        )
        return
    }

    # Validate Pair Port
    if ([string]::IsNullOrWhiteSpace($pairPort) -or $pairPort -notmatch '^\d+$') {
        [System.Windows.MessageBox]::Show(
            "Please enter the Pair Port shown in:`nSettings > Developer Options > Wireless Debugging > Pair device with pairing code",
            "Wi-Fi Pair"
        )
        return
    }

    # Ask for 6-digit pairing code via InputBox
    Add-Type -AssemblyName Microsoft.VisualBasic
    $pairingCode = [Microsoft.VisualBasic.Interaction]::InputBox(
        "Enter the 6-digit pairing code shown on your device:`n`nSettings > Developer Options > Wireless Debugging > Pair device with pairing code",
        "Enter Pairing Code",
        ""
    )

    if ([string]::IsNullOrWhiteSpace($pairingCode)) {
        [System.Windows.MessageBox]::Show("Pairing cancelled - no code entered.", "Wi-Fi Pair")
        return
    }

    if ($pairingCode -notmatch '^\d{6}$') {
        [System.Windows.MessageBox]::Show(
            "Invalid pairing code. Please enter exactly 6 digits.",
            "Wi-Fi Pair"
        )
        return
    }

    $wifiPairBtn.IsEnabled = $false
    $wifiPairBtn.Content   = "Pairing..."

    try {
        Write-Host -ForegroundColor Cyan "Pairing with ${ip}:${pairPort} using code $pairingCode ..."

        # adb pair expects the code to be piped via stdin
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName               = $adbPath
        $psi.Arguments              = "pair `"${ip}:${pairPort}`""
        $psi.RedirectStandardInput  = $true
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError  = $true
        $psi.UseShellExecute        = $false
        $psi.CreateNoWindow         = $true

        $proc = [System.Diagnostics.Process]::Start($psi)
        $proc.StandardInput.WriteLine($pairingCode)
        $proc.StandardInput.Close()

        $stdout = $proc.StandardOutput.ReadToEnd()
        $stderr = $proc.StandardError.ReadToEnd()
        $proc.WaitForExit()

        $output = ($stdout + $stderr).Trim()
        Write-Host -ForegroundColor Cyan "adb pair output: $output"

        if ($output -match "Successfully paired|paired to") {
            # Auto-fill connect port hint
            [System.Windows.MessageBox]::Show(
                "SUCCESS: Device paired with ${ip}:${pairPort}!`n`nNow go to Step 2:`n- Enter the CONNECT port (shown on the main Wireless Debugging screen, not the pair port).`n- Click Connect.",
                "Paired!"
            )
            # Pre-fill IP for Step 2 connect (already shared)
            Update-WifiStatus
        } else {
            [System.Windows.MessageBox]::Show(
                "FAILED: Pairing did not succeed.`n`nOutput: $output`n`nTips:`n- Make sure the pairing code is still visible on your device (it expires quickly).`n- Double-check the Pair Port (not the connect port).`n- Device and PC must be on the same Wi-Fi network.",
                "Pairing Failed"
            )
        }
    } catch {
        [System.Windows.MessageBox]::Show(
            "Error during pairing: $($_.Exception.Message)",
            "Pair Error"
        )
    } finally {
        $wifiPairBtn.IsEnabled = $true
        $wifiPairBtn.Content   = "Pair"
    }
}

function Get-DeviceName {
    # Try to get a friendly device name via adb shell
    try {
        $brand  = (& $adbPath shell getprop ro.product.brand  2>&1).Trim()
        $model  = (& $adbPath shell getprop ro.product.model  2>&1).Trim()
        if ($brand -and $model -and $brand -notmatch "error|daemon" -and $model -notmatch "error|daemon") {
            # Capitalize brand first letter, e.g. "redmi" -> "Redmi"
            $brand = (Get-Culture).TextInfo.ToTitleCase($brand.ToLower())
            return "$brand $model"
        }
    } catch {}
    return $null
}

function Update-WifiStatus {
    $devicesRaw = & $adbPath devices 2>&1 | Select-String -Pattern "\tdevice$"
    if (-not $devicesRaw) {
        $wifiStatusLabel.Text       = "[No Device]"
        $wifiStatusLabel.Foreground = ConvertTo-Brush "#FC8181"
        $window.Title               = "ADB App Manager  [No Device]"
        return
    }
    # Check if any connected device is over TCP/IP (IP:port pattern)
    $allDevLines = & $adbPath devices 2>&1 | Where-Object { $_ -match "\tdevice$" }
    $hasWifi = $allDevLines | Where-Object { $_ -match "^\d+\.\d+\.\d+\.\d+:\d+" }
    $hasUsb  = $allDevLines | Where-Object { $_ -notmatch "^\d+\.\d+\.\d+\.\d+:\d+" }

    # Fetch device name once
    $deviceName = Get-DeviceName

    if ($hasWifi -and $hasUsb) {
        $label = if ($deviceName) { "$deviceName  [USB+Wi-Fi]" } else { "[USB + Wi-Fi]" }
        $wifiStatusLabel.Text       = $label
        $wifiStatusLabel.Foreground = ConvertTo-Brush "#F6AD55"
        $window.Title               = "ADB App Manager  [$label]"
    } elseif ($hasWifi) {
        $label = if ($deviceName) { "$deviceName  [Wi-Fi]" } else { "[Wi-Fi]" }
        $wifiStatusLabel.Text       = $label
        $wifiStatusLabel.Foreground = ConvertTo-Brush "#63B3ED"
        $window.Title               = "ADB App Manager  [$label]"
    } else {
        $label = if ($deviceName) { "$deviceName  [USB]" } else { "[USB]" }
        $wifiStatusLabel.Text       = $label
        $wifiStatusLabel.Foreground = ConvertTo-Brush "#68D391"
        $window.Title               = "ADB App Manager  [$label]"
    }
}

function Connect-WifiAdb {
    $ip   = $wifiIpBox.Text.Trim()
    $port = $wifiPortBox.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($ip) -or $ip -eq "192.168.1.") {
        [System.Windows.MessageBox]::Show("Please enter a valid device IP address.", "Wi-Fi Connect")
        return
    }
    if ([string]::IsNullOrWhiteSpace($port) -or $port -notmatch '^\d+$') { $port = "5555" }

    $wifiConnectBtn.IsEnabled = $false
    $wifiConnectBtn.Content   = "Connecting..."
    try {
        # Step 1: If a USB device is present, switch it to TCP/IP mode first
        $usbLines = & $adbPath devices 2>&1 | Where-Object { $_ -match "\tdevice$" -and $_ -notmatch "^\d+\.\d+\.\d+\.\d+:\d+" }
        if ($usbLines) {
            Write-Host -ForegroundColor Cyan "Enabling TCP/IP on port $port via USB..."
            $tcpOut = & $adbPath tcpip $port 2>&1
            Write-Host -ForegroundColor Cyan "tcpip output: $tcpOut"
            Start-Sleep -Seconds 2   # give device a moment to switch
        }

        # Step 2: Connect
        Write-Host -ForegroundColor Cyan "Connecting to ${ip}:${port}..."
        $connectOut = (& $adbPath connect "${ip}:${port}" 2>&1) -join " "
        Write-Host -ForegroundColor Cyan "connect output: $connectOut"

        if ($connectOut -match "connected to|already connected") {
            [System.Windows.MessageBox]::Show(
                "SUCCESS: Connected to ${ip}:${port} over Wi-Fi!`n`nYou can now unplug the USB cable.",
                "Wi-Fi Connected"
            )
            Update-WifiStatus
            Load-Apps -RefreshCache
        } else {
            [System.Windows.MessageBox]::Show(
                "FAILED: Could not connect to ${ip}:${port}`n`nError: $connectOut`n`nTips:`n- Make sure the device and PC are on the same Wi-Fi network.`n" +
                "- Check IP: Settings -> About phone -> Status -> IP address.`n" +
                "- USB must be plugged in for the FIRST Wi-Fi pairing (script runs adb tcpip $port automatically).",
                "Connection Failed"
            )
        }
    } finally {
        $wifiConnectBtn.IsEnabled = $true
        $wifiConnectBtn.Content   = "Connect"
    }
}

function Disconnect-WifiAdb {
    $ip   = $wifiIpBox.Text.Trim()
    $port = $wifiPortBox.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($port) -or $port -notmatch '^\d+$') { $port = "5555" }

    $target = if (-not [string]::IsNullOrWhiteSpace($ip) -and $ip -ne "192.168.1.") {
        "${ip}:${port}"
    } else { $null }

    if ($target) {
        $out = (& $adbPath disconnect $target 2>&1) -join " "
        Write-Host -ForegroundColor Cyan "Disconnect $target : $out"
    } else {
        # Disconnect all TCP/IP devices
        $out = (& $adbPath disconnect 2>&1) -join " "
        Write-Host -ForegroundColor Cyan "Disconnect all: $out"
    }

    Update-WifiStatus
    [System.Windows.MessageBox]::Show("Disconnected from Wi-Fi ADB.`nTo reconnect wirelessly, plug in USB and click Connect again.", "Disconnected")
    Load-Apps -RefreshCache
}

# Wire Wi-Fi buttons
$wifiPairBtn.Add_Click({ Pair-WifiAdb })

$wifiConnectBtn.Add_Click({ Connect-WifiAdb })

$wifiDisconnectBtn.Add_Click({ Disconnect-WifiAdb })

$wifiRefreshBtn.Add_Click({
    Write-Host -ForegroundColor Cyan "Refreshing device status and app list..."
    Update-WifiStatus
    Load-Apps -RefreshCache
})

# Sync status on startup
Update-WifiStatus

# Show GUI
try {
    $window.ShowDialog() | Out-Null
    Write-Host -ForegroundColor Green "GUI closed."
} catch {
    Write-Host -ForegroundColor Red "GUI display error: $($_.Exception.Message)"
}