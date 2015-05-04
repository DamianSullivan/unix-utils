# Filesystem Bookmarks
#
# A filesystem navigation tool.
#
# To use bookmarks:
#    $ cd /usr/local/home/long/path/to/dir
#    $ bookmark dir
#    $ cddir - now takes you back to that director
#    $ rmbookmark dir - removes the bookmark

function bookmark() {
  if [ -z "$1" ]; then
    echo "Usage: bookmark <name>";
  else
    bookmark_name=$1;
    alias cd${bookmark_name}="cd `pwd`";
    alias | grep "alias cd" | sort > ~/.bookmarks;
  fi
}

function rmbookmark() {
  if [ -z "$1" ]; then
    echo "Usage: rmbookmark <name>";
  else
    bookmark_name=$1;
    unalias cd${bookmark_name};
    alias | grep "alias cd" > ~/.bookmarks;
  fi
}
