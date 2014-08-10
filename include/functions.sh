#!/bin/bash

function HoldPackage()
{
    local package=$1

    echo "${package}" hold > dpkg --set-selections
}

function AptInstall()
{
    local packages=$@

    apt-get -y install ${packages}
}

function AptFixDeps()
{
    apt-get -fy install
}

function DoEcho()
{
    echo "==== $1"
}

function DeliverFile()
{
    local file=$1
    local delivery_path=$2

    cp "${DELIVERY_DIR}/${file}" "${delivery_path}"
}
