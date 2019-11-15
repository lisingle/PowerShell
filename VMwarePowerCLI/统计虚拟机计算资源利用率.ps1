#This Script Created by Jimmy Li
#此脚本用来统计虚拟机的CPU和内存利用率情况；输入需要统计的天数（已当前时间为截止时间）
#Last update 2019/11/15
$area = "区域标识"
$days = Read-Host "请输入统计天数"
$end_time = Get-Date
$start_time = (Get-Date).AddDays(-$days)
$result = @()
$days += "日内"
$timestamp = [string]((Get-Date).Year) + [string]((Get-Date).Month) + [string]((Get-Date).Day) + [string]((Get-Date).Hour) + [string]((Get-Date).Minute)
Get-VM | Where-Object PowerState -EQ 'PoweredOn' | ForEach-Object {
    $vm = $_
    $cpu_usage = Get-Stat -Entity $vm -Start $start_time -Finish $end_time -Stat cpu.usage.average -ErrorAction SilentlyContinue | Measure-Object -Property Value -Maximum -Minimum -Average
    $mem_usage = Get-Stat -Entity $vm -Start $start_time -Finish $end_time -Stat mem.usage.average -ErrorAction SilentlyContinue | Measure-Object -Property Value -Maximum -Minimum -Average
    $max_cpu_usage = [string][math]::Round($cpu_usage.Maximum,2) + '%'
    $min_cpu_usage = [string][math]::Round($cpu_usage.Minimum,2) + '%'
    $average_cpu_usage = [string][math]::Round($cpu_usage.Average,2) + '%'
    $max_mem_usage = [string][math]::Round($mem_usage.Maximum,2) + '%'
    $min_mem_usage = [string][math]::Round($mem_usage.Minimum,2) + '%'
    $average_mem_usage = [string][math]::Round($mem_usage.Average,2) + '%'
    $vmname = $vm.Name
    $vmcpu = $vm.NumCpu
    $vmmem = $vm.MemoryGB
    $vmdisk = [math]::Round($vm.ProvisionedSpaceGB,2)
    $vmip = $vm.Guest.IPAddress | where {([IPAddress]$_).AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork}
    $usage_result = "" | select @{N="区域“;E={$area}},@{N="虚机名称“;E={$vmname}},@{N="核心数“;E={$vmcpu}},@{N="内存GB“;E={$vmmem}},@{N="磁盘GB“;E={$vmdisk}},@{N="IP地址“;E={$vmip}},
    @{N="最高CPU利用率（$days）“;E={$max_cpu_usage}},@{N="最低CPU利用率（$days）“;E={$min_cpu_usage}},@{N="平均CPU利用率（$days）“;E={$average_cpu_usage}},
    @{N="最高内存利用率（$days）“;E={$max_mem_usage}},@{N="最低内存利用率（$days）“;E={$min_mem_usage}},@{N="平均内存利用率（$days）“;E={$average_mem_usage}}
    $result += $usage_result
}
$result | Export-Csv $area"虚拟机计算资源利用率统计"$timestamp".csv" -Encoding UTF8
