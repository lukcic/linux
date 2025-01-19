# heredoc

```sh
[COMMAND] <<[-] 'DELIMITER'
    HERE-DOCUMENT
DELIMITER
```

`<<` - special redirection operator

`EOF` -  delimiter- any string can be used, usually `EOF`.
If delimiter is unquoted, then shell will substitute all variables, if it is quoted, shell will print variables as is.

`<<-` - minus sign in redirection operator allows to use indentation (all leading tabs will be ignored). Indentation
cannot use space.

## Examples

```sh
cat << EOF
The current working directory is $PWD
You're logged as $(whoami)
EOF
```

```sh
if true; then
    cat <<- EOF
    Line with leading tab.
    EOF
fi
```

## Redirecting output to a file

```sh
cat << EOF > output.txt
The current working directory is: $PWD
You're logged as: $(whoami)
EOF

# cat << EOF >> output.txt will append
```

## Piping output

```sh
cat << 'EOF' | sed 's/l/e/g' > output.txt
Hello
World
EOF

#Heeeo
#Wored
```

## heredoc with ssh

`-T` -  do not allocate pseudo-terminal. Used with scripts.

```sh
#!/usr/bin/env bash

ssh -T pve2.lukcic.net << EOF
echo "The current local working directory is: $PWD"
echo "The current remote working directory is: \$PWD"
EOF

#The current local working directory is: /Users/lukaszcichecki/lukcic/projects/linux/bash_scripting
#The current remote working directory is: /root
```

In the first case, shell will substitute command on localhost and print local working directory. In the second case,
command is escaped, so will run on the remote host.
