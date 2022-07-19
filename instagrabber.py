#!/usr/bin/env python3
import requests
import shutil
import json
import re
import argparse
from os import path

def getUserId(userId, sess):
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:102.0) Gecko/20100101 Firefox/102.0',
    }
    url = f'https://www.instagram.com/{userId}/'  
    print(f'[-] Attempting to grab user ID from {url}')
    r = sess.get(url)

    pattern = r'profilePage_(\d{1,12})'
    compPat = re.compile(pattern)
    return compPat.findall(r.text)[0]

def getReqURL(profileId, nResults=50, after=''):
    url = 'https://www.instagram.com/graphql/query/?query_id=17888483320059182&variables={'
    url += f'"id":"{profileId}"'
    url += f',"first":{nResults}'
    if after != '':
        url += f',"after":"{after}"'
    url += '}'
    return url

def buildImgList(profileId, sess):
    anotherPage = True
    afterId = ''
    imgURLs = []

    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:102.0) Gecko/20100101 Firefox/102.0',
        'X-Ig-App-Id': '936619743392459',
        'X-Asbd-Id': '198387',
        'Origin': 'https://www.instagram.com',
        'Referer': 'https://www.instagram.com/'
    }

    # gather urls to all images
    while anotherPage:
        r = sess.get(getReqURL(profileId, after=afterId), headers=headers)
        jsonData = json.loads(r.text)

        for i in jsonData['data']['user']['edge_owner_to_timeline_media']['edges']:
            imgURLs.append(i['node']['display_url'])

        anotherPage = jsonData['data']['user']['edge_owner_to_timeline_media']['page_info']['has_next_page']
        afterId = jsonData['data']['user']['edge_owner_to_timeline_media']['page_info']['end_cursor']
    
    return imgURLs

def downloadImages(imageList, writePath, sess):
    for i in imageList:
        filename = writePath + '/' + i.split('/')[-1].split('?')[0]
        r = requests.get(i, stream=True)
        r.raw.decode_content = True
        with open(filename, 'wb') as f:
            shutil.copyfileobj(r.raw, f)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-u', '--user', help='unique profile name of account to scrape')
    parser.add_argument('-s', '--sessionid', help='session id cookie value')
    parser.add_argument('-o', '--out', help='folder to save images')
    args = parser.parse_args()

    if not path.exists(args.out):
        print(f'{args.out} does not exist, exiting..')
        quit()

    s = requests.Session()
    s.cookies.set('sessionid', args.sessionid, domain='.instagram.com')

    profileId = getUserId(args.user, s)
    print(f'[+] Profile id found: {profileId}')
    images = buildImgList(profileId, s)
    print(f'[+] Found {len(images)} images to download')
    downloadImages(images, args.out, s)
    print(f'[+] Images saved to {args.out}')

if __name__ == '__main__':
    main()
