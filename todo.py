#!/usr/bin/env python
# encoding: UTF-8

import os
import sys
import re
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


if __name__ == '__main__':
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

