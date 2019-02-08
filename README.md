vim-my-sync
=========

Fork from '[vim-hsftp](https://github.com/hesselbom/vim-hsftp/)' Vim plugin:
upload, download and automagically synch remote files just after saving locally (:w), through `sftp` and `rsync`.

Usage:
------
First of all:
- you need to have `rsync` and a `ssh` client installed on your machine;
- you have to create a config file called `.hsftp` in your project directory.
- the server you connect needs to have a listening `ssh` connection.

When uploading/downloading, this plugin searches backwards for the `.hsftp` file.
So, if the edited file is e.g. `/test/dir/file.txt` and the config file is `/test/.hsftp`, it will upload/download as `dir/file.txt`.

The config file should be structured like this (amount of spaces doesn't matter):
Be carefull to **ALWAYS** put the trailing "/" (slash) at the end of each remote path, to avoid `rsync` problems.

    host   1.1.1.1
    user   username
    port   22
    remote /var/www/
    confirm_download 0
    confirm_upload 0

The "pass" field is not used anymore.
Only a key-file connection is contemplated, actually.

### Exclude files
To avoid downloading specific files (only works on `HdownloadAll`), you can create the `.exclude` file, with the list of file patterns to exclude.
The syntax to use is the same of a simple `exclude-file` as explained in `man rsync`.
If you don't specify any, the deafult excluded files are just the following:
`.git*`
`.hsftp`
`.exclude`

### Commands
    :Hdownload
Downloads current file from remote path

    :HdownloadAll
Downloads current directory from remote path

    :Hupload
Uploads current file to remote path

    :HuploadFolder
Uploads current folder of current buffer to remote path


### Mappings
    <leader>hsd
Calls :Hdownload

    <leader>hsu
Calls :Hupload

    <leader>hsf
Calls :HuploadFolder
