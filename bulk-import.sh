for i in `cat ADC_SSL_DETAILS.csv` ; do ./Migrate_to_ACM.sh `echo $i|cut -d',' -f1` `echo $i|cut -d',' -f2` `echo $i|cut -d',' -f3` ; done

