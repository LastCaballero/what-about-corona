#! /bin/zsh
url="https://phmpt.org/pfizers-documents/"

ddir=downloads
[[ ! -d $dwdir ]] && mkdir -p $ddir

links_all=( $( lynx -dump -listonly -nonumbers $url ) )
links_ext=( $( print -l $links_all:e | sort | uniq  ) )

grepstring=$( sed 's/^/(/;s/ /|/g;s/$/)$/' <<< $links_ext )

links_rel=( $( print -l $links_all | grep -E "$grepstring" ) )

cd $ddir
for dow ( $links_rel ) {
	[[ ! -e $dow:tail ]] && wget $dow	
}
