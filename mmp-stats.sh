#!/usr/bin/env bash
format_khs(){
	case $units in
		"Ths")
                        units="ths"
                ;;
		"Ghs")
			units="ghs"
		;;
		"Mhs")
			units="mhs"
		;;
		 "khs")
                        units="khs"
                ;;

		"hs"|"gs"|"sols")
			units="hs"
		;;
		*)
		units="hs"
	esac
}



stats_raw=`curl --connect-timeout 2 --max-time 5 --silent --noproxy '*' http://127.0.0.1:44445/summary`
#stats_raw=`cat /hive/miners/lolminer/stats_raw`

#echo $stats_raw

#		local fan=`jq '[.Workers[]."Fan_Speed"]' <<< $stats_raw`
#		local temp=`jq '[.Workers[]."Core_Temp"]' <<< $stats_raw`
#		index =`jq '[.Workers[]."Index"]' <<< $stats_raw`

		bus_numbers=`echo $stats_raw |jq -r ".Workers[].PCIE_Address" | cut -f 1 -d ':' | jq -sc .`

		algo=`echo $stats_raw | jq -r '.Algorithms[0].Algorithm'`
		units=`echo $stats_raw | jq -c -r '.Algorithms[0].Performance_Unit'| tr -d "/"`
		khs=`echo $stats_raw | jq -r '.Algorithms[0].Total_Performance'`
		format_khs

		Accepted=`echo $stats_raw | jq -c -r '.Algorithms[0].Total_Accepted'`
		Rejected=`echo $stats_raw | jq -c -r '.Algorithms[0].Total_Rejected'`
		Invalid=`echo $stats_raw | jq -c -r '.Algorithms[0].Total_Errors'`
		InvGPU=`echo $stats_raw | jq '.Algorithms[0].Worker_Errors' | jq -cs '.' | sed  's/,/;/g' | tr -d [ | tr -d ]`

		hs=`echo $stats_raw | jq '.Algorithms[0].Worker_Performance'`

#		stats=$(jq '{index: [.Workers[].Index], busid: $bus_numbers, hash: [.Algorithms[0].Worker_Performance], air: [$Accepted,Rejected], units: "hs", miner_name: .Software, miner_version: "1.69"}' <<< $stats_raw)

stats=$(echo $stats_raw | jq --argjson busid "$bus_numbers" \
	    --argjson acc "$Accepted" \
	    --argjson rej "$Rejected" \
	    --argjson inv "$Invalid" \
	    --arg units "$units" \
	    '{index: [.Workers[].Index], $busid, hash: .Algorithms[0].Worker_Performance, air: [$acc,$rej,$inv], $units, miner_name: "lolMiner", miner_version: .Software}')

#[[ -z $khs ]] && khs=0
#[[ -z $stats ]] && stats="null"
echo $stats
