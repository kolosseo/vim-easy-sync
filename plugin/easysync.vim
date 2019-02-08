" Title: easy-sync
" Description: Upload, download and automagically sync files just after ':w' through sftp and rsync
" Usage: :Eupload and :Edownload
"        By default mapped to
"        <leader>esd (easy-sync download) and
"        <leader>esu (easy-sync upload)
"        See README for more
" Github: https://github.com/kolosseo/vim-easy-sync
" Author: Jacopo Pace (jacopo.im)
" License: MIT

function! easysync#GetConf()
  let conf = {}

  let l:configpath = expand('%:p:h')
  let l:configfile = l:configpath . '/.easync'
  let l:foundconfig = ''
  if filereadable(l:configfile)
    let l:foundconfig = l:configfile
  else
    while !filereadable(l:configfile)
      let slashindex = strridx(l:configpath, '/')
      if slashindex >= 0
        let l:configpath = l:configpath[0:slashindex]
        let l:configfile = l:configpath . '.easync'
        let l:configpath = l:configpath[0:slashindex-1]
        if filereadable(l:configfile)
          let l:foundconfig = l:configfile
          break
        endif
        if slashindex == 0 && !filereadable(l:configfile)
          break
        endif
      else
        break
      endif
    endwhile
  endif

  if strlen(l:foundconfig) > 0
    let options = readfile(l:foundconfig)
    for i in options
      let vname = substitute(i[0:stridx(i, ' ')], '^\s*\(.\{-}\)\s*$', '\1', '')
      let vvalue = substitute(i[stridx(i, ' '):], '^\s*\(.\{-}\)\s*$', '\1', '')
      let conf[vname] = vvalue
    endfor

    let conf['local'] = fnamemodify(l:foundconfig, ':h:p') . '/'
    let conf['localpath'] = expand('%:p')
    let conf['remotepath'] = conf['remote'] . conf['localpath'][strlen(conf['local']):]
  endif

  return conf
endfunction

function! easysync#DownloadAll()
  let conf = easysync#GetConf()

  if has_key(conf, 'host')
    let exclude = printf('%s.exclude', conf['local'])
    let exclude_action = ''
    if filereadable(exclude)
        let exclude_action = printf('--exclude-from=%s', exclude)
    endif

    let cmd = printf('rsync -vrtplze ssh --progress --stats --delete %s --exclude=".easync" --exclude=".exclude" --exclude=".git*" %s@%s:%s %s', exclude_action, conf['user'], conf['host'], conf['remote'], conf['local'])
    echo cmd

    if conf['confirm_download'] == 1
      let choice = confirm('Download file?', "&Yes\n&No", 2)
      if choice != 1
        echo 'Canceled.'
        return
      endif
    endif

    execute '!' . cmd
  else
    echo 'Could not find .easync config file'
  endif
endfunction

function! easysync#DownloadFile()
  let conf = easysync#GetConf()

  if has_key(conf, 'host')
    let action = printf('get %s %s', conf['remotepath'], conf['localpath'])
    let cmd = printf('expect -c "set timeout 5; spawn sftp -P %s %s@%s; expect \"sftp>\"; send \"%s\r\"; expect -re \"100%\"; send \"exit\r\";"', conf['port'], conf['user'], conf['host'], action)

    if conf['confirm_download'] == 1
      let choice = confirm('Download file?', "&Yes\n&No", 2)
      if choice != 1
        echo 'Canceled.'
        return
      endif
    endif

    execute '!' . cmd
  else
    echo 'Could not find .easync config file'
  endif
endfunction

function! easysync#UploadFile()
  let conf = easysync#GetConf()

  if has_key(conf, 'host')
    let action = printf('put %s %s', conf['localpath'], conf['remotepath'])
    let cmd = printf('expect -c "set timeout 5; spawn sftp -r -P %s %s@%s; expect \"sftp>\"; send \"%s\r\"; expect -re \"100%\"; send \"exit\r\";"', conf['port'], conf['user'], conf['host'], action)

    if conf['confirm_upload'] == 1
      let choice = confirm('Upload file?', "&Yes\n&No", 2)
      if choice != 1
        echo 'Canceled.'
        return
      endif
    endif

    execute '!' . cmd
  endif
endfunction

function! easysync#UploadFolder()
  let conf = easysync#GetConf()

  " execute "! echo " . file
  " let conf['localpath'] = expand('%:p')
  let action = "send pwd\r;"
  if has_key(conf, 'host')
    for file in split(glob('%:p:h/*'), '\n')
      let conf['localpath'] = file
      let conf['remotepath'] = conf['remote'] . conf['localpath'][strlen(conf['local']):]
  
      if conf['confirm_upload'] == 1
        let choice = confirm('Upload file?', "&Yes\n&No", 2)
        if choice != 1
          echo 'Canceled.'
          return
        endif
      endif
      let action = action . printf('expect \"sftp>\"; send \"put %s %s\r\";', conf['localpath'], conf['remotepath'])
    endfor
    let cmd = printf('expect -c "set timeout 5; spawn sftp -P %s %s@%s; expect \"sftp>\"; send \"%s\r\"; expect -re \"100%\"; send \"exit\r\";"', conf['port'], conf['user'], conf['host'], action)
""  let cmd = printf('expect -c "set timeout 5; spawn sftp -P %s %s@%s; %s expect -re \"100%\"; send \"exit\r\";"', conf['port'], conf['user'], conf['host'], action)

    if conf['confirm_upload'] == 1
      let choice = confirm('Upload folder?', "&Yes\n&No", 2)
      if choice != 1
        echo 'Canceled.'
        return
      endif
    endif

    execute '!' . cmd
  else
    echo 'Could not find .easync config file'
  endif
endfunction

command! EdownloadAll call easysync#DownloadAll()
command! Edownload call easysync#DownloadFile()
command! Eupload call easysync#UploadFile()
command! EuploadFolder call easysync#UploadFolder()

nmap <leader>esd :Edownload<Esc>
nmap <leader>esu :Eupload<Esc>
nmap <leader>esf :EuploadFolder<Esc>
autocmd BufWritePost * :call easysync#UploadFile()
"autocmd BufReadPre * :call easysync#DownloadFile()
