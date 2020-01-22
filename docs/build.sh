#!/bin/bash
set echo off
rm -rf classes manual modules
sass scss/ldoc.scss ldoc.css --no-source-map -s compressed
ldoc config.ld