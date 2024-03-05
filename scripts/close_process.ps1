param(
    [string]$processName
)

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class User32 {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

    [DllImport("user32.dll")]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);

    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
}
"@

$WM_CLOSE = 0x0010
$process = Get-Process | Where-Object { $_.ProcessName -like $processName } | Select-Object -First 1

if ($process) {
    $processId = $process.Id


$callback = {
    param([IntPtr]$hWnd, [IntPtr]$lParam)
    
    $windowProcessId = 0
    [User32]::GetWindowThreadProcessId($hWnd, [ref]$windowProcessId)
    
    # IntPtrをintにキャストし、その後uint32にキャストして比較
    $lParamInt = [int]$lParam
    $lParamUInt = [uint32]$lParamInt
    
    if ($windowProcessId -eq $lParamUInt) {
        [User32]::SendMessage($hWnd, $WM_CLOSE, [IntPtr]::Zero, [IntPtr]::Zero) | Out-Null
    }
    
    return $true
}
    
    # EnumWindowsProcに対してスクリプトブロックをキャスト
    $enumWindowsProc = $callback -as [User32+EnumWindowsProc]
    
    [User32]::EnumWindows($enumWindowsProc, [IntPtr]$processId) | Out-Null
}
