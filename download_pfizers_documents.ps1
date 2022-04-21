$url = "https://phmpt.org/pfizers-documents/"
$pfizer_dir = "pfizer"
-not ( Test-Path $pfizer_dir ) -and ( mkdir $pfizer_dir )
$website = Invoke-WebRequest -UseBasicParsing $url

$all_links = $website.links.href

$download_links = $all_links | Where-Object { $_ -match "`.[a-zA-Z]{2,}$" }

$download_links | ForEach-Object {
    $filename = ( $_ -split "/" )[-1]
    Invoke-WebRequest -Uri $_ -OutFile "$pfizer_dir/$filename"
}
