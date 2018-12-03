#!/bin/bash -ex

# required variables and example:
# BRANCH=config
# TARGET_FILE=deployment/deployment.yml
# TARGET_REPO=git@github.com:DevOps-with-Kubernetes/okeydokey.git
# RELEASE_IMAGE_PATH=devopswithkubernetes/okeydokey:v1234
# COMMIT=866d1857df90990932cd4788a8106e8578332745
# GH_DEPLOYKEY=

# deploy key config
cat > DEPLOYKEY <<< "$(base64 --decode <<< "${GH_DEPLOYKEY}")"
chmod 600 DEPLOYKEY
eval $(ssh-agent -s)
ssh-add DEPLOYKEY

git config --global user.name "CI Updater"
git config --global user.email "ci@example.com"

git checkout -B ${BRANCH}
git pull origin ${BRANCH} --rebase || true

# Here we use yq to modify the image path of our template.
cat ${TARGET_FILE} | docker run  -i --rm --name yq devopswithkubernetes/yq --yaml-output \
'.spec.template.spec.containers[].image = $PATH' --arg PATH "${RELEASE_IMAGE_PATH}" > updated.yml
LINES=$(wc -l updated.yml | awk '{print $1}' )
[ "$LINES" = 0 ] && echo "Update failed." && exit 1

cat updated.yml > ${TARGET_FILE}


# Commit to another branch
git add "${TARGET_FILE}"
git commit -m "Update configs for ${COMMIT}"
git remote add target_repo "${TARGET_REPO}"
git push target_repo "${BRANCH}"

# You can also use personal token to be authed with github like one below:
# git remote add target_repo https://"${GH_TOKEN}"@"${TARGET_REPO}"
# git push target_repo "${BRANCH}"
