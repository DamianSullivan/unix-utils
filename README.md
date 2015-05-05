### Bash Eternal History  
Records all commands to a file for later searching.  
usage:  
  source ~/bash_eternal_history.sh  
  ...type a bunch of commands...  
  ? command (To find matches for the command in bash history.)

### Filesystem Bookmarks
A filesystem navigation tool when working with long directory structures.  
usage:  
  $ source ~/bookmarks.sh  
  $ cd /usr/local/home/long/path/to/dir  
  $ bookmark dir  
  $ cddir - now takes you back to that director  
  $ rmbookmark dir - removes the bookmark  

### Orange Cursor  
Make the cursor safety orange to be able to find it easily.  
usage:  
  source ~/orange_cursor.sh  
  <cursor is now orange>  

### Rollup
add up values with a common key.  
  example_file.txt:  
    key1  5  
    key1  5  
    key2  1  
 $ ./rollup.pl example_file.txt  
    key1  10  
    key2  1  
    Total 11  

### Terminal Session Recording
Uses script command to record all terminal sessions to for later review.
usage:
    source ~/session_recording.sh
    all terminal sessions will be saved in ~/terminal-logs
