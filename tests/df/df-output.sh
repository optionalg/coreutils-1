#!/bin/sh
# Exercise df's --output option.

# Copyright (C) 2012 Free Software Foundation, Inc.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

. "${srcdir=.}/tests/init.sh"; path_prepend_ ./src
print_ver_ df

# Ensure that --output is mutually exclusive with -i, -P, and -T.
# Ensure that this limitation is not depending on the order of options.
cat <<\EOF > exp || framework_failure_
df: options OPT and --output are mutually exclusive
Try 'df --help' for more information.
EOF

df -i --output '.' 2>out && fail=1
sed -i 's/ -i / OPT /' out
compare exp out || fail=1

df --output -i '.' 2>out && fail=1
sed -i 's/ -i / OPT /' out
compare exp out || fail=1

df -P --output '.' 2>out && fail=1
sed -i 's/ -P / OPT /' out
compare exp out || fail=1

df --output -P '.' 2>out && fail=1
sed -i 's/ -P / OPT /' out
compare exp out || fail=1

df -T --output '.' 2>out && fail=1
sed -i 's/ -T / OPT /' out
compare exp out || fail=1

df --output -T '.' 2>out && fail=1
sed -i 's/ -T / OPT /' out
compare exp out || fail=1

# Ensure that each field is only used once for the --output argument.
cat <<\EOF > exp || framework_failure_
df: option --output: field 'target' used more than once
Try 'df --help' for more information.
EOF

df --output=target,source,target '.' 2>out && fail=1
compare exp out || fail=1

# Ensure that this limitation also works for splitted --output options.
df --out=target,source --out=target '.' 2>out && fail=1
compare exp out || fail=1

# Ensure that the full output includes all fields, and
# that --o (without argument) is identical to the full list.

cat <<\EOF > exp || framework_failure_
Filesystem Type Size Used Avail Use% Inodes IUsed IFree IUse% Mounted on
EOF

df --o=source,fstype,size,used,avail,pcent \
 --o=itotal,iused,iavail,ipcent,target '.' >out || fail=1
sed -e '1 {s/ [ ]*/ /g;q}' out > out2
compare exp out2 || fail=1

df --output '.' >out || fail=1
sed -e '1 {s/ [ ]*/ /g;q}' out > out2
compare exp out2 || fail=1

# Ensure that the grand total line now contains a "-" in the TARGET field ...
cat <<\EOF > exp || framework_failure_
-
EOF

df --output=source,target --total '.' >out || fail=1
sed -n -e '3 {s/^total[ ]*//;p;q}' out > out2
compare exp out2 || fail=1

# ... but it should read "total" if there is no SOURCE field.
cat <<\EOF > exp || framework_failure_
total
EOF

df --output=target --total '.' >out || fail=1
sed -n -e '3 {p;q}' out > out2
compare exp out2 || fail=1

# Ensure that --output is mentioned in the usage.
cat <<\EOF > exp || framework_failure_
--output
EOF

df --help > out || fail=1
grep ' --output' out | sed 's/^.*\(--output\).*$/\1/;q' > out2
compare exp out2 || fail=1

Exit $fail