# oci_dnsmiror

Export : 

````
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
for compocid in $complistcur; do oci dns zone list --compartment-id $compocid --all --scope PRIVATE >> zonelistfull.log ; done
cat zonelistfull.log | jq -r '.data[] | ."name"' >> zonesnamelist.log
cat zonelistfull.log | jq -r '.data[] | ."id"' >> zonesidlist.log
zonesidlist=$(cat zonesidlist.log)
for zoneid in $zonesidlist; do echo Enumerating zone : $zoneid && ./zonesenum.sh $zoneid ; done

rm -f zonesnamelist.log
rm -f zonesidlist.log
rm -f zonesenum.sh

````

Import : 


````
#!/bin/sh
#variables
export target_comp="ocid1.compartment."
export target_viewid="ocid1.dnsview."

zonesfiles=$(grep '"rtype": "A"' zoneexport_ocid* -lR)
for file in $zonesfiles; do ./zonebuild.sh $file $target_comp $target_viewid ; done



