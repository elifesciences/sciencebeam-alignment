#!/bin/bash
set -e

pytest sciencebeam_alignment
pylint sciencebeam_alignment
