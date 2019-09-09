#This script created by JimmyLi
#Last update 2019/09/09
<#
此脚本函数用来统计vCenter下宿主机所在的群集、服务器厂商、型号、服务器序列号、主机名称、CPU信息、内存信息等，返回一个数据集
#>
Function Lisingle-Get-VMhost() {
    $result = @()
    Get-Cluster | ForEach-Object {
        $clustername = $_.Name
        Get-VMHost -Location $clustername | ForEach-Object {
            $vmhostname = $_    #服务器名称
            $esxcli = Get-EsxCli -V2 -VMHost $vmhostname
            $platform = $esxcli.hardware.platform.get.Invoke()
            $ServerVendor = $platform.VendorName   #服务器厂商
            $ServerModel = $platform.ProductName    #服务器型号
            $ServerSN = $platform.SerialNumber    #服务器序列号
            $vmhost = Get-VMHost -Name $vmhostname
            $vmhost_view = Get-VMHost -Name $vmhostname | Get-View
            $cpu_phy_count = $vmhost_view.Hardware.CpuInfo.NumCpuPackages    #物理CPU个数
            $cpu_Cores = $vmhost_view.Hardware.CpuInfo.NumCpuCores    #CPU核心总数
            $mem_phy_GB = $vmhost.MemoryTotalGB   #物理内存总量GB
            $mem_used_GB = $vmhost.MemoryUsageGB
            $cpu_phy_Mhz = $vmhost.CpuTotalMhz
            $cpu_used_Mhz = $vmhost.CpuUsageMhz
            $cpu_usage = [math]::Round($cpu_used_Mhz/$cpu_phy_Mhz,4)    #CPU利用率
            $mem_usage = [math]::Round($mem_used_GB/$mem_phy_GB,4)    #内存利用率
            $result += "" | select @{N="集群名称";E={$clustername}},@{N="服务器厂商";E={$ServerVendor}},@{N="服务器型号";E={$ServerModel}},
            @{N="序列号";E={$ServerSN}},@{N="主机名称";E={$vmhostname}},@{N="CPU个数";E={$cpu_phy_count}},@{N="CPU核心数";E={$cpu_Cores}},@{N="CPU主频资源Mhz";E={$cpu_phy_Mhz}},@{N="CPU利用率";E={$cpu_usage}},
            @{N="内存总量GB";E={[math]::Round($mem_phy_GB,0)}},@{N="内存利用率";E={$mem_usage}}
        }
    }
    return $result
}
