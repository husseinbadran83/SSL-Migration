set -x
domain=$1
crt=$2
key=$3
nsip=$4
user=$5
pwd=$6

get_file()

{

	filename=$1

sshpass -p "$pwd" scp -o StrictHostKeyChecking=no $user@$nsip:/nsconfig/ssl/$filename  .


}



convert_crt()

{

crt=$1

openssl x509 -in $crt -out $crt.pem
}


convert_rsa()

{

key=$1

openssl rsa -in $key -out $key.pem
}


import_to_acm()

{

crt_file_path=$1

key_file_path=$2

ca_file_path=$3



mv $crt_file_path $domain







if [ ! -z $ca_file_path ];

then

 



python3 import_Acm_script.py --certificate $domain  --certificate-chain $ca_file_path  --private-key $key_file_path



else

python3 import_Acm_script.py --certificate $domain   --private-key $key_file_path



fi





}





get_file $crt

get_file $key

convert_crt $crt

convert_rsa $key

import_to_acm $crt.pem $key.pem





