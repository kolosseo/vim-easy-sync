vim-easy-sync
=========

Fork from '[vim-hsftp](https://github.com/hesselbom/vim-hsftp/)' Vim plugin:
upload, download and automagically synch remote files just after saving locally (:w), through `sftp` and `rsync`.

Usage:
------
First of all:
- you need to have `rsync` and a `ssh` client installed on your machine;
- you have to create a config file called `.easync` in your project directory.
- the server you connect needs to have a listening `ssh` connection.

When uploading/downloading, this plugin searches backwards for the `.easync` file.
So, if the edited file is e.g. `/test/dir/file.txt` and the config file is `/test/.hsftp`, it will upload/download as `dir/file.txt`.

The config file should be structured like this (amount of spaces doesn't matter):
Be carefull to **ALWAYS** put the trailing "/" (slash) at the end of each remote path, to avoid `rsync` problems.

    host   1.1.1.1
    user   username
    pass   ''
    port   22
    remote /var/www/
    confirm_download 0
    confirm_upload 0

The "pass" field (password) is not used actually.
Only a ssh connection with key-file is contemplated.

### Exclude files
To avoid downloading specific files (only works on `EdownloadAll`), you can create the `.exclude` file, with the list of file patterns to exclude.
The syntax to use is the same of a simple `exclude-file` as explained in `man rsync`.
If you don't specify any, the deafult excluded files are just the following:
`.git*`
`.easync`
`.exclude`

### Commands
    :Edownload
Downloads current file from remote path

    :EdownloadAll
Downloads current directory from remote path

    :Eupload
Uploads current file to remote path

    :EuploadFolder
Uploads current folder of current buffer to remote path


### Mappings
    <leader>esd
Calls :Edownload

    <leader>esu
Calls :Eupload

    <leader>esf
Calls :EuploadFolder
