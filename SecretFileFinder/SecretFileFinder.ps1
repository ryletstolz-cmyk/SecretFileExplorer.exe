Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$global:selectedPath = ""

# ========== CUSTOM EXPLORER ==========
function Open-CustomExplorer {
    $global:selectedPath = ""

    $expForm = New-Object System.Windows.Forms.Form
    $expForm.Text = "Custom File Explorer"
    $expForm.Size = "560,500"
    $expForm.StartPosition = "CenterScreen"

    # Instructions
    $infoLabel = New-Object System.Windows.Forms.Label
    $infoLabel.Text = "Instructions:`n- Double-click folders to open them`n- Click a file or folder to select it`n- Use 'Up' to go back`n- Press OK to save your choice"
    $infoLabel.Location = "20,10"
    $infoLabel.Size = "520,70"

    $pathLabel = New-Object System.Windows.Forms.Label
    $pathLabel.Location = "20,90"
    $pathLabel.Size = "500,20"

    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Location = "20,120"
    $listBox.Size = "500,300"

    $okBtn = New-Object System.Windows.Forms.Button
    $okBtn.Text = "OK"
    $okBtn.Location = "240,430"
    $okBtn.Size = "100,30"

    $upBtn = New-Object System.Windows.Forms.Button
    $upBtn.Text = "Up"
    $upBtn.Location = "20,430"
    $upBtn.Size = "80,30"

    $currentPath = "C:\"
    $script:items = @()

    function Load-Folder($path){
        if(!(Test-Path $path)){ return }
        $listBox.Items.Clear()
        $pathLabel.Text = $path
        $script:items = Get-ChildItem $path -Force
        foreach($i in $script:items){
            if($i.PSIsContainer){
                $listBox.Items.Add("[Folder] " + $i.Name)
            } else {
                $listBox.Items.Add($i.Name)
            }
        }
    }

    Load-Folder $currentPath

    # Double-click to open folders
    $listBox.Add_DoubleClick({
        if($listBox.SelectedIndex -ge 0){
            $item = $script:items[$listBox.SelectedIndex]
            if($item.PSIsContainer){
                Load-Folder $item.FullName
            }
        }
    })

    # Up button
    $upBtn.Add_Click({
        $parent = Split-Path $pathLabel.Text
        if($parent){
            Load-Folder $parent
        }
    })

    # OK saves selection
    $okBtn.Add_Click({
        if($listBox.SelectedIndex -ge 0){
            $item = $script:items[$listBox.SelectedIndex]
            $global:selectedPath = $item.FullName
            $expForm.Close()
        }
    })

    $expForm.Controls.AddRange(@(
        $infoLabel,$pathLabel,$listBox,$okBtn,$upBtn
    ))
    $expForm.ShowDialog()
}

# ========== MAIN APP ==========
$form = New-Object System.Windows.Forms.Form
$form.Text = "Secret File Explorer"
$form.Size = "460,220"
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

$fileBox = New-Object System.Windows.Forms.TextBox
$fileBox.Location = "20,40"
$fileBox.Size = "300,25"
$fileBox.ReadOnly = $true

$browseBtn = New-Object System.Windows.Forms.Button
$browseBtn.Text = "Browse"
$browseBtn.Location = "330,40"
$browseBtn.Size = "80,25"

# Browse opens custom explorer
$browseBtn.Add_Click({
    Open-CustomExplorer
    if(Test-Path $global:selectedPath){
        $fileBox.Text = $global:selectedPath
        # Special Explorer jump mode
        Start-Process explorer.exe "/select,`"$global:selectedPath`""
    }
})

$form.Controls.AddRange(@($fileBox,$browseBtn))
$form.ShowDialog()
