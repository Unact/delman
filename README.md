# delman

Платформенно-независимое мобильное приложение для курьеров по приему платежей и передачи товаров

Для сборки и запуска приложения необходимо иметь в корне проекта файл .env с переменными среды:

* DELMAN_SENTRY_DSN
* DELMAN_YANDEX_API_KEY
* DELMAN_RENEW_URL

Также приложения можно запускать без .env файла, но тогда при запуске надо указывать
`--dart-define DELMAN_SENTRY_DSN=<значение> --dart-define DELMAN_YANDEX_API_KEY=<значение> --dart-define DELMAN_RENEW_URL=<значение>`
