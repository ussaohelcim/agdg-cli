function PuxarJsonELimpar { param ($urljson)
	$sujo = Invoke-WebRequest -Uri $urljson 
	$limpo = $sujo.Content | ConvertFrom-Json
	return $limpo
}
function GetNome { 	param ( $reply )
	$_name = if($reply.trip) {$reply.name +""+ $reply.trip } else {$reply.name}
	return $_name
}
function GetFile { 	param ( $reply )
	try {
		$linkFile = "https://i.4cdn.org/vg/" + $reply.tim + $reply.ext
		$filename = if($null -eq $reply.ext) { $null } else {$reply.filename + $reply.ext +" > "+ $linkFile} 

		return $filename
	}
	catch { "error?" }
}
function GetNumeroResposta { 	param ( $reply )
	return $reply.no
}
function GetData { 	param ( $reply )
	return $reply.now
}
function GetUnixTime { 	param ( $reply )
	return $reply.time
}
function Get-WindowSize {
	return (Get-Host).UI.RawUI.WindowSize.Width
}
function RetornaComWrap { param ([string]$textoOriginal)
	[string]$novoTexto = ""
	$textoSeparado = $textoOriginal.Split([Environment]::NewLine)
	$size = Get-WindowSize
	foreach($line in $textoSeparado)
	{
		[string]$_novaLinha = ""
		[string]$_txt = $line

		if ($_txt.Length -gt $size) {

			$_palavras = $_txt.Split(' ')

			foreach($palavra in $_palavras)
			{
				[int]$_tempTxt = $_novaLinha.Length + $palavra.Length
				if($_tempTxt -gt $size)
				{
					$_novaLinha += $palavra + (Get-LetraRepetida -_letra " " -_tamanho ($size - $_tempTxt) )
				}
				else {
					$_novaLinha += $palavra + " "
				}
				
			}
		}
		$novoTexto += $_novaLinha +[Environment]::NewLine
	}
	return $novoTexto
	
}
function Get-LetraRepetida { param ($_letra,$_tamanho)
	$_r = ""

	for ($i = 0; $i -lt $_tamanho; $i++) {
		$_r += $_letra
	}
	return $_r
	
}
function EscreverNoTamanhoDaTela {	param (	$letra, $cor)
	[int]$tamanho = Get-WindowSize #(Get-Host).UI.RawUI.WindowSize.Width
	$letrinhas = ""
	for ($i = 0; $i -lt $tamanho; $i++) {
		$letrinhas += $letra
	}
	Write-Host $letrinhas -ForegroundColor $cor
}
function PrintarFio { param ( $numFio )
	$script:breadLink = "https://boards.4channel.org/vg/thread/$numFio"
	$fioJson = PuxarJsonELimpar -urljson "https://boards.4channel.org/vg/thread/$numFio.json"

	foreach($resposta in $fioJson.posts)
	{
		$nl = [System.Environment]::NewLine
        [string]$textoPuro = $resposta.com -replace '<br>',$nl
        $textoPuro = $textoPuro -replace '<br/>',$nl
        $textoPuro = $textoPuro -replace '<br />',$nl
        $textoPuro = $textoPuro -replace '</p>',$nl
        $textoPuro = $textoPuro -replace '&nbsp;',' '
        $textoPuro = $textoPuro -replace '&Auml;','Ä'
        $textoPuro = $textoPuro -replace '&auml;','ä'
        $textoPuro = $textoPuro -replace '&Ouml;','Ö'
        $textoPuro = $textoPuro -replace '&ouml;','ö'
        $textoPuro = $textoPuro -replace '&Uuml;','Ü'
        $textoPuro = $textoPuro -replace '&uuml;','ü'
        $textoPuro = $textoPuro -replace '&szlig;','ß'
        $textoPuro = $textoPuro -replace '&amp;','&'
        $textoPuro = $textoPuro -replace '&quot;','"'
        $textoPuro = $textoPuro -replace '&apos;',"'"
        $textoPuro = $textoPuro -replace '<.*?>',''
        $textoPuro = $textoPuro -replace '&gt;','>'
        $textoPuro = $textoPuro -replace '&lt;','<'
        $textoPuro = $textoPuro -replace '&#039;','´'

		$name = GetNome -reply $resposta
		$file = GetFile -reply $resposta
		$data = GetUnixTime -reply $resposta 
		$data = Get-Date -UnixTimeSeconds $data
		[string]$num = GetNumeroResposta -reply $resposta
		Write-Host $name -ForegroundColor Green -NoNewline
		Write-Host "" $data "no.$num" -NoNewline

		$quemQuotou = ""
		foreach($_resposta in $fioJson.posts)
		{
			[string]$_mensagem = $_resposta.com
			
			if($_mensagem.Contains($num))
			{
				$_num = $_resposta.no
				$quemQuotou += " >>$_num"
			}
		}
		Write-Host $quemQuotou -ForegroundColor DarkGray 

		if($file) {Write-Host $file -ForegroundColor DarkYellow}
		#Write-Host $textoPuro

		#$_teste = RetornaComWrap -textoOriginal $textoPuro

		#$linhas = $_teste.Split([Environment]::NewLine)
		$linhas = $textoPuro.Split([Environment]::NewLine)

		foreach($linha in $linhas)
		{
			[string]$txt = $linha
			

			if($txt.StartsWith('>>'))
			{
				Write-Host $txt -ForegroundColor DarkRed
			}
			elseif ($txt.StartsWith('>')) {
				
				Write-Host $txt -ForegroundColor DarkGreen
				
			}
			else {
				Write-Host $txt
			}
			
		}
		
		EscreverNoTamanhoDaTela -letra "-" -cor Red
	}
	return $fioJson
}

function BaixarTudo { param ($fio )
	foreach($r in $fio.posts)
	{
		try {
			$tim = $r.tim
			$ext = $r.ext
			[string]$nomeArquivo = "$tim$ext"
			$linkFile = "https://i.4cdn.org/vg/$nomeArquivo" 
			
			if($nomeArquivo -ne "")
			{
				Write-Host "baixando $nomeArquivo"
				Invoke-WebRequest -Uri $linkFile -OutFile $nomeArquivo 
			}
		}
		catch {	"error?" }
		 
	}
	
}
function Perguntar { 
	
	$opcao = Read-Host "'D' > download all files | 'R' > refresh | 'L' > copy bread link"
	if($opcao -eq 'd')
	{
		BaixarTudo -fio $fioAGDG
	}
	elseif ($opcao -eq 'r') {
		Main
	} elseif ($opcao -eq 'l') {
		Set-Clipboard $breadLink
		Write-Host "LINK IS NOW IN YOUR CLIPBOARD" -ForegroundColor Blue
		Write-Host "openning msedge inprivate mode..." 
		Start-Sleep -Seconds 2
		Start-Process msedge --inprivate 
	}
	else {
		Write-Host "closing..."
	}
}
function Main { 
	Clear-Host
	
	$catalogo = PuxarJsonELimpar -urljson "https://boards.4channel.org/vg/catalog.json"

	$agdg = 0

	foreach ($page in $catalogo) {
		$fios = $page.threads
		foreach ($fio in $fios) {
			[string]$general = $fio.sub
			if($general.Contains("/agdg/"))
			{
				$agdg = $fio.no
				break #
			}
		}
	}
	$script:fioAGDG = PrintarFio -numFio $agdg
	Perguntar
}

# $_teste = "teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste teste "
# $aaaa = RetornaComWrap -textoOriginal $_teste
# Write-Host $aaaa

Main 
