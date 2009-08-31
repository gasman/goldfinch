10 CLEAR VAL "24575": LOAD "installer1"CODE
20 CLS: PRINT "Ready to install firmware."'"Please remove JP2 (E) jumper"'"to reflash ROM or leave JP2"'"linked if you want to test"'"the system in MAPRAM mode"'"without reflashing."''"Stripes in border will signal"'"installation progress."''"Press any key..."''
30 LET x=USR VAL "32768": IF x<>VAL "255" THEN PRINT "System not flashed.": IF x>=VAL "32" THEN PRINT "DivIDE error.":STOP
40 PRINT "Installation OK."''"Link jumper JP2 (E) and reboot."