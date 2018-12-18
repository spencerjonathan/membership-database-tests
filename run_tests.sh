#!/bin/bash -x

sudo ./refresh_database.sh
codecept run acceptance
#codecept run -vvv acceptance
