#!/bin/sh
#zonebuild.sh
export filename=$1
export target_comp=$2
export target_viewid=$3

zonename=$(cat $filename | jq -r '. | ."domain"')
zone=$(oci dns zone create --compartment-id $target_comp --name $zonename --zone-type "PRIMARY" --scope "PRIVATE" --view-id $target_viewid) 
zoneid=$(echo $zone | jq -r '.data | ."id"')
echo $zone | jq -r '.' > mirrored_$zoneid_$zonename.json

#cat $filename | jq -r '[.items[] | select (."rtype" | startswith("A"))]' > arecords_$filename.tmp
#sed -i 's/true/false/g' arecords_$filename.tmp
#oci dns record zone patch --zone-name-or-id $zoneid --scope "PRIVATE" --view-id $target_viewid --items file://arecords_$filename.tmp
#rm -f arecords_$filename.tmp 

cat $filename | jq -r '[.items[] | select (."rtype" | startswith("A","PTR"))]' > records_$filename.tmp
sed -i 's/true/false/g' records_$filename.tmp
oci dns record zone patch --zone-name-or-id $zoneid --scope "PRIVATE" --view-id $target_viewid --items file://records_$filename.tmp  
rm -f records_$filename.tmp

