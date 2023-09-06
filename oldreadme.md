```
#!/bin/sh 
rm -f zonesenum.sh
wget https://raw.githubusercontent.com/BaptisS/oci_dnsmiror/main/zonesenum.sh
chmod +x zonesenum.sh
rm -f zonelist.log
rm -f zonelistfull.log
rm -f zonesnamelist.log
rm -f zonesidlist.log

complist=$(oci iam compartment list --all --compartment-id-in-subtree true)
complistcur=$(echo $complist | jq .data | jq -r '.[] | ."id"')
for compocid in $complistcur; do oci dns zone list --compartment-id $compocid --all --scope PRIVATE --query 'data[?("is-protected")]' >> zonelistfull.log ; done
cat zonelistfull.log | jq -r '.[] | ."name"' >> zonesnamelist.log
cat zonelistfull.log | jq -r '.[] | ."id"' >> zonesidlist.log
zonesidlist=$(cat zonesidlist.log)
for zoneid in $zonesidlist; do echo Enumerating zone : $zoneid && ./zonesenum.sh $zoneid ; done

rm -f zonesnamelist.log
rm -f zonesidlist.log
rm -f zonesenum.sh

export date=$(date --iso-8601)
zip dns-zones.$date.zip zoneexport_ocid1.dns-zone*
rm -f *.json
export filename=$(ls *.zip)
export path=$(pwd)
echo $path/$filename
```
