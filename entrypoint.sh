#!/bin/sh

set -eu

REDIS_HOST="${REDIS_HOST:-redis}"
REDIS_PORT="${REDIS_PORT:-6379}"
NITTER_HTTPS="${NITTER_HTTPS:-false}"
NITTER_HOST="${NITTER_HOST:-nitter.net}"
NITTER_NAME="${NITTER_NAME:-nitter}"
NITTER_THEME="${NITTER_THEME:-Nitter}"
REPLACE_TWITTER="${REPLACE_TWITTER:-nitter.net}"
REPLACE_YOUTUBE="${REPLACE_YOUTUBE:-piped.kavin.rocks}"
REPLACE_REDDIT="${REPLACE_REDDIT:-teddit.net}"
REPLACE_INSTAGRAM="${REPLACE_INSTAGRAM:-""}"

BUILD="/build"
WORKD="/data"

build_working_dir()
{
    [ -d $WORKD ]             || mkdir -p $WOKRD

    [ -d $WORKD/tmp ]         || mkdir -p $WORKD/tmp
    [ -d $WORKD/public ]      || cp -rf $BUILD/public      $WORKD/.

    chown -R www-data:www-data $WORKD
    chmod 777 $WORKD
}

construct_nitter_conf()
{
    if [ ! -f $WORKD/nitter.conf ]; then
	cat /dist/nitter.conf.pre \
	    | sed "s/REDIS_HOST/$REDIS_HOST/g" \
	    | sed "s/REDIS_PORT/$REDIS_PORT/g" \
	    | sed "s/NITTER_HTTPS/$NITTER_HTTPS/g" \
	    | sed "s/NITTER_HOST/$NITTER_HOST/g" \
	    | sed "s/NITTER_NAME/$NITTER_NAME/g" \
	    | sed "s/NITTER_THEME/$NITTER_THEME/g" \
	    | sed "s/REPLACE_TWITTER/$REPLACE_TWITTER/g" \
	    | sed "s/REPLACE_YOUTUBE/$REPLACE_YOUTUBE/g" \
	    | sed "s/REPLACE_REDDIT/$REPLACE_REDDIT/g" \
	    | sed "s/REPLACE_INSTAGRAM/$REPLACE_INSTAGRAM/g" > $WORKD/nitter.conf
    fi
    chown www-data:www-data $WORKD/nitter.conf
}

run_nitter_program()
{
    cd $WORKD
    exec gosu www-data:www-data /usr/local/bin/nitter
}

# -- program starts

build_working_dir
construct_nitter_conf

if [[ $@ ]]; then 
    case "$1" in
	"init")
	    # workdir is prepared by now
	    ;;
	
	"nitter")
	    run_nitter_program;;
	
	*)
	    eval "exec $@";;
    esac
else
    run_nitter_program
fi

exit 0
