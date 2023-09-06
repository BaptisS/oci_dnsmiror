# oci_dnsmiror

Export : 

````

#!/bin/sh 
rm -f zonesenum.sh
wget https://raw.githubusercontent.com/BaptisS/oci_dnsmiror/main/zonesenum.sh
chmod +x zonesenum.sh
rm -f zonelist.log

export region=$(echo $OCI_REGION)
export tenancyid=$(echo $OCI_TENANCY)
export tenancyname=$(oci iam compartment get --compartment-id $tenancyid | jq -r '.data | ."name"')

rm -f zonelistfull-$region-$tenancyname.log
rm -f zonesnamelist-$region-$tenancyname.log
rm -f zonesidlist-$region-$tenancyname.log


#oci search resource structured-search --query-text "query dnsview resources" --region $region > dnsviews-$region-$tenancyname.log
#complistcur=$(cat dnsviews-$region-$tenancyname.log | jq -r '.data.items[] | ."compartment-id"'| sort | uniq)
complistcur=$(oci search resource structured-search --query-text "query dnsview resources" --region $region | jq -r '.data.items[] | ."compartment-id"'| sort | uniq)
for compocid in $complistcur; do echo List Zones in $compocid && oci dns zone list --compartment-id $compocid --all --scope PRIVATE --query 'data[?("is-protected")]' >> zonelistfull-$region-$tenancyname.log ; done
cat zonelistfull-$region-$tenancyname.log | jq -r '.[] | ."name"' >> zonesnamelist-$region-$tenancyname.log
cat zonelistfull-$region-$tenancyname.log | jq -r '.[] | ."id"' >> zonesidlist-$region-$tenancyname.log
zonesidlist=$(cat zonesidlist-$region-$tenancyname.log)
for zoneid in $zonesidlist; do echo Enumerating zone : $zoneid && ./zonesenum.sh $zoneid ; done

rm -f zonesnamelist-$region-$tenancyname.log
rm -f zonesidlist-$region-$tenancyname.log
rm -f zonesenum.sh

export date=$(date --iso-8601)
zip dns-zones.$date_$tenancyname_$region.zip zoneexport_ocid1.dns-zone*
rm -f *.json
export filename=$(ls *.zip)
export path=$(pwd)
echo $path/$filename


````

Import : 


````
#!/bin/sh
#variables
export target_comp="ocid1.compartment."
export target_viewid="ocid1.dnsview."

rm -f zonebuild.sh
wget https://raw.githubusercontent.com/BaptisS/oci_dnsmiror/main/zonebuild.sh
chmod +x zonebuild.sh

rm -f zonesa.list
rm -f zonesptr.list
rm -f zonesaaaa.list

grep '"rtype": "A"' zoneexport_ocid* -lR > zonesa.list
grep '"rtype": "PTR"' zoneexport_ocid* -lR > zonesptr.list
grep '"rtype": "AAAA"' zoneexport_ocid* -lR > zonesaaaa.list

cat zonesa.list > zones.file
cat zonesptr.list >> zones.file
cat zonesaaaa.list >> zone.file
uniq -u zones.file > zonesfile.log

zonesfiles=$(cat zonesfile.log)

rm -f zonesfile.log
rm -f zones.file

#zonesfiles=$(grep '"rtype": "A"' zoneexport_ocid* -lR)

for file in $zonesfiles; do ./zonebuild.sh $file $target_comp $target_viewid ; done





````

Cleanup: 


````
#!/bin/sh
#variables
export compocid='ocid1.compartment.abcdefgh'
export viewid='ocid1.dnsview.abcdefgh'

zoneslist=$(oci dns zone list --compartment-id $compocid --view-id $viewid --scope PRIVATE --all | jq -r '.data[] | [."id"] | @csv' | tr -d '"')
for zone in $zoneslist; do oci dns zone delete --zone-name-or-id $zone --force --scope PRIVATE --view-id $viewid && echo zone $zone deleted;done


