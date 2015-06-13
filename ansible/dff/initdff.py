import json
import requests
import os

dffs = requests.get('https://fifoci.dolphin-emu.org/dff').json()
for dff in dffs:
    url = 'https://fifoci.dolphin-emu.org/' + dff['url']
    os.system('wget -c %s' % (url))

sql = open('dff.sql', 'w')
sql.write("begin;\n")
for dff in dffs:
    sql.write("insert into fifoci_fifotest (file, name, shortname, active, description) values('%s', '%s', '%s', '%s', '%s');\n"
            % (dff['url'], dff['filename'], dff['shortname'], 1, dff['shortname']))
sql.write("commit;\n")
sql.close()

