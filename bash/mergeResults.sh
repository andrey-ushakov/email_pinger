#!/usr/bin/env bash

basePath=$1

# remove
rm -r ${basePath}/data*/src*/_valid_emails

rm -r ${basePath}/data*/src*/_invalid_emails
rm -r ${basePath}/data*/_invalid_emails

rm -r ${basePath}/data*/src*/_invalid_domains
rm -r ${basePath}/data*/_invalid_domains

rm -r ${basePath}/data*/src*/_done