#Created By LuckyJimmy  2019/11/06
Function Copy-VLAN() {
    Param 
    (
        #传入如下参数：hostname表示要操作的宿主机名称，switchname表示要操作的宿主机的虚拟标准交换机的名称,vp表示需要复制到目标的虚拟端口组virtualportgroup
        $hostname,
        $switchname,
        $vp
    )
    $vswitch = Get-VMHost -Name $hostname | Get-VirtualSwitch -Name $switchname
    $vp | ForEach-Object {
        $vlantag = $_.Name
        $vlanid = $_.VLanId
        New-VirtualPortGroup -VirtualSwitch $vswitch -Name $vlantag -VLanId $vlanid -Confirm:$false
    }
}
