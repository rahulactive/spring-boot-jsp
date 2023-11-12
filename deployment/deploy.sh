# Find application version from pom.xml file
export APP_NAME=$(perl -nle 'print "$2" if /<(version)>(v(\d\.){2}\d)<\/\1/' pom.xml)
cd deployment
ansible-playbook -i <deployment srv address>, playbook.yaml -e app_name="news-${APP_NAME}.jar" --private-key=${SSHKEY} -u ${SSHUSER} -vv
