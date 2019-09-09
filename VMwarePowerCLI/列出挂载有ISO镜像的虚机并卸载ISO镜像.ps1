#This script created by LuckyJimmy
#Last update 2019/09/08
#检查虚拟机的虚拟光驱ISO镜像挂载情况（输入参数-unmount $true或者1表示进行卸载）
Function Lisingle-Check-Cdrom {
    Param
    (
        [switch]$unmount = $false
    )
    $result = @()
    $vms = @()
    Get-VM | ForEach-Object {
        $vm = $_
        $vmname = $vm.Name
        $cddriver = Get-CDDrive -VM $_
        $IsoPath = $cddriver.IsoPath
        if ($IsoPath -ne $null)
        {
            $result += "" | select @{N="VMName";E={$vmname}},@{N="IsoPath";E={$IsoPath}}
            $vms += $vm
        }
    }
    if ($result) {
        write "如下虚拟机挂载了ISO镜像：“
        $result
        if ($unmount -eq $true)
        {
            write "`n开始卸载ISO镜像..."
            $vms | ForEach-Object {
                $vm = $_
                try
                {
                    Get-CDDrive -VM $vm | Set-CDDrive -NoMedia -Confirm:$false -ErrorAction "SilentlyContinue"
                }
                catch {}
            }
            Start-Sleep -Seconds 5
            $question = Get-VMQuestion | Where {$_.Text -like "*locked*cd-rom*"}
            if ($question) {
                $question | ForEach-Object {
                    $que = $_
                    $options = $_.Options
                    $Options | ForEach-Object {
                        if ($_.Label -like "*yes*")
                        {
                            $option = $_.Label
                            Set-VMQuestion -VMQuestion $que -Option $option -Confirm:$false -ErrorAction SilentlyContinue
                        }
                    }
                }           
            }
            write "卸载已完成！"
        }
    }
    else {
        write "没有找到挂载了ISO的虚拟机！"
    }    
}
