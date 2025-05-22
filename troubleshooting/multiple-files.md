# Working with many files

Create multiple files

```sh
seq 1 1000000 | xargs touch
```

## Speeding up process

```sh
ls -lsU ./directory
# disable  sorting

rm *
# argument list is too long - too many file names passed as arguments

ls -U | xargs rm
# will work

cd ..
mkdir empty
rsync -a  --delete empty/ directory/
# sync catalogs and remove from 'directory' everything which is not present in dir 'empty'
```