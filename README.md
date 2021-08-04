# github-rename-all-my-commits

Uses git filter-repo depending on system availability to rename all of your commits in all of your repos, intended for removing deadnames, will be funky with any forks you want to merge though.


This only runs on public repos.

# Warnings

This is not tested, I wrote this in between doing other crap for a friend.

# Install

git filter-repo requires python to be installed, fetching all of the user repos depends on "jq"

See the https://github.com/newren/git-filter-repo/blob/main/INSTALL.md for installing `filter-repo`.

See https://stedolan.github.io/jq/ for how to instal `jq`.

Also requires WSL to execute bash.

# Running

All of the "logic" is in `runme.sh`. Note no checks are performed to verify that new and from github usernames are different, but I strongly encourage that because this force pushes a lot.

You may specify multiple old e-mails.

`runme.sh --from-github-username [OLDGITHUBUSERNAME] --to-github-username [NEWGITHUBUSERNAME] --new-name "[NEWNAME]" --new-email [NEWEMAIL] --old-email [OLDEMAIL]`.


For password you must either specify `--github-netrc` pointing to a netrc file used for github.com login or `--github-token` specifying your github token (see https://github.com/settings/tokens to create one). Must have repo permissions.
