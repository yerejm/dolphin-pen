import json
import requests
import os
import os.path

dffs = requests.get('https://fifoci.dolphin-emu.org/dff').json()
for dff in dffs:
    filename = dff['url'].split('/')[-1]
    if os.path.isfile(filename):
        print("%s already exists. Skipping..." % (filename))
    else:
        url = 'https://fifoci.dolphin-emu.org' + dff['url']
        os.system('wget -c %s' % (url))

sql = open('dff.sql', 'w')
sql.write("begin;\n")
for dff in dffs:
    sql.write("insert into fifoci_fifotest (file, name, shortname, active, description) values('%s', '%s', '%s', '%s', '%s');\n"
            % (dff['url'], dff['filename'], dff['shortname'], 1, dff['shortname']))
sql.write("commit;\n")
sql.close()

