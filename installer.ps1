#Check prerequisites
    #Is 64-Bit Java installed?
        if(Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object DisplayName -like "Java*")
        {
                if(Test-Path "$env:ProgramFiles\Java")
                {
                    $javaInstalled = $true
                }
                else
                {
                    $javaInstalled = $false
                    [Windows.Forms.MessageBox]::Show("Java 32-bit is installed, but not Java 64-Bit. Please click 'Install Java' to install it and then restart the program.","Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Error)
                }
            }
        else
        {
                $javaInstalled = $false
            }

    #Is 7-Zip installed?
        if(Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object DisplayName -like "7-Zip*")
        {
                $7ZipInstalled = $true
            }
        else
        {
                $7ZipInstalled = $false
            }

    #Check where it is installed. Have them change the install path if it's in program files.
        if(Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object DisplayName -eq "The Elder Scrolls V: Skyrim")
        {
            try
            {
                $skyrimPath = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object DisplayName -eq "The Elder Scrolls V: Skyrim" | Select-Object -ExpandProperty InstallLocation
            }
            catch
            {
                [Windows.Forms.MessageBox]::Show("COULD NOT FIND SKYRIM INSTALL! Please make sure Skyrim is installed somewhere other than program files!`r`nHow to install Skyrim somewhere else:`r`n1. Close steam`r`n2. Open your steam folder (by default, C:\Program Files (x86)\Steam)`r`n3. Navigate to steamapps`r`n4. Open libraryfolders.vdf with Notepad or some other word processor`r`n5. In the same fashion as the file has something like `"1`" `"C:\Program Files (x86)\Steam`" create a new line `"2`" `"C:\X`" where X is the name of the folder you would like to use.`r`n6. Make sure you physically create that folder in that place on your desired drive, and make sure it is empty.`r`n7. Open steam. Go to Steam > Settings > Downloads > Steam Library Folders. The new entry will be there.`r`n8. Steam will have created a steam.dll file in the new folder. Navigate to the folder, and create a new folder named `"steamapps`".`r`n9. When hitting Install on a game, you may choose the installation path for the game in a drop-down menu OR open the game properties and move the install folder under the Local Files tab.","Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Error)
                exit
            }
            if($skyrimPath -contains "*Program Files*")
            {
                $skyrimInstalled = $false
            }
            else
            {
                $skyrimInstalled = $true
            }
        }
        else
        {
            $skyrimInstalled = $false
        }
        if(!$skyrimInstalled)
        {
            [Windows.Forms.MessageBox]::Show("COULD NOT FIND SKYRIM INSTALL! Please make sure Skyrim is installed somewhere other than program files!`r`nHow to install Skyrim somewhere else:`r`n1. Close steam`r`n2. Open your steam folder (by default, C:\Program Files (x86)\Steam)`r`n3. Navigate to steamapps`r`n4. Open libraryfolders.vdf with Notepad or some other word processor`r`n5. In the same fashion as the file has something like `"1`" `"C:\Program Files (x86)\Steam`" create a new line `"2`" `"C:\X`" where X is the name of the folder you would like to use.`r`n6. Make sure you physically create that folder in that place on your desired drive, and make sure it is empty.`r`n7. Open steam. Go to Steam > Settings > Downloads > Steam Library Folders. The new entry will be there.`r`n8. Steam will have created a steam.dll file in the new folder. Navigate to the folder, and create a new folder named `"steamapps`".`r`n9. When hitting Install on a game, you may choose the installation path for the game in a drop-down menu OR open the game properties and move the install folder under the Local Files tab.","Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Error)
            exit
        }

#Add Assemblies
    #Windows Forms
    Add-Type -AssemblyName System.Windows.Forms
    #Zip Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem

#Create files and directorys
    #Path to Azura.exe
    $installerPath = (Get-Item .\).FullName
    $installerSrc = "$installerPath\src"
    #Create downloads folder
    New-Item -ItemType Directory -Path $installerPath\Downloads -Force
    $installerDownloads = (Get-Item $installerPath\Downloads).FullName

#Configure and install prereqs
    #Root Form window
    $configForm = New-Object System.Windows.Forms.Form
        $configForm.Width = 820
        $configForm.Height = 665
        $configForm.Text = "Azura's Star"
        $configForm.MaximizeBox = $false
        $configForm.MinimizeBox = $false
        $configForm.FormBorderStyle = 'Fixed3D' 
        $Icon = New-Object system.drawing.icon ("$installerSrc\img\azura.ico")
        $configForm.Icon = $Icon
            
            $configFormOutput = New-Object System.Windows.Forms.RichTextBox
                $configFormOutput.Top = 100
                $configFormOutput.Left = 10
                $configFormOutput.Size = New-Object System.Drawing.Size(300,500)
                $configFormOutput.ReadOnly = $true
                $configForm.Controls.Add($configFormOutput)

            function output($text)
            {
                $configFormOutput.AppendText("$text `r`n")
                $configFormOutput.ScrollToCaret()
            }

            $configFormPreReqsLabel = New-Object System.Windows.Forms.Label
                $configFormPreReqsLabel.Text = "Prerequisites"
                $configFormPreReqsLabel.Top = "10"
                $configFormPreReqsLabel.Left = "10"
                $configFormPreReqsLabel.Anchor + "Left,Top"
                $configForm.Controls.Add($configFormPreReqsLabel)

            $configFormPreReqsJava = New-Object System.Windows.Forms.Button
                switch($javaInstalled)
                {
                    $true 
                    {
                        $configFormPreReqsJava.Text = "Java Installed"
                        $configFormPreReqsJava.Enabled = $false
                        output("Java already installed")
                    }
                    $false
                    {
                        $configFormPreReqsJava.Text = "Install Java"
                    }
                }
                $configFormPreReqsJava.Top = 35
                $configFormPreReqsJava.Left = 10
                $configFormPreReqsJava.Size = New-Object System.Drawing.Size(100,25)
                $configFormPreReqsJava.ADD_CLICK(
                {
                    Start-Process $installerSrc\bin\jre-8u231-windows-x64.exe
                    output("Installing Java")
                })
                $configForm.Controls.Add($configFormPreReqsJava)

            $configFormPreReqs7zip = New-Object System.Windows.Forms.Button
                switch($7zipInstalled)
                {
                    $true 
                    {
                        $configFormPreReqs7zip.Text = "7zip Installed"
                        $configFormPreReqs7zip.Enabled = $false
                        output("7-Zip already Installed")
                    }
                    $false
                    {
                        $configFormPreReqs7zip.Text = "Install 7-Zip"
                    }
                }
                $configFormPreReqs7zip.Top = 35
                $configFormPreReqs7zip.Left = 110
                $configFormPreReqs7zip.Size = New-Object System.Drawing.Size(100,25)
                $configFormPreReqs7zip.ADD_CLICK(
                {
                    Start-Process $installerSrc\bin\7z1900-x64.exe
                    output("Installing 7-Zip")
                })
                $configForm.Controls.Add($configFormPreReqs7zip)

            $configFormPreReqsSkyrim = New-Object System.Windows.Forms.Button
                $configFormPreReqsSkyrim.Text = "Run Skyrim once"
                $configFormPreReqsSkyrim.Top = 35
                $configFormPreReqsSkyrim.Left = 210
                $configFormPreReqsSkyrim.Size = New-Object System.Drawing.Size(100,25)
                $configFormPreReqsSkyrim.ADD_CLICK(
                {
                    [Windows.Forms.MessageBox]::Show("When Skyrim launches, let it automatically detect your settings, then launch to the main menu. Then you can exit Skyrim and come back here to run the Preinstall.","Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
                    output("Launching Skyrim for first time set up")
                    $steamPath = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object DisplayName -Like "Steam" | Select-Object -ExpandProperty UninstallString) -replace "uninstall.exe","steam.exe"
                    Start-Process $steamPath -ArgumentList "-applaunch 72850"
                    $configFormPreReqsSkyrim.Enabled = $false
                    if($javaInstalled -and $7ZipInstalled)
                    {
                        $configFormPreReqsPreinstall.Enabled = $true
                        output("You may now run the Preinstall")

                    }
                    else
                    {
                        [Windows.Forms.MessageBox]::Show("Java and 7-Zip must be installed before you can run the Preinstall. Please install them and restart the installer","Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Error)
                        output("Java and 7-Zip must be installed before you can run the Preinstall. Please install them and restart the installer")
                    }
                })
                $configForm.Controls.Add($configFormPreReqsSkyrim)

            $configFormPreReqsPreinstall = New-Object System.Windows.Forms.Button
                $configFormPreReqsPreinstall.Enabled = $false
                $configFormPreReqsPreinstall.Text = "Run Preinstall"
                $configFormPreReqsPreinstall.Top = 65
                $configFormPreReqsPreinstall.Left = 210
                $configFormPreReqsPreinstall.Size = New-Object System.Drawing.Size(100,25)
                $configFormPreReqsPreinstall.ADD_CLICK(
                {

                    output("Getting Nexus API key")
                    [Windows.Forms.MessageBox]::Show("Some mods need to be downloaded from Nexus, this requires a Nexus Personal API Key which is given to premium Nexus accounts only. This is private to you and we don't save it, we just pass it through to Nexus.`r`n`r`nDO NOT SHARE THIS WITH ANYONE!`r`n`r`nYou can find your Personal API Key at the bottom of the page that will open in your default browser after clicking ok.", "Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
                    Start-Process "https://www.nexusmods.com/users/myaccount?tab=api%20access"
                    $configFormGetAPIKey = New-Object System.Windows.Forms.Form
                    $configFormGetAPIKey.Width = 600
                    $configFormGetAPIKey.Height = 600
                    $configFormGetAPIKey.Text = "Ultimate Skyrim Installation - Personal API Key"
                    $configFormGetAPIKey.Icon = $Icon
                    $getAPIKey = New-Object System.Windows.Forms.TextBox
                    $getAPIKey.Top = 10
                    $getAPIKey.Left = 10
                    $getAPIKey.Size = New-Object System.Drawing.Size(500, 50)
                    $getAPIKey.Scrollbars = "Vertical"
                    $getAPIKey.AutoSize = $false;
                    $getAPIKey.Multiline = $true
                    $configFormGetAPIKey.Controls.Add($getAPIKey)

                    $confirmAPIKey = New-Object System.Windows.Forms.Button
                    $confirmAPIKey.Text = "Continue"
                    $confirmAPIKey.Top = 100
                    $confirmAPIKey.Left = 150
                    $confirmAPIKey.ADD_CLICK(
                            {
                                $global:apiKey = $getAPIKey.Text
                                $configFormGetAPIKey.Close()
                            })
                    $configFormGetAPIKey.Controls.Add($confirmAPIKey)
                    $configFormGetAPIKey.ShowDialog()

                    output("Starting manual downloads, this might take a few minutes. This sometimes causes the window to not response even though it's still working. Be patient :)")

                    if(!(Test-Path $skyrimPath\skse_loader.exe) -and !(Test-Path "$skyrimPath\d3dx9_42.dll"))
                    {
                        output("Downloading SKSE and it's preloader...")
                        Invoke-WebRequest -Uri "https://skse.silverlock.org/beta/skse_1_07_03.7z" -OutFile "$installerDownloads\SKSE_install.7z"
                        $preloaderDownloadLink = Invoke-RestMethod -Uri "https://api.nexusmods.com/v1/games/skyrim/mods/75795/files/1000207412/download_link.json" -Headers @{"apikey"="$apiKey"}
                        Invoke-WebRequest -Uri $preloaderDownloadLink[0].URI -OutFile "$installerDownloads\SKSEPreloader.zip"
                        output("Download complete")

                        output("Installing SKSE...")
                        & "$env:ProgramFiles\7-Zip\7z.exe" "x" "$installerDownloads\SKSE_install.7z" "-o$skyrimPath" > $null
                        foreach($file in (Get-ChildItem -Path "$skyrimPath\skse_1_07_03"))
                        {
                            Copy-Item -Path $file.FullName -Destination "$skyrimPath\" -Force
                        }
                        Remove-Item "$installerDownloads\SKSE_install.7z"


                        $SKSEzip = Get-Item "$installerDownloads\SKSEPreloader.zip"
                        [System.IO.Compression.ZipFile]::ExtractToDirectory($SKSEzip.FullName, $skyrimPath)
                        Remove-Item "$installerDownloads\SKSEPreloader.zip"
                        output("Installed SKSE")
                    }else{output("SKSE already installed") }

                    output("Copying ENB files...")
                    Copy-Item -Path $installerSrc\bin\d3d9.dll -Destination $skyrimPath -Force
                    Copy-Item -Path $installerSrc\bin\enbhost.exe -Destination $skyrimPath -Force
                    Copy-Item -Path $installerSrc\bin\enblocal.ini -Destination $skyrimPath -Force
                    output("Copied ENB files")
                    
                    output("Creating install directories")
                    New-Item -ItemType Directory -Path $skyrimPath\US -Force
                    New-Item -ItemType Directory -Path $skyrimPath\US\Utilities -Force
                    New-Item -ItemType Directory -Path $skyrimPath\US\Downloads -Force
                    foreach($file in (Get-ChildItem -Path "$installerSrc\ultsky"))
                    {
                        Copy-Item -Path $file.FullName -Destination "$skyrimPath\US\Downloads" -Force
                    }
                    Copy-Item -Path "$installerSrc\bin\US 406hf2 Gamepad - LD Hotfix 1.auto" -Destination $skyrimPath\US -Force
                    Copy-Item -Path "$installerSrc\bin\US 406hf2 Keyboard - LD Hotfix 1.auto" -Destination $skyrimPath\US -Force
                    if(!(Test-Path -Path $skyrimPath\US\Utilities\TES5Edit.exe))
                    {
                        output("Downloading TES5Edit from Nexus...")
                        $TES5EditDownloadLink = Invoke-RestMethod -Uri "https://api.nexusmods.com/v1/games/skyrim/mods/25859/files/1000309592/download_link.json" -Headers @{"apikey"="$apiKey"}
                        Invoke-WebRequest -Uri $TES5EditDownloadLink[0].URI -OutFile "$installerDownloads\TES5Edit.7z"
                        output("Downloaded TES5Edit")

                        output("Extracting TES5Edit...")
                        & "$env:ProgramFiles\7-Zip\7z.exe" "x" "$installerDownloads/TES5Edit.7z" "-o$skyrimPath\US\Utilities" > $null
                        Remove-Item "$installerDownloads\TES5Edit.7z"
                        output("Extraxted TES5Edit")
                    }else{output("TES5Edit already installed")}
                    
                    if(!(Test-Path "$skyrimPath\US\Downloads\NVAC - New Vegas Anti Crash-53635-7-5-1-0.zip"))
                    {
                        output("Downloading NVAC...")
                        $NVACDownloadLink = Invoke-RestMethod -Uri "https://api.nexusmods.com/v1/games/newvegas/mods/53635/files/1000039152/download_link.json" -Headers @{"apikey"="$apiKey"}
                        Invoke-WebRequest -Uri $NVACDownloadLink[0].URI -OutFile "$skyrimPath\US\Downloads\NVAC - New Vegas Anti Crash-53635-7-5-1-0.zip"
                        output("Downloaded NVAC")

                    }else{output("NVAC already installed")}

                    if(!(Test-Path "$skyrimPath\US\Downloads\Wyrmstooth 1.17B.zip"))
                    {
                        output("Downloading Wyrmstooth...")
                        Invoke-WebRequest -Uri "https://archive.org/download/Wyrmstooth1.17B/Wyrmstooth%201.17B.zip" -OutFile "$skyrimPath\US\Downloads\Wyrmstooth 1.17B.zip"
                        output("Downloaded Wyrmstooth")

                    }else{output("NVAC and Wyrmstooth already installed")}
        
                    output("Getting VideoMemory")
                    [Windows.Forms.MessageBox]::Show("Please enter your RAM amount and VRAM amount in the next window.","Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
                    $configFormGetRam = New-Object System.Windows.Forms.Form
                        $configFormGetRam.Width = 300
                        $configFormGetRam.Height = 110
                        $configFormGetRam.Text = "Ultimate Skyrim Installation"
                        $configFormGetRam.Icon = $Icon
                        $getRAM = New-Object System.Windows.Forms.TextBox
                            $getRAM.Text = "Enter RAM in megabytes here"
                            $getRAM.Top = 10
                            $getRAM.Left = 10
                            $getRAM.Size = New-Object System.Drawing.Size(150,25)
                            $getRAM.add_TextChanged(
                            {
                                # Check if Text contains any non-Digits
                                if($getRAM.Text -match '\D'){
                                    # If so, remove them
                                    $getRAM.Text = $getRAM.Text -replace '\D'
                                    # If Text still has a value, move the cursor to the end of the number
                                    if($getRAM.Text.Length -gt 0){
                                        $getRAM.Focus()
                                        $getRAM.SelectionStart = $getRAM.Text.Length
                                    }
                                }
                            })
                            $configFormGetRam.Controls.Add($getRAM)
                        $getVRAM = New-Object System.Windows.Forms.TextBox
                            $getVRAM.Text = "Enter VRAM in megabytes here"
                            $getVRAM.Top = 40
                            $getVRAM.Left = 10
                            $getVRAM.Size = New-Object System.Drawing.Size(150,25)
                            $getVRAM.add_TextChanged(
                            {
                                # Check if Text contains any non-Digits
                                if($getVRAM.Text -match '\D'){
                                    # If so, remove them
                                    $getVRAM.Text = $getVRAM.Text -replace '\D'
                                    # If Text still has a value, move the cursor to the end of the number
                                    if($getVRAM.Text.Length -gt 0){
                                        $getVRAM.Focus()
                                        $getVRAM.SelectionStart = $getVRAM.Text.Length
                                    }
                                }
                            })
                            $configFormGetRAM.Controls.Add($getVRAM)
                        $confirmRAM = New-Object System.Windows.Forms.Button
                            $confirmRAM.Text = "Confirm"
                            $confirmRAM.Top = 39
                            $confirmRAM.Left = 165
                            $confirmRAM.ADD_CLICK(
                            {
                                $RAM = [int]$getRAM.Text
                                $VRAM = [int]$getVRAM.Text
                                if($RAM -lt 4096)
                                {
                                    [Windows.Forms.MessageBox]::Show("You may not have enough RAM to run Ultimate Skyrim! Proceed at your own risk.","Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Error)
                                }
                                if($VRAM -lt 4096)
                                {
                                    [Windows.Forms.MessageBox]::Show("You may not have enough VRAM to run Ultimate Skyrim! Proceed at your own risk.","Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Error)
                                }
                                $videoMem = "Video Memory: " + (($RAM + $VRAM) - 2048) + " MB"
                                $configFormVideoMemory.Text = $videoMem
                                if($videoMem -le 12288){$recSpec = "Low";$PresetIndex = 0}
                                if($videoMem -lt 22528 -and $videoMem -gt 12288){$recSpec = "Medium";$PresetIndex = 1}
                                if($videoMem -ge 22528){$recSpec = "High";$PresetIndex = 2}
                                [Windows.Forms.MessageBox]::Show("Your recommended ENB preset is $recSpec.","Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
                                output("Setting ENB preset")
                                $configFormENBPreset.SelectedIndex = $PresetIndex
                                output("Setting VideoMemory in enblocal.ini")
                                (Get-Content -Path "$installerSrc\bin\enblocal.ini" -raw) -replace "INSERTRAMHERE",(($RAM + $VRAM) - 2048) | Set-Content "$skyrimPath\enblocal.ini"
                                $configFormGetRam.Close()
                            })
                            $configFormGetRam.Controls.Add($confirmRAM)
                        $configFormGetRam.ShowDialog()
                    [Windows.Forms.MessageBox]::Show("Due to the size of DynDOLOD, it must be downloaded manually. You will be directed to the download page. Please drag and drop the file into the downloads folder that will open when you hit OK","Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
                    Start-Process "https://mega.nz/#!SANlQY7R!deorWwQBDDw4GoHYfJ-7NJVOWQ1U-KsoH1HrdG4PFaI"
                    Start-Process "$skyrimPath\US\Downloads"
                    [Windows.Forms.MessageBox]::Show("Now you can run Automaton!","Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
                    output("Ready to run Automaton! Double check your settings and rerun Preinstall if you need to change something")
                    $startAutomaton.Enabled = $true
                })
                $configForm.Controls.Add($configFormPreReqsPreinstall)

            $configFormENBPreset = New-Object System.Windows.Forms.ComboBox
                $configFormENBPreset.Top = 35
                $configFormENBPreset.Left = 320
                $configFormENBPreset.Size = New-Object System.Drawing.Size(100,25)
                $configFormENBPreset.Items.Add("Low")
                $configFormENBPreset.Items.Add("Medium")
                $configFormENBPreset.Items.Add("High")
                $configForm.Controls.Add($configFormENBPreset)

            $configFormVideoMemory = New-Object System.Windows.Forms.Label
                $configFormVideoMemory.Text = "Video Memory: "
                $configFormVideoMemory.Top = 60
                $configFormVideoMemory.Left = 320
                $configFormVideoMemory.Size = New-Object System.Drawing.Size(150,25)
                $configForm.Controls.Add($configFormVideoMemory)

            $configFormENBLabel = New-Object System.Windows.Forms.Label
                $configFormENBLabel.Text = "ENB Preset"
                $configFormENBLabel.Top = 10
                $configFormENBLabel.Left = 320
                $configForm.Controls.Add($configFormENBLabel)

            $configFormInstallPathLabel = New-Object System.Windows.Forms.TextBox
                $configFormInstallPathLabel.Text = "Install Path: $skyrimPath\US"
                $configFormInstallPathLabel.Top = 100
                $configFormInstallPathLabel.Left = 320
                $configFormInstallPathLabel.Size = New-Object System.Drawing.Size(400,25)
                $configFormInstallPathLabel.ReadOnly = $true 
                $configForm.Controls.Add($configFormInstallPathLabel)

            $configFormDownloadPathLabel = New-Object System.Windows.Forms.TextBox
                $configFormDownloadPathLabel.Text = "Download Path: $skyrimPath\US\Downloads"
                $configFormDownloadPathLabel.Top = 135
                $configFormDownloadPathLabel.Left = 320
                $configFormDownloadPathLabel.Size = New-Object System.Drawing.Size(400,25)
                $configFormDownloadPathLabel.ReadOnly = $true 
                $configForm.Controls.Add($configFormDownloadPathLabel)

            $startAutomaton = New-Object System.Windows.Forms.Button
                $startAutomaton.Enabled = $false
                $startAutomaton.Text = "Run Automaton"
                $startAutomaton.Top = 170
                $startAutomaton.Left = 320
                $startAutomaton.Size = New-Object System.Drawing.Size(400,25)
                $startAutomaton.ADD_CLICK(
                {
                    output("Running Automaton")
                    Start-Process "$installerSrc\bin\automaton\Automaton.exe"
                    [Windows.Forms.MessageBox]::Show("When Automaton launches, select either Keyboard or Gamepad from $skyrimPath\US and then copy the install and download paths into their respective fields.`r`nAllow Automaton to access your Nexus account and handle NXM links (required). If you are a Nexus premium member, Automaton can download each mod for you automatically by clicking on the switch at the top.`r`nOtherwise, click on the box with the arrow inside next to each mod to go to the download page. You can hover over the mod's name in Automaton to see which specific file needs to be downloaded.`r`nAfter all of the mods have been downloaded, click on 'Install modpack.' After Automaton finishes installing the mods, close it to continue the install process.","Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
                    $automatonIsRunning = $true
                    while($automatonIsRunning)
                    {
                        if(!(Get-Process | Where-Object ProcessName -eq "Automaton"))
                        {
                            $automatonIsRunning = $false
                        }
                    }
                    $automatonSuccess = [Windows.Forms.MessageBox]::Show("Did Automaton complete? If it crashed, select no.","Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::YesNo, [Windows.Forms.MessageBoxIcon]::Information)
                    switch($automatonSuccess)
                    {
                        "Yes"
                        {
                            output("Configuring ENB")
                            $folderName = (Get-ChildItem -Path "$skyrimPath\US" | Where-Object Name -like "US*" | Where-Object Attributes -eq "Directory").Name -replace "\\",""
                            $configFormENBPreset.Enabled = $false
                            Copy-Item -Path "$installerSrc\ini\$($configFormENBPreset.SelectedIndex)\Skyrim.ini" -Destination "$skyrimPath\US\$folderName\profiles\$folderName\Skyrim.ini" -Force
                            Copy-Item -Path "$installerSrc\ini\$($configFormENBPreset.SelectedIndex)\SkyrimPrefs.ini" -Destination "$skyrimPath\US\$folderName\profiles\$folderName\SkyrimPrefs.ini" -Force
                            Remove-Item -Path "$skyrimPath\US\$folderName\mods\Snowfall Weathers\ENB Files - empty into Skyrim Directory\enblocal.ini" -ErrorAction SilentlyContinue
                            foreach($file in (Get-ChildItem "$skyrimPath\US\$folderName\mods\Snowfall Weathers\ENB Files - empty into Skyrim Directory"))
                            {
                                Copy-Item -Path $file.FullName -Destination "$skyrimPath" -Force
                            }
                            foreach($file in (Get-ChildItem "$installerSrc\ENB"))
                            {
                                Copy-Item -Path $file.FullName -Destination "$skyrimPath" -Force
                            }
                            output("Starting ModOrganizer to create ini")
                            [Windows.Forms.MessageBox]::Show("ModOrganizer will launch and then close. Do not touch your mouse or keyboard. Click ok to any pop-ups","Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
                            Start-Process "$skyrimPath\US\$folderName\ModOrganizer.exe"
                            Start-Sleep -Seconds 10
                            Stop-Process -Name ModOrganizer
                            [Windows.Forms.MessageBox]::Show("The installer will now clean your DLC. Just dismiss the developer message, or any error messages that pop up. The DLC should still get cleaned","Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
                            $modOrganizerIni = (Get-Content -Path "$skyrimPath\US\$folderName\ModOrganizer.ini")
                            foreach($line in $modOrganizerIni)
                            {
                                if($line -like "size=*")
                                {
                                    $temp = [int]($line -replace "size=","")
                                    if($temp -gt 0){$numberOfEXE = $temp}
                                }
                            }
                            $DLCList = "Update","Dawnguard","Dragonborn","Hearthfires"
                            $newEXEs = ""
                            $i = $numberOfEXE + 1
                            $DLCPATH = $skyrimPath -replace '\\',"/"
                            foreach($DLC in $DLCList)
                            {
                                $newEXEs = $newEXEs + "$i\title=Clean $DLC`r`n$i\toolbar=false`r`n$i\ownicon=true`r`n$i\binary=$DLCPATH/US/Utilities/TES5Edit.exe`r`n$i\arguments=`"-autoexit -quickautoclean -autoload $DLC.esm`"`r`n$i\workingDirectory=$DLCPATH/US/$folderName/`r`n$i\steamAppID=`r`n"
                                $i++
                            }
                            $newEXEs = $newEXEs + "size=$($i-1)"
                            (Get-Content -Path "$skyrimPath\US\$folderName\ModOrganizer.ini" -Raw) -replace "size=$numberOfEXE",$newEXEs | Set-Content -Path "$skyrimPath\US\$folderName\ModOrganizer.ini"
                            (Get-Content -Path "$skyrimPath\US\$folderName\ModOrganizer.ini" -Raw) + "[Settings]`r`nlanguage=en`r`noverwritingLooseFilesColor=@Variant(\0\0\0\x43\x1@@\xff\xff\0\0\0\0\0\0)`r`noverwrittenLooseFilesColor=@Variant(\0\0\0\x43\x1@@\0\0\xff\xff\0\0\0\0)`r`noverwritingArchiveFilesColor=@Variant(\0\0\0\x43\x1@@\xff\xff\0\0\xff\xff\0\0)`r`noverwrittenArchiveFilesColor=@Variant(\0\0\0\x43\x1@@\0\0\xff\xff\xff\xff\0\0)`r`ncontainsPluginColor=@Variant(\0\0\0\x43\x1@@\0\0\0\0\xff\xff\0\0)`r`ncontainedColor=@Variant(\0\0\0\x43\x1@@\0\0\0\0\xff\xff\0\0)`r`ncompact_downloads=false`r`nmeta_downloads=false`r`nuse_prereleases=false`r`ncolorSeparatorScrollbars=true`r`nlog_level=1`r`ncrash_dumps_type=1`r`ncrash_dumps_max=5`r`noffline_mode=false`r`nuse_proxy=false`r`nendorsement_integration=true`r`nhide_api_counter=false`r`nload_mechanism=0`r`nhide_unchecked_plugins=false`r`nforce_enable_core_files=true`r`ndisplay_foreign=true`r`nlock_gui=false`r`narchive_parsing_experimental=false`r`n`r`n[pluginBlacklist]`r`n1\name=plugin_python.dll`r`nsize=1" | Set-Content -Path "$skyrimPath\US\$folderName\ModOrganizer.ini"
                            foreach($DLC in $DLCList)
                            {
                                Start-Process "$skyrimPath\US\$folderName\ModOrganizer.exe" -ArgumentList "-p `"$folderName`" `"moshortcut://:Clean $DLC`""
                                output("Cleaning $DLC.esm")
                                Start-Sleep -seconds 10
                            }
                            while(Get-Process | Where-Object -Property ProcessName -eq "TES5Edit"){Start-Sleep -seconds 5}
                            if($folderName -like "*Gamepad*"){Remove-Item $skyrimPath\ControlMap_Custom.txt -Force}
                            $WshShell = New-Object -comObject WScript.Shell
                            $Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Ultimate Skyrim.lnk")
                            $targetPath = "`"$skyrimPath\US\$folderName\ModOrganizer.exe`""
                            $Shortcut.Arguments = "-p `"$folderName`" `"moshortcut://:SKSE`""
                            $Shortcut.TargetPath = $targetPath
                            $shortcut.IconLocation="$skyrimPath\TESV.exe"
                            $Shortcut.Save()
                            $postCompletion = [Windows.Forms.MessageBox]::Show("Congratulations! Ultimate Skyrim is installed and a shortcut has been created on your desktop! Would you like to launch Ultimate Skyrim now?","Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::YesNo, [Windows.Forms.MessageBoxIcon]::Exclamation)
                            switch($postCompletion)
                            {
                                "Yes"
                                {
                                    Start-Process "`"$skyrimPath\US\$folderName\ModOrganizer.exe`"" -ArgumentList "-p `"$folderName`" `"moshortcut://:SKSE`""
                                    $configForm.Close()
                                }
                                "No"
                                {
                                    $postCompletionNO = [Windows.Forms.MessageBox]::Show("Would you like to quit the installer?","Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::YesNo, [Windows.Forms.MessageBoxIcon]::Exclamation)
                                    if($postCompletionNO -eq "Yes"){$configForm.Close()}
                                }
                            }
                        }
                        "No"
                        {
                            [Windows.Forms.MessageBox]::Show("Restart Automaton and try again. If it crashes continuously, seek support in the Discord or on Reddit.","Ultimate Skyrim Install", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Information)
                        }
                    }
                })
                $configForm.Controls.Add($startAutomaton)

    $configForm.ShowDialog()
