import sys
import commands
import os

sys.exit(0)

FILES_TO_CHECK = (
    '.cvsignore',
    'Makefile',
    'readme.txt',
    'README.txt',
    'README.TXT',
    'setup.py',
    'INSTALL'
)

def run_cmd(cmd):
    status, output = commands.getstatusoutput(cmd)
    if status != 0:
        #sys.exit(1)
        return ""
    return output


def get_tag(output):
    return 

def print_latest_cvs_tag():
    for file in FILES_TO_CHECK:
        output = run_cmd("env LC_ALL=C cvs log " + file + "| grep symbolic -A 1")
        tokens = output.split(':')
        if len(tokens) >= 2:
            tag = tokens[1].strip()
            if tag:
                print tag
                break

if __name__ == '__main__':
    print_latest_cvs_tag()
