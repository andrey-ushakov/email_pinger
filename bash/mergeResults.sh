#!/usr/bin/env bash

basePath=$1

# > means overwrite ; >> means append

cat ${basePath}/data*/src*/_valid_emails > ${basePath}/all_valid_emails

cat ${basePath}/data*/src*/_invalid_emails > ${basePath}/all_invalid_emails
cat ${basePath}/data*/_invalid_emails >> ${basePath}/all_invalid_emails

cat ${basePath}/data*/src*/_invalid_domains > ${basePath}/all_invalid_domains
cat ${basePath}/data*/_invalid_domains >> ${basePath}/all_invalid_domains
