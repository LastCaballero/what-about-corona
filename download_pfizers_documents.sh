#!/bin/sh

lynx -dump -listonly -nonumbers https://phmpt.org/pfizers-documents/ | grep -E "(pdf|txt|xlsx|xpt|xsl)$" | xargs -n 1 wget
