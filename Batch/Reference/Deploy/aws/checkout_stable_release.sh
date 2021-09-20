#aws/checkout_stable_release.sh CRMSD01
#Comment: this script will 
# 1. getting/export all environment variables from current HEAD 
# 2. checkout devops code for this environemt 
# 3. move to new environment
dbname=$1
source ./env_def/read_variables.sh $dbname
rm -rf /tmp/AWS/build-$$
mkdir -p /tmp/AWS/build-$$
cd /tmp/AWS/build-$$
git clone -b $GIT_BRANCH $GIT_REPOSITORY 
cd AWS/
git checkout $GIT_STABLE_VERSION
export Git_Working_Folder=/tmp/AWS/build-$$
