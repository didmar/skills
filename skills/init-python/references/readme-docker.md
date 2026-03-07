## Docker

### Development

```bash
docker compose up -d --build app
```

Sources are mounted as a volume — edits are reflected immediately.

### Production

```bash
docker compose --profile prod up -d --build app-prod
```
