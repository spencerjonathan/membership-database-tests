#!/bin/bash -x

./refresh_database.sh
codecept run acceptance
