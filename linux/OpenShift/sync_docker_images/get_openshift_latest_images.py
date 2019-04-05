#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Get the latest docker images from https://access.redhat.com/containers.

Author: lj1218
Create: 2018-04-19
Update: 2018-04-19
"""
import json
import sys
import time
import urllib2

query_img_list = [
    'rhel7/pod-infrastructure',
    'openshift3/ose-pod',
    'openshift3/ose-docker-registry',
    'openshift3/ose-egress-router',
    'openshift3/ose-keepalived-ipfailover',
    'openshift3/ose-f5-router',
    'openshift3/ose-deployer',
    'openshift3/ose-haproxy-router',
    'openshift3/ose-sti-builder',
    'openshift3/ose-docker-builder',
    'openshift3/logging-deployer',
    'openshift3/logging-curator',
    'openshift3/metrics-deployer',
    'openshift3/logging-auth-proxy',
    'openshift3/logging-kibana',
    'openshift3/metrics-cassandra',
    'openshift3/metrics-hawkular-metrics',
    'openshift3/metrics-hawkular-openshift-agent',
    'openshift3/metrics-heapster',
    'openshift3/jenkins-1-rhel7',
    'openshift3/jenkins-2-rhel7',
    'openshift3/jenkins-slave-nodejs-rhel7',
    'openshift3/ose-service-catalog',
    'openshift3/ose-cluster-capacity',
    'openshift3/logging-fluentd',
    'openshift3/ose-egress-http-proxy',
    'openshift3/ose-ansible',
    'openshift3/registry-console',
    'openshift3/container-engine',
    'openshift3/ose',
    'openshift3/node',
    'openshift3/jenkins-slave-base-rhel7',
    'openshift3/jenkins-slave-maven-rhel7',
    'openshift3/openvswitch',
    'openshift3/logging-elasticsearch',
    'openshift3/mediawiki-apb',
    'openshift3/postgresql-apb',
    'openshift3/ose-recycler',
    ]

http_req_headers = {
    'Host': 'www.redhat.com',
    'Connection': 'keep-alive',
    'accept': 'application/json',
    'Origin': 'https://access.redhat.com',
    'Referer': 'https://access.redhat.com/containers/?tab=tags',
    # 'Accept-Encoding': 'gzip, deflate, br',
    'Accept-Language': 'zh-CN,zh;q=0.8'
    }

target_tag = 'latest'


def __write_file(filename, content):
    f = open(filename, 'w')
    for elem in content:
        f.write(elem)
    f.close()


def __get_img_tags_group_with_target_tag(images):
    latest = False
    for image in images:
        repositories = image['repositories']
        for repository in repositories:
            tag_names = []
            tags = repository['tags']
            for tag in tags:
                name = tag['name']
                if name == target_tag:
                    latest = True
                else:
                    tag_names.append(name)
            if latest:
                return tag_names
    return []  # Can't find target_tag


def __parse(resp, query_image, image_versions, unmatched_images):
    resp_json_dict = json.loads(resp)
    if resp_json_dict['matchCount'] == 0:
        unmatched_images.append('{0} :  matchCount=0\n'.format(query_image))
        return

    images = resp_json_dict['processed'][0]['images']
    tags = __get_img_tags_group_with_target_tag(images)
    if len(tags) == 0:
        unmatched_images.append("{0} :  can't find tag '{1}'\n".format(
            query_image, target_tag))
        return

    line = query_image
    for tag in tags[::-1]:
        line += ' ' + tag
    image_versions.append(line + '\n')


def __get_img_ver_tags(url, query_img, image_versions, unmatched_images):
    req = urllib2.Request(url, None, http_req_headers)
    f = urllib2.urlopen(req)
    resp = f.read()
    __parse(resp, query_img, image_versions, unmatched_images)


def __get_image_version_tags(output_file='temp.txt',
                             unmatched_file='unMatch.txt'):
    image_versions = []
    unmatched_images = []
    for item in query_img_list:
        print(item)
        url = 'https://www.redhat.com/wapps/containercatalog/' \
            + 'rest/v1/repository/registry.access.redhat.com/' \
            + item.replace('/', '%252F') + '/images'
        __get_img_ver_tags(url, item, image_versions, unmatched_images)
        time.sleep(1)

    if len(image_versions) > 0:
        __write_file(output_file, image_versions)
    if len(unmatched_images) > 0:
        print('Warning: Got some image tags failed! '
              'Please check it out at {0}'.format(unmatched_file))
        __write_file(unmatched_file, unmatched_images)


if __name__ == '__main__':
    argc = len(sys.argv)
    if argc == 1:
        __get_image_version_tags()
    elif argc == 2:
        __get_image_version_tags(sys.argv[1])
    else:
        __get_image_version_tags(sys.argv[1], sys.argv[2])
