#!/bin/sh
# Roda a cada inicialização do container no Render.
set -e

cd /var/www/html

# Sem APP_KEY definida no painel, gera uma por inicialização. Como o banco
# também é recriado a cada boot, não há sessão antiga a preservar.
if [ -z "$APP_KEY" ]; then
    export APP_KEY="base64:$(head -c 32 /dev/urandom | base64)"
fi

# O Render informa a URL pública do serviço nesta variável.
export APP_URL="${APP_URL:-$RENDER_EXTERNAL_URL}"

# O disco do plano gratuito não é persistente: o SQLite nasce vazio a cada
# boot e recebe o usuário de demonstração e as pessoas de exemplo.
touch database/database.sqlite
php artisan migrate --force --seed

php artisan config:cache
php artisan route:cache
php artisan view:cache

# Tudo acima rodou como root; o Apache roda como www-data e precisa escrever
# no banco (sessões, cadastros) e em storage/.
chown -R www-data:www-data database storage bootstrap/cache

exec apache2-foreground
