#!/usr/bin/env python

import json
import subprocess


def communicate(cmd):
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    if p.returncode != 0:
        print out
        print err
        raise Exception(
            'Command exited with code %s: %s' % (p.returncode, cmd))
    return out, err


def list_containers():
    out, err = communicate(['docker', 'ps', '-q'])
    cids = out.split()
    return cids


def inspect_container(cid):
    out, err = communicate(['docker', 'inspect', cid])
    j = json.loads(out)
    assert len(j) == 1
    return j[0]


def get_info():
    cinfo = {}
    groups = {}
    for cid in list_containers():
        j = inspect_container(cid)
        # cinfo[cid] = j
        cinfo[j['Id']] = j
    return cinfo


def get_groups(docker):
    groups = {}
    for cid, j in docker.iteritems():
        try:
            clgroups = j['Config']['Labels']['groups'].split(',')
        except KeyError:
            clgroups = []
        for g in clgroups + ['all']:
            try:
                groups[g].add(cid)
            except KeyError:
                groups[g] = set([cid])
    return groups


def get_hostvars(docker):
    h = {}
    h['ansible_host'] = docker['Id']
    h['ansible_net'] = {'ipv4': {
        'address': docker['NetworkSettings']['IPAddress']}}
    h['ansible_connection'] = 'docker'
    h['docker'] = docker
    return h


def main(args):
    if len(args) == 1 or (len(args) == 2 and args[1] == '--list'):
        cinfo = get_info()
        i = get_groups(cinfo)
        i.update((k, list(v)) for (k, v) in i.iteritems())
        hostvars = dict((k, get_hostvars(v)) for (k, v) in cinfo.iteritems())
        i['_meta'] = {'hostvars': hostvars}
        print json.dumps(i)
    elif len(args) == 3 and args[1] == '--host':
        cinfo = get_info()
        h = get_hostvars(cinfo[args[2]])
        print json.dumps(h)
    else:
        raise Exception('Usage: %s [--list | --host HOST]' % args[0])


if __name__ == '__main__':
    import sys
    main(sys.argv)
