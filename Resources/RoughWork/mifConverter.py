def makeAddress(address, HEX):
    spaces = " " * (7 - len(str(address)))
    return str("\t%s%s:   %d;\n" % (address, spaces, int(HEX, 16)));
    
header1 = "-- Copyright (C) 2016  Intel Corporation. All rights reserved.\n-- Your use of Intel Corporation's design tools, logic functions\n-- and other software and tools, and its AMPP partner logic\n-- functions, and any output files from any of the foregoing\n-- (including device programming or simulation files), and any\n-- associated documentation or information are expressly subject\n-- to the terms and conditions of the Intel Program License\n-- Subscription Agreement, the Intel Quartus Prime License Agreement,\n-- the Intel MegaCore Function License Agreement, or other\n-- applicable license agreement, including, without limitation,\n-- that your use is for the sole purpose of programming logic\n-- devices manufactured by Intel and sold by Intel or its\n-- authorized distributors.  Please refer to the applicable\n-- agreement for further details.\n\n-- Quartus Prime generated Memory Initialization File (.mif)\n"
header2 = "\nWIDTH=8;\nDEPTH=65536;\n\nADDRESS_RADIX=UNS;\nDATA_RADIX=UNS;\n\nCONTENT BEGIN\n"

imageFile = open("imageFile.hex", "r")
mifFile = open("IMAGE.mif", "w")

address = 0;

mifFile.write(header1)
mifFile.write(header2)

for line in imageFile:
    mifFile.write(makeAddress(address, line.strip()))
    address = address + 1;

mifFile.write("END;")
imageFile.close()
mifFile.close()
print("Complete!!!")
