diff 2.txt 1.txt > diff.txt
lua.exe tweak_diff.lua diff.txt
patch --binary 2.txt diff.txt1
