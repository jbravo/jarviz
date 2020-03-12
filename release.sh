#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

JARVIZ_HOME="$(pwd)"
export NPM_TOKEN=''

echo "Node version: $(node --version)"
echo "NPM version: $(npm --version)"
echo 'Java version:'
java -version

printf '\nYou are about to release both Java and Node modules. Proceed [yes/no]? '
read -r user_input
if [ "$user_input" != 'yes' ]; then
  echo 'Release canceled!'
  exit 0
fi

printf '\nPreparing release of jarviz-graph...\n'
cd ./jarviz-graph
TEMP_NPM_VERSION=$(npm version patch)
git add package.json
git commit -m "[npm] prepare release @vrbo/jarviz-graph@${TEMP_NPM_VERSION}"
cd "${JARVIZ_HOME}"

printf '\nPreparing release of jarviz-lib...\n'
mvn release:prepare -Dresume=false -DskipTests -Darguments='-DskipTests'

printf '\nPreparing release of jarviz-cli...\n'
sed -i -E "s|JARVIZ_CLI_VERSION\=[^\n]*|JARVIZ_CLI_VERSION\=${TEMP_NPM_VERSION}|" jarviz-cli/jarviz

echo 'Done'