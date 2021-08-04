#!/bin/bash
set -x
tmpdir=$(mktemp -d)
virtualenv "${tmpdir}/venv"
source "${tmpdir}/venv/bin/activate"
pip install -r requirements.txt

OLD_EMAILS=()

while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    --from-github-username)
      FROM_GITHUB_USERNAME="$2"
      shift # past argument
      shift # past value
      ;;
    --to-github-username)
      TO_GITHUB_USERNAME="$2"
      shift # past argument
      shift # past value
      ;;
    --to-github-token)
      TO_GITHUB_PASSWORD="$2"
      shift # past argument
      shift # past value
      ;;
    --to-github-netrc)
      TO_GITHUB_NETRC="$2"
      shift # past argument
      shift # past value
      ;;
    --new-name)
      NEW_NAME="$2"
      shift;
      shift;
      ;;
   --new-email)
     NEW_EMAIL="$2"
     shift;
     shift;
     ;;
   --old-email)
     OLD_EMAILS+=("$2")
     shift;
     shift;
     ;;
  esac
done

echo "Running with FROM_GITHUB_USERNAME=$FROM_GITHUB_USERNAME TO_GITHUB_USERNAME=$TO_GITHUB_USERNAME NEW_NAME=$NEW_NAME NEW_EMAIL=$NEW_EMAIL OLD_EMAIL=${OLD_EMAILS[*]}"

read -p "Press enter to continue or ctrl-c to quit"

pushd "${tmpdir}"

if [ -z "${TO_GITHUB_NETRC}" ]; then
  if [ -z "${TO_GITHUB_PASSWORD}" ] ; then
    echo "You must specify one of --to-github-netrc or --to-github-token"
    exit 1
  fi
  TO_GITHUB_NETRC="${tmpdir}/netrc"
  echo "machine api.github.com
login ${TO_GITHUB_USERNAME}
password ${TO_GITHUB_PASSWORD}" > "${TO_GITHUB_NETRC}"
fi

# Create the rewrite file

for email in "${OLD_EMAILS[@]}"
do
  echo "${NEW_NAME} <${NEW_EMAIL}> <${email}>" >> "${tmpdir}/rewritemap"
done

echo "Using rewrite map $(cat ${tmpdir}/rewritemap)"
echo "See README.md for info on how to configure"
read -p "Press enter to continue or ctrl-c to quit"

# Rewrite the repos

PAGE=1


while true; do
  #  RESULTS=$(curl -s "https://api.github.com/users/${FROM_GITHUB_USERNAME}/repos?per_page=200&page=${PAGE}" | jq -r ".[].name")
  RESULTS=$(curl -s "https://api.github.com/orgs/apache/repos?per_page=200&page=${PAGE}" | jq -r ".[].name")
  if [ -z "$RESULTS" ]; then
    break
  fi
  while IFS= read -r repo_name; do
    git clone "git@github.com:${FROM_GITHUB_USERNAME}/${repo_name}.git"
    pushd "${repo_name}" || continue
    git filter-repo --mailmap "${tmpdir}/rewritemap"
    git remote add newuser "git@github.com:${TO_GITHUB_USERNAME}/${repo_name}.git"
    curl --netrc-file "${TO_GITHUB_NETRC}" https://api.github.com/user/repos -d "{\"name\":\"${repo_name}\"}"
    git push --all newuser
    popd
  done <<< "$RESULTS"
  PAGE=$((PAGE + 1))
done
