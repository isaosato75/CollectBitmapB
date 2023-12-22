@start powershell.exe -windowstyle hidden -noprofile "$me = '%~f0';. ([scriptblock]::create((gc -li $me|select -skip 1|out-string)))" %*&goto:eof
<#
.SYNOPSIS
�N���b�v�{�[�h���Ď����A�r�b�g�}�b�v�摜���R�s�[���ꂽ�Ƃ��Ɏ����I�ɕۑ����܂��B
.DESCRIPTION
�N���b�v�{�[�h���Ď����A�r�b�g�}�b�v�摜���R�s�[���ꂽ�Ƃ��Ɏ����I�ɕۑ����܂��B
�摜�̕ۑ���́A����ł̓X�N���v�g �t�@�C���Ɠ����t�H���_�[�ɕۑ�����܂��B�X�N���v�g���s���̈����Ŏw�肷�邩�AXML �ݒ�t�@�C���ŕۑ�����w��ł��܂��BXML �ݒ�t�@�C���ɂ��ẮA-Full ���w�肵�ăw���v��\�����Ă��������B

�u�e�L�X�g�v�Ɓu�摜�v�̗������܂ރf�[�^���R�s�[���ꂽ�Ƃ��́A�ۑ����܂���B
�Ⴆ�� Excel �ŃZ�����R�s�[�����Ƃ��A�e�L�X�g�̕`���ꂽ�}���R�s�[����܂����A�����ɏ����t���e�L�X�g�⏑���Ȃ��e�L�X�g�AExcel �`���̃Z���Q�ƂȂǂ��R�s�[����A�\��t�����鑤�͂��ꂼ��̌`���̃f�[�^�����o���邱�Ƃ��ł��܂��B
���̂悤�ɁA�u�摜�v�Ɓu�e�L�X�g�v�̗������܂ޏ��͕ۑ����܂���B
�܂��A�x�N�g���}�i���^�t�@�C���`���j���ۑ����܂���B

collectbitmap.ps1xml �t�@�C�����쐬���A������J�X�^�}�C�Y�ł��܂��B
PS1XML ��`�t�@�C���́A�Ⴆ�� PowerShell �ɂĎ��̗v�̂ō쐬�ł��܂��B
PS> @{
>> SavePath = {Split-Path $me -Parent}
>> FileName = {'{1:yyyyMMdd_HHmmssff}_{0}.png' -f $env:COMPUTERNAME, $captureddatetime}
>> Printing       = $true
>> PrintingFont   = 'Consolas'
>> PrintingSize   = 75
>> PrintingString = {"{1:d} {1:HH:mm:ss.ff}`r`n{0}" -f $env:COMPUTERNAME, $captureddatetime}
>> } | Export-CliXml collectbitmap.ps1xml
SavePath �ɂ͕ۑ���t�H���_�[��Ԃ��X�N���v�g �u���b�N���w�肵�܂��B����͋N�����Ɉ�x�����]������܂��B
FileName �ɂ͕ۑ�����摜�t�@�C������Ԃ��X�N���v�g �u���b�N���w�肵�܂��B����͐}��ۑ����閈�ɕ]������܂��B
�����ꂩ�̒l���ȗ����邱�Ƃ��ł��܂��B�ȗ������l�̓X�N���v�g�̋K��l���p�����܂��B
.NOTES
Bitmap collector batch version 1.00

MIT License

Copyright (c) 2023 Isao Sato

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#>

################################################################
# bitmap collector batch
################################
# 2023/12/22
################################################################

param($SaveFolder)

Set-StrictMode -Version 2
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

[Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

try {
filter Verify-AuthenticodeSignature([Parameter(Mandatory=$true, ValueFromPipeline=$true)] [string] $LiteralPath, [switch] $Force) {
    [bool] $Result = $false
    $exception = $null
    $private:ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    
    $cert = Get-AuthenticodeSignature -LiteralPath $LiteralPath
    
    if($cert -eq $null) {
        throw (New-Object System.ArgumentException ('�t�@�C�� {0} �̓f�W�^�����������؂ł��܂���B�B' -f $LiteralPath), (New-Object System.UnauthorizedAccessException))
    }
    
    switch($cert) {
        {$cert.Status -eq [System.Management.Automation.SignatureStatus]::Valid} {
            if((Test-Path (Join-Path cert:\CurrentUser\TrustedPublisher ($cert.SignerCertificate.Thumbprint)))) {
                $Result = $true
            } else {
                if((Test-Path (Join-Path cert:\LocalMachine\TrustedPublisher ($cert.SignerCertificate.Thumbprint)))) {
                    $Result = $true
                } elseif((Test-Path (Join-Path cert:\CurrentUser\TrustedPublisher ($cert.SignerCertificate.Thumbprint)))) {
                    $Result = $true
                } else {
                    $exception = New-Object System.Management.Automation.PSSecurityException ('�t�@�C�� {0} �̃f�W�^�������̔��s���͐M������Ă܂���B���̃X�N���v�g�̓V�X�e���Ŏ��s����܂���B' -f $LiteralPath), (New-Object System.UnauthorizedAccessException)
                }
            }
        }
        {$cert.Status -eq [System.Management.Automation.SignatureStatus]::NotSigned} {
            $exception = New-Object System.Management.Automation.PSSecurityException ('�t�@�C�� {0} �̓f�W�^����������Ă��܂���B���̃X�N���v�g�̓V�X�e���Ŏ��s����܂���B' -f $LiteralPath), (New-Object System.UnauthorizedAccessException)
        }
        {$cert.Status -eq [System.Management.Automation.SignatureStatus]::UnknownError} {
            $exception = New-Object System.ArgumentException ('�t�@�C�� {0} �̓f�W�^�����������؂ł��܂���B�B' -f $LiteralPath), (New-Object System.UnauthorizedAccessException)
        }
        {$cert.Status -eq [System.Management.Automation.SignatureStatus]::NotSupportedFileFormat} {
            $exception = New-Object System.ArgumentException ('�t�@�C�� {0} �̓f�W�^�����������؂ł��܂���B�B' -f $LiteralPath), (New-Object System.UnauthorizedAccessException)
        }
        default {
            $exception = New-Object System.Management.Automation.PSSecurityException ('�t�@�C�� {0} �̓f�W�^����������Ă��܂��������ł��B���̃X�N���v�g�̓V�X�e���Ŏ��s����܂���B' -f $LiteralPath), (New-Object System.UnauthorizedAccessException)
        }
    }
    if(-not ($exception -eq $null -or $Force)) {
        throw $exception
    }
    
    $Result
}

filter Verify-ScriptExecution([Parameter(Mandatory=$true, ValueFromPipeline=$true)] [string] $LiteralPath, [switch] $Force) {
    $private:ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    switch((Get-ExecutionPolicy)) {
        {$_ -eq [Microsoft.PowerShell.ExecutionPolicy]::Unrestricted} {
            $true
        }
        {$_ -eq [Microsoft.PowerShell.ExecutionPolicy]::Bypass} {
            $true
        }
        {$_ -eq [Microsoft.PowerShell.ExecutionPolicy]::RemoteSigned} {
            if(([uri] $LiteralPath).IsUnc) {
                Verify-AuthenticodeSignature $LiteralPath -Force:$Force
            }
        }
        {$_ -eq [Microsoft.PowerShell.ExecutionPolicy]::AllSigned} {
            Verify-AuthenticodeSignature $LiteralPath -Force:$Force
        }
        default {
            if(-not $Force) {
                throw New-Object System.Management.Automation.PSSecurityException ('�X�N���v�g�̎��s���V�X�e���Ŗ����ɂȂ��Ă��邽�߁A�t�@�C�� {0} ��ǂݍ��߂܂���B' -f $LiteralPath), (New-Object System.UnauthorizedAccessException)
            }
            $false
        }
    }
}




################################
# the major logic
################################

function private:Enter-BitmapCapture([System.Collections.Hashtable] $xconf) {
    
    # creating a full path for saving pictures
    
    function Get-SavePath
    {
        Join-Path $xconf['SavePath'] (Invoke-Command ([scriptblock]::Create($xconf['FileName'])))
    }

    # responsing to the event
    
    function Watch-Clipboard_OnClipboardChanged
    {
        $captureddatetime = [datetime]::Now
        [System.Windows.Forms.IDataObject] $dt = [System.Windows.Forms.Clipboard]::GetDataObject()
        if($dt.GetDataPresent([System.Windows.Forms.DataFormats]::Bitmap) -and -not $dt.GetDataPresent([System.Windows.Forms.DataFormats]::Text) -and -not $dt.GetDataPresent([System.Windows.Forms.DataFormats]::MetafilePict))
        {
            $disposepict = $null
            if($pict.Image -ne $null) {
                $disposepict = $pict.Image
                $pict.Image = $null
                $disposepict.Dispose()
            }
            
            $bmp = $dt.GetImage()
            $pict.Image = New-Object System.Drawing.Bitmap $bmp
            $pictsize = $bmp.Size
            $bmp.Dispose()
            
            if($check.Checked) {
                $printingstring = (Invoke-Command ([scriptblock]::Create($xconf['PrintingString'])))
                $fontsize = $xconf['PrintingSize']
                # $fontsize = [Math]::Min($fontsize, $pict.Image.Width /15)
                # $fontsize = [Math]::Min($fontsize, $pict.Image.Height /3)
                $grp = $null
                $fontfamily = $null
                $font = $null
                $pen = $null
                $drawpath = $null
                try {
                    $grp = [System.Drawing.Graphics]::FromImage($pict.Image)
                    $fontfamily = New-Object System.Drawing.FontFamily $xconf['PrintingFont']
                    $font = New-Object System.Drawing.Font $fontfamily, $fontsize
                    $measuredsize = $grp.MeasureString($printingstring, $font)
                    $fontsizescale = 1.0
                    if($measuredsize.Width -gt $pictsize.Width) {
                        $fontsizescale = [Math]::Min($fontsizescale, ($pictsize.Width / $measuredsize.Width))
                    }
                    if($measuredsize.Height -gt $pictsize.Height) {
                        $fontsizescale = [Math]::Min($fontsizescale, ($pictsize.Height / $measuredsize.Height))
                    }
                    $fontsize = [int] ($fontsize * $fontsizescale)
                    $pen = New-Object System.Drawing.Pen ([System.Drawing.Brushes]::Black), 4
                    $drawpath = New-Object System.Drawing.Drawing2D.GraphicsPath
                    $drawpath.AddString(
                        $printingstring,
                        $fontfamily,
                        [int][System.Drawing.FontStyle]::Regular,
                        $fontsize,
                        (New-Object System.Drawing.Point 0, 0),
                        ([System.Drawing.StringFormat]::GenericDefault))
                    $grp.DrawPath($pen, $drawpath)
                    $grp.FillPath([System.Drawing.Brushes]::White, $drawpath)
                }finally{
                    if($drawpath){$drawpath.Dispose()}
                    if($pen){$pen.Dispose()}
                    if($font){$font.Dispose()}
                    if($fontfamily){$fontfamily.Dispose()}
                    if($grp){$grp.Dispose()}
                }
            }
            
            $path = Get-SavePath
            
            $mimetype = "image/png"
            $encparams = $null
            # �掿80/100�� JPEG �摜�ɂ���ꍇ�̗�
            # $mimetype = "image/jpeg"
            # $encparams = New-Object System.Drawing.Imaging.EncoderParameters -ArgumentList 1
            # $encparams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter -ArgumentList @([System.Drawing.Imaging.Encoder]::Quality, [System.Int64] 80)
            
            $codecinfo = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object {$_.MimeType -eq $mimetype} | Select-Object -First 1
            $pictext = [System.IO.Path]::GetExtension($codecinfo.FilenameExtension.Split(';')[0])
            
            $pict.Image.Save(
                [System.IO.Path]::ChangeExtension($path, $pictext),
                $codecinfo,
                $encparams)
        }
    }
    
    # main
    
    $check = New-Object System.Windows.Forms.CheckBox
    $check.Text = '�e�L�X�g�����v�����g����'
    $check.Dock = [System.Windows.Forms.DockStyle]::Top
    $check.BackColor = [System.Drawing.Color]::Transparent
    $check.Checked = $xconf['Printing']
    
    $label = New-Object System.Windows.Forms.Label
    $label.Text = "�R�s�[�����r�b�g�}�b�v�摜��ۑ����܂��B`n�ۑ���F`n" +$xconf['SavePath']
    $label.Dock = [System.Windows.Forms.DockStyle]::Fill
    $label.BackColor = [System.Drawing.Color]::Transparent
    
    $pict = New-Object System.Windows.Forms.PictureBox
    $pict.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
    $pict.Dock = [System.Windows.Forms.DockStyle]::Fill
    
    $pict.Controls.Add($check)
    $pict.Controls.Add($label)
    
    $watcher = New-Object ClipboardWatcher
    $watcher.Text = "�r�b�g�}�b�v���W"
    $watcher.Controls.Add($pict)
    $watcher.Add_ClipboardChanged(${function:Watch-Clipboard_OnClipboardChanged})
    
    [System.Windows.Forms.Application]::Run($watcher)
}


################################
# definitions handlers for window messages
################################

if([psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get['ClipboardWatcher'] -eq $null) {
    Add-Type -ReferencedAssemblies System.Windows.Forms -TypeDefinition @"
    using System;
    using System.Windows.Forms;
    using System.Runtime.InteropServices;
    
    namespace NASsystems.ClipboardWatching
    {
        public class ClipboardWatcher : Form
        {
            public ClipboardWatcher()
            {
                this.HandleCreated += new EventHandler(this.ClipboardWatcher_OnHandleCreated);
                this.HandleDestroyed += new EventHandler(this.ClipboardWatcher_OnHandleDestroyed);
            }
            
            public event EventHandler ClipboardChanged;
            
            protected void JoinClipboardChain()
            {
                try
                {
                    AddClipboardFormatListener(this.Handle);
                }
                catch
                {
                    // ��O���� AddClipboardFormatListener �����݂��Ȃ������i�� NT60 �ȑO�j�Ɖ��肷��B
                    nextHandle = SetClipboardViewer(this.Handle);
                }
            }
            
            protected void DefectClipboardChain()
            {
                try
                {
                    RemoveClipboardFormatListener(this.Handle);
                }
                catch
                {
                    // ��O���� RemoveClipboardFormatListener �����݂��Ȃ������i�� NT60 �ȑO�j�Ɖ��肷��B
                    bool sts = ChangeClipboardChain(this.Handle, nextHandle);
                }
            }
            
            protected override void WndProc(ref Message msg)
            {
               switch(msg.Msg)
               {
                case WM_CLIPBOARDUPDATE:
                    // for NT6.0 or later
                    RaiseClipboardChanged();
                    break;
                case WM_DRAWCLIPBOARD:
                    // for earlier than NT6.0
                    RaiseClipboardChanged();
                    if(nextHandle != IntPtr.Zero)
                        SendMessage(nextHandle, msg.Msg, msg.WParam, msg.LParam);
                    return;
                case WM_CHANGECBCHAIN:
                    // for earlier than NT6.0
                    if(msg.WParam == nextHandle)
                    {
                        nextHandle = (IntPtr)msg.LParam;
                    }
                    else
                    {
                        if(nextHandle != IntPtr.Zero)
                            SendMessage(nextHandle, msg.Msg, msg.WParam, msg.LParam);
                    }
                    return;
                }
                base.WndProc(ref msg);
            }
            
            protected const int WM_CLIPBOARDUPDATE = 0x031D;
            protected const int WM_DRAWCLIPBOARD   = 0x0308;
            protected const int WM_CHANGECBCHAIN   = 0x030D;
            
            [DllImport("user32.dll", SetLastError=true)]
            protected static extern bool AddClipboardFormatListener(IntPtr hwnd);
            
            [DllImport("user32.dll", SetLastError=true)]
            protected static extern bool RemoveClipboardFormatListener(IntPtr hwnd);
            
            [DllImport("user32")]
            protected static extern IntPtr SetClipboardViewer(IntPtr hWndNewViewer);
            
            [DllImport("user32")]
            protected static extern bool ChangeClipboardChain(IntPtr hWndRemove, IntPtr hWndNewNext);
            
            [DllImport("user32")]
            protected extern static int SendMessage(IntPtr hWnd, int Msg, IntPtr wParam, IntPtr lParam);
            
            private IntPtr nextHandle;
            
            private void ClipboardWatcher_OnHandleCreated(object sender, EventArgs args)
            {
                JoinClipboardChain();
            }
            
            private void ClipboardWatcher_OnHandleDestroyed(object sender, EventArgs args)
            {
                DefectClipboardChain();
            }
            
            private void RaiseClipboardChanged()
            {
                if(ClipboardChanged != null)
                    ClipboardChanged(this, new EventArgs());
            }
        }
    }
"@
    [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Add('ClipboardWatcher',[NASsystems.ClipboardWatching.ClipboardWatcher])
}


################################
# entry
################################

# �X�N���v�g �t�@�C���Ɠ����� PS1XML �t�@�C������������ǂݍ���
# �ݒ�t�@�C�������݂��Ȃ��ꍇ�A��̍\�������\�z����B
[System.IO.Path]::ChangeExtension($me, '.ps1xml') |% {
    if(Test-Path $_) {
        Verify-ScriptExecution $_ | Out-Null
        $xconf = Import-CliXml $_
    } else {
        $xconf = @{}
    }
}

# $xconf �̖���`�̊e�v�f�Ɋ���̍\�������\�z����B
if($null -eq $xconf['SavePath']) {
    $xconf['SavePath'] = {Split-Path $me -Parent}
}

if($null -eq $xconf['FileName']) {
    $xconf['FileName'] = {'{1:yyyyMMdd_HHmmssff}_{0}.png' -f $env:COMPUTERNAME, $captureddatetime}
}

if($null -eq $xconf['PrintingString']) {
    $xconf['PrintingString'] = {"{1:d} {1:HH:mm:ss.ff}`r`n{0}" -f $env:COMPUTERNAME, $captureddatetime}
}

if($null -eq $xconf['PrintingFont']) {
    $xconf['PrintingFont'] = 'Consolas'
}

if($null -eq $xconf['PrintingSize']) {
    $xconf['PrintingSize'] = 75
}

if($null -eq $xconf['Printing']) {
    $xconf['Printing'] = $false
}


# �ۑ���p�X����������
if($null -eq $SaveFolder -or [string]::IsNullOrEmpty($SaveFolder.ToString())) {
    $xconf['SavePath'] = Invoke-Command ([scriptblock]::Create($xconf['SavePath']))
} else {
    $xconf['SavePath'] = $SaveFolder.ToString()
}

$xconf['SavePath'] |? {-not(Test-Path $_)} |% {mkdir $_} |% {'�ۑ��� {0} ���쐬���܂����B' -f $_.FullName}

# ��_���Ăяo��
# STA �̎��s�����\�z���Ď�_�����Ăяo���B

$is = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
$is.ApartmentState = [System.Threading.ApartmentState]::STA
$is.Variables.Add((New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry 'me', $me, 'the script filename', Constant))

$rs = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace($host, $is)
$rs.ApartmentState = [System.Threading.ApartmentState]::STA
$rs.Open() | Out-Null

$ps = [System.Management.Automation.PowerShell]::Create()
$ps.Runspace = $rs

$ps.AddScript(${function:Enter-BitmapCapture}) | Out-Null
$ps.AddArgument($xconf) | Out-Null

$ps.Invoke()
$ps.Streams.Error
$ps.Dispose()
} catch {
    try {
        $name = [System.IO.Path]::GetFileNameWithoutExtension($me)
    } catch {
        $name = 'collectbitmap'
    }
    [System.Windows.Forms.MessageBox]::Show($_.ToString(), $name)
}
