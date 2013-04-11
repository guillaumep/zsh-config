import sys
import commands
import os


def run_cmd(cmd):
    status, output = commands.getstatusoutput(cmd)
    if status != 0:
        sys.exit(1)
    return output


def print_hg_info():
    output = run_cmd("env LC_ALL=C hg summary")
    l = output.split('\n')
    ver = branch = None
    for line in l:
        parsedline = line.split(':', 1)
        if parsedline[0] == 'branch':
            branch = parsedline[1].strip()
        elif parsedline[0] == 'parent':
            ver = parsedline[1].strip()
    if branch:
        print branch + ':' + ver
    elif ver:
        print ver

if __name__ == '__main__':
    print_hg_info()
