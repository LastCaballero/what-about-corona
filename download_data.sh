#!/bin/bash

url="https://covid.ourworldindata.org/data/owid-covid-data.csv"
file="owid-covid-data.csv"

wget -O $file $url
