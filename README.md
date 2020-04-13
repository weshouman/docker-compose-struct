# docker-compose-struct
This repo is an example of breaking the docker-compose config apart into smaller structured pieces to increase reusability.  
A makefile is provided as an example for combining the config back and how interfacing could be done.

### Usage Examples
```shell
make up   VARIANT=pg      AUTO_UPDATE=true
make down VARIANT=pg_web  AUTO_UPDATE=true
make up   VARIANT=pg_web  AUTO_UPDATE=false
make down VARIANT=pg      AUTO_UPDATE=true
make up   VARIANT=mariadb AUTO_UPDATE=true
make down VARIANT=mariadb
```

### Notes
To avoid unintended data deletion the provided makefile doesn't take down the volumes after tearing the containers, which is the default behavior of docker-compose.  
To achieve that, one would use for example ```docker-compose -f gen/pg-prod.yml down -v```

### Options
#### ```VARIANT```
- ```pg```: for a postgresql database based Gitea
- ```mariadb```: for a mariadb database based Gitea
- ```pg_web```: for working only with the web service of Gitea (when pg is used)
- ```mariadb_web```: for working only with the web service of Gitea (when mariadb is used)
#### ```AUTO_UPDATE```
- ```true```: regenerate the docker-compose file that will be applied to catch any updates.
- **```false```**: use the last generated file for the given variant
