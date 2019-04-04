#!/bin/sh

set -e

if [ ! -d "/var/alchemy/Phraseanet" ]
then
    git clone https://github.com/alchemy-fr/Phraseanet.git /var/alchemy/Phraseanet
    (cd /var/alchemy/Phraseanet \
        && git remote rename origin alchemy)
fi

cd /var/alchemy/Phraseanet
make

if [ ! -f "/var/alchemy/Phraseanet/config/configuration.yml" ]
then
    mkdir -p /var/alchemy/Phrasea_datas

    #### Phraseanet install
    bin/setup system:install --email=admin@phrdocker.dev --password=admin --db-host=db --db-port=3306 --db-user=root --db-password=root --db-template=en-simple --appbox=ab_master --databox=db_databox1 --server-name=Alchemy-dockerdev.dck --data-path=/var/alchemy/Phraseanet/Phrasea_datas -y

    ## change elasticsearch server host and create index
    bin/setup system:config set main.search-engine.options.host elasticsearch
    bin/setup system:config set main.search-engine.options.minScore 2
    bin/setup system:config set main.search-engine.options.base_aggregate_limit 10
    bin/setup system:config set main.search-engine.options.collection_aggregate_limit 10
    bin/setup system:config set main.search-engine.options.doctype_aggregate_limit 10
    bin/setup system:config set main.cache.options.host redis
    bin/setup system:config set main.cache.options.port 6379
    bin/setup system:config set main.cache.type Redis
    bin/setup system:config set workers.queue.main-queue.host rabbitmq
    bin/setup system:config set workers.queue.main-queue.user alchemy
    bin/setup system:config set workers.queue.main-queue.password vdh4dpe5Wy3R
    bin/setup system:config set main.storage.subdefs /var/alchemy/Phrasea_datas
    bin/setup system:config set main.storage.cache /var/alchemy/Phraseanet/cache
    bin/setup system:config set main.storage.log /var/alchemy/Phraseanet/log
    bin/setup system:config set main.storage.download /var/alchemy/Phraseanet/tmp/download
    bin/setup system:config set main.storage.lazaret /var/alchemy/Phraseanet/tmp/lazaret
    bin/setup system:config set main.storage.caption /var/alchemy/Phraseanet/tmp/caption
    bin/console compile:configuration
    bin/console searchengine:index -c

    ## enable API and disable ssl on it
    bin/setup system:config set registry.api-clients.api-enabled true
    bin/setup system:config set main.api_require_ssl false
    bin/console comp:conf
fi
