#!/bin/bash
set -e

docker run --rm elife/sciencebeam-alignment /bin/bash -c 'pytest sciencebeam_alignment && pylint sciencebeam_alignment'
