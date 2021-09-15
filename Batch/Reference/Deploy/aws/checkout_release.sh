#aws/checkout_release.sh git@github.aus.thenational.com:CRMS/release.git DCExit /tmp/release/2315
release_url=$1
release_id=$2
tmp_release_folder=$3

rm -rf $tmp_release_folder
mkdir -p $tmp_release_folder
cd $tmp_release_folder
git clone $release_url
