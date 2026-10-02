# Cadastro de Pessoas — Laravel + Vue 3

CRUD de pessoas (física/jurídica) com autenticação por sessão.
Laravel 13 · Vue 3 · Tailwind 4 · Vite · SQLite

## Demo online

**URL:** https://crud-pessoas-30de.onrender.com
**Login:** `admin@exemplo.com` / `senha123`

Hospedado no plano gratuito do Render: o primeiro acesso depois de um tempo
parado pode levar até ~1 minuto (o servidor "acorda"). O banco é recriado a
cada reinício, então os dados sempre voltam ao estado de exemplo.

Deploy: `Dockerfile` + `render.yaml` (Blueprint). Cada push no `master` publica
uma nova versão.

## Requisitos

- PHP 8.3+ (com extensão `pdo_sqlite`)
- Composer
- Node 20+

## Instalação

```bash
composer install
npm install
```

O arquivo `.env` já vem configurado (SQLite). Em uma cópia limpa do repositório
ele não existe — nesse caso:

```bash
cp .env.example .env
php artisan key:generate
```

Banco de dados (o arquivo `database/database.sqlite` não vai para o Git):

```bash
php artisan migrate --seed
```

## Rodando

Dois terminais:

```bash
npm run dev        # Vite (assets com hot reload)
php artisan serve  # http://127.0.0.1:8000
```

Ou, para rodar sem o Vite em modo dev, compile os assets uma vez com `npm run build`.

**Login:** `admin@exemplo.com` / `senha123` (criado pelo seeder)

## Testes

```bash
php artisan test
```

## Estrutura

| Camada | Arquivo |
|---|---|
| Tabela | `database/migrations/*_create_pessoas_table.php` |
| Model | `app/Models/Pessoa.php` |
| Validação | `app/Http/Requests/PessoaRequest.php` |
| Regra CPF/CNPJ | `app/Rules/CpfCnpj.php` |
| CRUD | `app/Http/Controllers/PessoaController.php` |
| Login | `app/Http/Controllers/AuthController.php` |
| Rotas | `routes/web.php` |
| Front (Vue) | `resources/js/components/` |
| HTTP client | `resources/js/api.js` |
| Testes | `tests/Feature/PessoaTest.php` |

## Notas

- O front é uma página só (`resources/views/app.blade.php`) que monta o Vue; todo
  o resto são endpoints JSON consumidos via `fetch`.
- Autenticação é por sessão/cookie. O token CSRF é rotacionado no login e
  devolvido no header `X-CSRF-TOKEN`, que o `api.js` reaplica.
- CPF e telefone são gravados **somente com dígitos**; a máscara é aplicada na tela.

## Depois de mover a pasta de lugar

As views Blade compiladas guardam caminhos absolutos. Rode:

```bash
php artisan optimize:clear
```
