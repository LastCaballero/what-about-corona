#!/bin/zsh

DATAFILE="owid-covid-data.csv"
URL="https://github.com/owid/covid-19-data/raw/master/public/data/owid-covid-data.csv"

latest_date=$( tail -n 1 $DATAFILE | cut -f 4 -d "," ) 
seconds_today=$( date +%s )
seconds_file=$( date -d $latest_date +%s )
difference_in_days=$(( ($seconds_today - $seconds_file) / (60*60*24) )) 

[[ ! -e $DATAFILE ]] && wget -O $DATAFILE $URL
[[ $difference_in_days -gt 2 ]] && wget -O $DATAFILE $URL

typeset -A columns
typeset -A countries
typeset -A rel_columns

columns=($(sed -n -r '1 s/,/\n/gp' $DATAFILE | nl))

OLDIFS=$IFS;IFS=$'\t\n'
	countries=($(sed 1d $DATAFILE | gawk -F "," '$2 != "" {print $3}' | sort | uniq | nl | sed -r 's/^ +//'))
	rel_columns=($(sed -n -r '1 s/,/\n/gp' $DATAFILE | nl | grep -E "million|vacci|density|stringency" | sed -r 's/^ +//'))
IFS=$OLDIFS


longest_chars_country=$((for l ( $countries ); print $l | wc -c) | sort -g | tail -n 1) 
longest_column_name=$((for l ( $columns ); print $l | wc -c) | sort -g | tail -n 1)

function all_countries_comparison () {
	for col ( ${(kn)rel_columns} ) {
		columnname=$rel_columns[$col]
		print -f "      $latest_date %${longest_column_name}s\n" $columnname
		for land ( $countries ) {
			grep -F -m 1 "$land,$latest_date" $DATAFILE | cut -f 3,$col -d "," 
		} | 
		gawk -F "," '$2 != "" { printf "%'$longest_chars_country's\t%15.4f\n", $1, $2 }' |
		sort -k 2 -g -r -t $'\t' | sed 30q | nl
		print "\n"
	}
}

all_countries_comparison | tee league_data_countries.txt

function compare_two_years () {
	year_ago=$( date -d "$latest_date -1 year" +"%Y-%m-%d" )
	year_ago_and_30_days_ago=$( date -d "$latest_date -1 year -30 days" +"%Y-%m-%d" )
	date_30_days_ago=$( date -d "$latest_date -30 days" +"%Y-%m-%d" )
	for country ( ${(o)countries} ) {
		for col ( ${(kn)rel_columns} ){
			print "\n$country:    $rel_columns[$col]"
			country_data=$(grep -F "$country" $DATAFILE)
			data1="$( sed -n -r '/'$year_ago_and_30_days_ago'/,/'$year_ago'/p' <<<$country_data | cut -f 4,$col -d "," )"
			data2="$( sed -n -r '/'$date_30_days_ago'/,/'$latest_date'/p' <<<$country_data  | cut -f 4,$col -d "," )"
			paste  <(cat <<<$data1) <(cat <<<$data2) |
			gawk '
				BEGIN{
					FS = ",|\t"
				}
				{
					printf "%10s\t%12.4f\t%10s\t%12.4f\n", $1, $2, $3, $4
				}
			'
		}
	}
}


compare_two_years | tee two_year_comparison.txt
