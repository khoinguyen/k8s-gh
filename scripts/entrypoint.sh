#!/bin/bash
set -e  # exit on error

setup-gh-app-auth() {
  if [[ "${GITHUB_APP_ID}" != "" ]] && [[ -e "${GITHUB_APP_SECRET_PATH}" ]] ; then
    # Create a temporary JWT for API access
    GITHUB_JWT=$( jwt encode --secret "@${GITHUB_APP_SECRET_PATH}" -i "${GITHUB_APP_ID}" --exp="10 mins" --alg RS256 )

    # Request installation information; note that this assumes there's just one installation (this is a private GitHub app);
    # if you have multiple installations you'll have to customize this to pick out the installation you are interested in    
    APP_TOKEN_URL=$( curl -s -H "Authorization: Bearer ${GITHUB_JWT}" -H "Accept: application/vnd.github.v3+json" https://api.github.com/app/installations | yq -r '.[0].access_tokens_url' )

    # Now POST to the installation token URL to generate a new access token we can use to with with the gh and hub command lines
    export GITHUB_TOKEN=$( curl -s -X POST -H "Authorization: Bearer ${GITHUB_JWT}" -H "Accept: application/vnd.github.v3+json" ${APP_TOKEN_URL} | yq -r '.token' )
    # Configure gh as an auth provider for git so we can use git push / pull / fetch with github.com URLs
    gh auth setup-git
  fi
}

setup-gh-app-auth

gh auth status

for f in /docker-entrypoint-init.d/*.sh; do
  bash "$f"
done

