def writeLine(line):
    L = line[9:11]
    hexImage.write(L + "\n")

hexFile = open("IMRA.hex", "r")
hexImage = open("Image.hex", "w")

for line in hexFile:
    writeLine(line)

hexImage.truncate(262142)
hexFile.close()
hexImage.close()
print("Conversion Complete!")
