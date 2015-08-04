#!/usr/bin/env python
# encoding: UTF-8

import re, os, sys, getopt
from datetime import datetime, date
from yaml import load, dump


def build_dir( suff ):
    r_dir = os.getcwd() + '/' + suff + '/'
    return r_dir

def get_files( path ):
    return os.listdir( path )


def load_yaml( path, f ):
    full_path = path + f
    stream = file( full_path, 'r' )
    yaml = load( stream )
    return yaml

def default_out():
    path = build_dir('..')
    files = get_files( path )

    now_time = date.today()
    for f in files:
        m = re.match(r'\d+\.yaml$',  f )
        if m:
            yaml = load_yaml( path, f )
            if yaml.has_key( 'update' ):
                # 判断日期是否在2日内
                #datetime.datetime.strptime(dtstr, "%Y-%m-%d %H:%M:%S").date()
                last_update = datetime.strptime( yaml['update'], "%Y-%m-%d %H:%M" ).date()
                last_sale_days = ( now_time - last_update ).days

                if ( last_sale_days > 2 ):
                    print f + "\t" + str( last_sale_days ) + " days"
            else:
                print f + "\t" + "Never!"


def area_out():
    path = build_dir('..')
    files = get_files( path )

    # 字典型的 area
    areas = {}
    for f in files:
        m = re.match(r'\d+\.yaml$',  f )
        if m:
            yaml = load_yaml( path, f )

            if areas.has_key( yaml["area"] ):
                areas[yaml["area"]] = str( areas[yaml["area"]] ) + "\t" + f
            else:
                areas[yaml["area"]] = f


    keys = areas.keys()
    keys.sort()

    for k in keys:
        print str(k) + ":\t" + areas[k]


if __name__ == '__main__':
    try:
        opts, args = getopt.getopt(sys.argv[1:], "a:", ["area"])
    except getopt.GetoptError:
        sys.exit()

    if len( opts ) == 0:
        default_out()
        sys.exit()

    for o, a in opts:
        if o in ( '-a', '--area' ):
            area_out()
