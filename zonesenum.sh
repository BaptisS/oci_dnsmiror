#!/bin/sh
#zonesenum.sh
export zoneid=$1
zonedetail=$(oci dns zone get --zone-name-or-id $zoneid)
zone_compid=$(echo $zonedetail | jq -r '.data | ."compartment-id"')
zone_dom=$(echo $zonedetail | jq -r '.data | ."name"')
zone_viewid=$(echo $zonedetail | jq -r '.data | ."view-id"')
echo "Enumerating Domain : '"$zone_dom"'"

oci dns record zone get --zone-name-or-id $zoneid --all > zoneenum_$1.json
sed -i '1,3d' zoneenum_$1.json
head -n -5 zoneenum_$1.json > zoneenum_fixed_$1.json

echo "{" > zoneexport_$1.json
echo "  "'"compartmentId"'": '"$zone_compid"'," >> zoneexport_$1.json
echo "  "'"domain"'": '"$zone_dom"'," >> zoneexport_$1.json
echo "  "'"force"'": true," >> zoneexport_$1.json
echo "  "'"items"'": [" >> zoneexport_$1.json
cat zoneenum_fixed_$1.json >> zoneexport_$1.json
echo "  ]," >> zoneexport_$1.json
echo "  "'"scope"'": "PRIVATE"," >> zoneexport_$1.json
echo "  "'"viewId"'": '"$zone_viewid"'," >> zoneexport_$1.json
echo "  "'"zoneNameOrId"'": '"$zoneid"'" >> zoneexport_$1.json
echo "}" >> zoneexport_$1.json

rm -f zoneenum_$1.json
rm -f zoneenum_fixed_$1.json
