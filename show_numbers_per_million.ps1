$url = "https://github.com/owid/covid-19-data/raw/master/public/data/owid-covid-data.csv"
$datei = "daten.csv"

if ( -not (Test-Path $datei) -or ((Get-Item $datei).CreationTime -lt (Get-Date).AddDays(-1)) ) {
    Invoke-WebRequest $url -OutFile $datei    
}

$csv = Import-Csv -Delimiter "," $datei

$groups_by_countries = $csv | Group-Object location -AsHashTable

$countries = $groups_by_countries.Keys

$countries | ForEach-Object {
    $groups_by_countries."$_" | Format-Table date,@{l="new cases per million";e={[float]$_.new_cases_per_million}},@{l="new deaths per million";e={[float]$_.new_deaths_per_million}}
}

