#!/usr/bin/env bash
set -exo pipefail

dir="$( cd "$( dirname "$0" )" && pwd )"
home_dir=${CFDEV_HOME:-$HOME/.cfdev}
cache_dir="$home_dir/cache"
analyticskey="WFz4dVFXZUxN2Y6MzfUHJNWtlgXuOYV2"

servicew="$PWD"/servicew
servicewpkg="main"
go build \
  -o $servicew \
  -ldflags \
    "-X $servicewpkg.version=0.0.$(date +%Y%m%d-%H%M%S)" \
    code.cloudfoundry.org/cfdev/pkg/servicew

analyticsd="$PWD"/analytix
analyticsdpkg="main"
go build \
  -o $analyticsd \
  -ldflags \
    "-X $analyticsdpkg.testAnalyticsKey=$analyticskey
     -X $analyticsdpkg.version=0.0.$(date +%Y%m%d-%H%M%S)" \
     code.cloudfoundry.org/cfdev/pkg/analyticsd

cfdepsUrl="$cache_dir/cfdev-deps.tgz"
pkg="code.cloudfoundry.org/cfdev/config"

go build \
  -ldflags \
    "-X $pkg.cfdepsUrl=file://$cfdepsUrl
     -X $pkg.cfdepsMd5=$(md5sum "$cfdepsUrl" | awk '{ print $1 }')
     -X $pkg.cfdepsSize=$(wc -c < "$cfdepsUrl" | tr -d '[:space:]')

     -X $pkg.servicewUrl=file://$servicew
     -X $pkg.servicewMd5=$(md5sum "$servicew" | awk '{ print $1 }')
     -X $pkg.servicewSize=$(wc -c < "$servicew" | tr -d '[:space:]')

     -X $pkg.analyticsdUrl=file://$analyticsd
     -X $pkg.analyticsdMd5=$(md5sum "$analyticsd" | awk '{ print $1 }')
     -X $pkg.analyticsdSize=$(wc -c < "$analyticsd" | tr -d '[:space:]')

     -X $pkg.cliVersion=0.0.$(date +%Y%m%d-%H%M%S)
     -X $pkg.buildVersion=dev
     -X $pkg.testAnalyticsKey=$analyticskey" \
     code.cloudfoundry.org/cfdev

