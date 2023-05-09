# git-repo-size-reducer action

This action filters unneeded objects from a git repository using git-filter-repo. It can be used in the case that a git repository is too large for deployment, for example, to Heroku.

It works by using [git-filter-repo](https://github.com/newren/git-filter-repo), an excellent tool which is recommended by the git docs instead of git filter [here](https://git-scm.com/docs/git-filter-branch#_warning).

It first runs `git filter-repo --analyze`, which creates the file `.git/filter-repo/analysis/path-deleted-sizes.txt`. Then it runs a script which extracts all of the filepaths of artifacts from deleted files, and adds them to `files-to-delete.txt`. Then finally it runs `git filter-repo --invert-paths --paths-from-file files-to-delete.txt --force` which rewrites your git history, removing all of the files from it and recovering the storage.

Finally, it prints a report that you can read when the action has finished running, like this:

```sh
New history written in 0.04 seconds; now repacking/cleaning...
Repacking your repo and cleaning out old unneeded objects
Completely finished after 0.12 seconds.
Your repo previously contained 4 megabytes or 4605 kilobytes of objects.
It now contains 0 megabytes or 35 kilobytes of objects.
You have filtered 4 megabytes or 4570 kilobytes of objects from your git repository.
```

The most useful feature of this is that you don't have to rewrite the history of your main repo, which can cause problems when working with other developers. Running this action will not affect your main repository, and the rewritten (smaller) history can be push directly to Heroku or another cloud provider.

## Example usage

```yml
heroku:
  runs-on: ubuntu-latest

  steps:
    - uses: actions/checkout@v3
        with:
          fetch-depth: 0
    - name: Git Repo Size Reducer
      uses: eamon0989/git-repo-size-reducer@v1

    # add your logic to deploy the branch here
```
