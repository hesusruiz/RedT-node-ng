#!/bin/sh
docker compose up -d
docker compose logs -f --tail=20
