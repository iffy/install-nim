import re
if find("abcdefg", re"cde") == 2:
  echo "ok"
else:
  echo "fail"
if find("abcdefg", re"abc") == 0:
  echo "ok"
else:
  echo "fail"
