import urllib.request, json, argparse
import feedparser
import datetime
import time

parser = argparse.ArgumentParser(description='Check if a docker image has the latest security updates for Amazon Linux 2')
parser.add_argument('-r', '--rss', dest='rss', default='https://alas.aws.amazon.com/AL2/alas.rss', help="RSS feed from Amazon Linux Security Advisorie")
parser.add_argument('-i', '--image', dest='image', default='project0de/base', help="Name of docker image")
parser.add_argument('-t', '--tag', dest='tag', default='latest', help="Tag of the image to check")
args = parser.parse_args()

last_update = None
# get update time
with urllib.request.urlopen('https://hub.docker.com/v2/repositories/' + args.image + '/tags/') as url:
  data = json.loads(url.read().decode())
  for tag in data['results']:
    if tag['name'] == args.tag:
      last_update = datetime.datetime.strptime(tag['last_updated'], "%Y-%m-%dT%H:%M:%S.%fZ").timestamp()

if last_update == None: raise BaseException("Could not determine last update")

has_update = False
# check rss feed if CVE related updates exist
for e in feedparser.parse(args.rss).entries:
  if time.mktime(e.updated_parsed) > last_update:
    has_update = True
    print('{:s}:\n{:s}\n{:s}\n{:s}\n'.format(e.updated, e.title, e.description, e.link))

if has_update: exit(1)