#!/usr/bin/env bash

if [[ -z $1 ]]; then
	echo Error: Provide output filename or - for stdout
	exit 1
fi

ykman piv certificates export 9c $1

