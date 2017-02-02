#!/system/bin/bash
#Android: Requiere Bash & cURL
#Linux: Change "#!/system/bin/bash" by "#!/bin/bash"

help="""

usage:

4search [-BhiIL] [-p page to dislay] QUERY
ex: 4searcher -ir -p 3 

   -B )  [!] Android only  ..
            Open resultat in browser
   -h )  Show this message
   -i )  [!] Slow...
            Display ips address of hosts in results
   -I )  [!] Extra slow..
            Display ips and locations of hosts in results
   -L )  [!] Slow..
            Display locations of host in results
   -p )  Choose which page to use

#TODO;
    #[×]-P )  Curl -x 
    #[×]-r )  Reverse display result ("i--")
    #[×]-R )  Random query from file 
    #[×]-s )  Sqli urls ( with "=" )
"""
 
proxy=False  
random=False
number=1
page=1
ipf=False
locf=False
browsr=false
revrs=False
sqli=False

while getopts "BhisILp:P:" opt; do
  case "$opt" in
    B ) browsr=True ;;
    h ) echo -e "$help" && exit;;
    s ) number=$OPTARG ;;
    p ) page=$OPTARG ;;
#P )  Proxy=True;;
    i  ) ipf=True ;;
    I ) ipf=True; locf=True ;;
    L  ) locf=True ;;
#r ) revrs=True ;;
#R ) random=True ;;
#s ) sqli=True ;;
  esac
done
shift $(( OPTIND -1 ))


#..Query...

  z=$(echo "$@" | awk '{print NF}')
    if [ "$z" == 0 ];then
      echo -e "You need enter a query..\nusage:\ngtst [-BhiILs] [-p page to dislay] QUERY"
      exit
    elif [ "$z" == 1 ];then
      for query in "$@";do
        q="$query"
      done
    else
      for query in "$@";do
         q+="$query+"
      done
       q=${q:0:-1}
fi

#..Results page & request url...

if [ "$page" == "1" ]; then
  url="http://www.4search.com/search/?q="$q"&scat=all"
else
  rn=$(($page*100+1))
  rs=$(($page-1))
    url="http://www.4search.com/search/?q="$q"&rstart="$rs"&rn="$rn""
fi

#..Open in Browser...

if [ "$browsr" == True ]; then
su -c "am start -a android.intent.action.VIEW -d "$url"" && clear 
exit
fi

#..reca...

echo -e "\e[0;32mSearch for:$q\npage: $page\e[0m"

#..Urls+descr results...

reponse=$(curl -s "$url" | grep -A 1 -B 2 '"rurl"')
  urls=$(echo -e "$reponse" | grep "h4" | cut -d '"' -f 4)
  descr=$(echo "$reponse"  | grep "p style=" | cut -d ">" -f 2 | cut -d "<" -f 1)

#..Change var to array...

IFS=$'\n'
urls=($urls)
descr=($descr)
IFS=' '
rslt=${#urls[@]}


#..Display results...

for ((i=1;i<=$rslt;i++)); do

#..ip + loc (Extra slow)...

  if [ "$ipf" == True ] && [ "$locf" == True ];then 
    host=$(echo "${urls[$i-1]}" | cut -d "/" -f 3 )
    pg=$(ping -c1 $host | head -n1 | cut -d '(' -f 2)
    ip="${pg:0:-4}"
    loc=$(curl -s http://freegeoip.net/json/$host |cut -d "\"" -f24,12 | tr '\"' ':')
    echo -e "$i:\e[1;32m${urls[$i-1]}\n\e[0m\[($ip)$loc]: \e[1;33m${descr[$i-1]}\n\e[1;0m      ######################################\e[0m"

#..Ip (slow)...

  elif [ "$ipf" == True ];then
    host=$(echo "${urls[$i-1]}" | cut -d "/" -f 3 )
    pg=$(ping -c1 $host | head -n1 | cut -d '(' -f 2)
    ip="${pg:0:-4}"
      echo -e "$i:\e[1;32m${urls[$i-1]}\n\e[0m($ip): \e[1;33m${descr[$i-1]}\n\e[1;0m      ####################################\e[0m"

#..Loc (slow)...

  elif [ "$locf" == True ];then
    host=$(echo "${urls[$i-1]}" | cut -d "/" -f 3 )
    loc=$(curl -s http://freegeoip.net/json/$host |cut -d "\"" -f24,12 | tr '\"' ':')
    echo -e "$i:\e[1;32m${urls[$i-1]}\n\e[0m($loc)\e[1;33m${descr[$i-1]}\n\e[1;0m      #####################################\"e[0m"

#..Just urls and descriptions(faster)...

  else
    echo -e "$i:\e[1;32m${urls[$i-1]}\n \e[1;33m${descr[$i-1]}\n\e[1;0m      ###################################\e[0m"
  fi
done