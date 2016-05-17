import os


def readFile(filename):
    filehandle = open(filename)
    print filehandle.read()
    filehandle.close()

readFile('hola.txt')
