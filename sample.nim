import re
doAssert find("abcdefg", re"cde") == 2
doAssert find("abcdefg", re"abc") == 0