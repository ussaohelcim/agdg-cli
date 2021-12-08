function PuxarJsonELimpar { param ($urljson)
	$sujo = Invoke-WebRequest -Uri $urljson 
	$limpo = $sujo.Content | ConvertFrom-Json
	return $limpo
}
function GetNome { 	param ( $reply )
	return $reply.name
}
function GetFile { 	param ( $reply )
	try {
		$linkFile = "https://i.4cdn.org/vg/" + $reply.tim + $reply.ext
		$filename = if($null -eq $reply.ext) {'-'} else {$reply.filename + $reply.ext +" > "+ $linkFile} 

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
function EscreverNoTamanhoDaTela {	param (	$letra, $cor)
	[int]$tamanho = (Get-Host).UI.RawUI.WindowSize.Width
	$letrinhas = ""
	for ($i = 0; $i -lt $tamanho; $i++) {
		$letrinhas += $letra
	}
	Write-Host $letrinhas -ForegroundColor $cor
}
function PrintarFio { param ( $numFio )
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
		$num = GetNumeroResposta -reply $resposta
		Write-Host $name -ForegroundColor Green -NoNewline
		Write-Host "" $data "no.$num"
		Write-Host $file -ForegroundColor Blue
		Write-Host $textoPuro

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
	$opcao = Read-Host "D > download all files | R > refresh"
	if($opcao -eq 'd')
	{
		BaixarTudo -fio $fioAGDG
	}
	elseif ($opcao -eq 'r') {
		Main
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
				break
			}
		}
	}
	$fioAGDG = PrintarFio -numFio $agdg
	Perguntar
}

$fioAGDG = ''

Main 
