if [ -z "$BASH" ]; then
    echo Bash not installed.
    exit 1
fi
git status >/dev/null 2>&1 || { echo >&2 "Not in a git directory or no git"; exit 1; }

mkdir -p /tmp/swissknife
touch /tmp/swissknife/modified_files.txt

FILES_MODIFIED=""
get_modified_files() {
    if [[ "$CIRCLE_BRANCH" == "$BASE_BRANCH" ]]; then
        FILES_MODIFIED=$(git diff --name-only HEAD HEAD~1)
    else
        FILES_MODIFIED=$(git diff --name-only $(git merge-base HEAD origin/${BASE_BRANCH})..HEAD)
    fi
}

get_modified_files
if [ -z "$FILES_MODIFIED" ]
then
    echo "Files not modified"
else
    echo "$FILES_MODIFIED" >> /tmp/swissknife/modified_files.txt
    cat /tmp/swissknife/modified_files.txt
fi
