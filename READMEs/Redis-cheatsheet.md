# Redis basic commands cheatsheet

## Connect to redis from the container
```bash
docker exec -it traquer-redis redis-cli
```

Once on the redis-cli, you can use the following commands to authenticate and select the database:

```bash
auth <your_redis_password>
select 0
```

## List all keys
```bash
keys *
```

## Check value of a key
```bash
get <key>
```
