# laravel-batch-lab

Laravel を用いた**バッチ処理・非同期基盤・大規模データ処理の設計と運用**をハンズオン形式で体系的に学ぶための検証リポジトリです。

## 目的

実務のエンタープライズ開発・本番運用で直面する以下の課題を、ローカル環境で実際に再現・計測・解決しながら習得します。

- 大量データ処理時のメモリ管理（OOM 再現、`chunk` / `chunkById` / `lazy` / `cursor` の比較）
- InnoDB のロック・デッドロック検証とトランザクション境界設計
- 障害発生時にもデータ不整合を起こさない冪等性（リラン）設計
- 排他制御（`Cache::lock` / `withoutOverlapping` / `onOneServer`）
- テスト駆動・事前学習による堅牢なバッチテスト
- **6通りのバッチ起動アーキテクチャ**の再現と比較
  1. OS Cron + Laravel Scheduler
  2. 常駐 Queue Worker（Redis）
  3. Scheduler + Queue Worker ハイブリッド（`Bus::batch` 並列処理）
  4. 認証付き HTTP / Webhook 起動
  5. イベント駆動キュー（SQS 互換: ElasticMQ）
  6. ワンショットコンテナ実行（ECS RunTask / AWS Batch 型）

詳細なカリキュラムと進捗は [road_map.md](road_map.md) を参照してください。

---

## 最小構成の実行環境（Docker / OrbStack）

ストレージ・メモリ消費を最小限に抑えるため、Laravel Sail のフルセットは使用せず、バッチ・非同期検証に必要な最小構成のみを定義しています。

| サービス | イメージ | 役割 |
| :--- | :--- | :--- |
| `app` | `php:8.4-cli-alpine` + Composer + `pdo_mysql`, `redis`, `pcntl` | Artisan コマンド・Queue Worker・テスト実行 |
| `db` | `mysql:8.0` | InnoDB ロック・デッドロック・インデックス検証 |
| `redis` | `redis:7-alpine` | `Cache::lock` 排他制御・Redis Queue 検証 |
| `sqs` *(optional)* | `softwaremill/elasticmq-native` (`profiles: ["sqs"]`) | Chapter 7 の SQS / DLQ 検証時にのみ起動 |

### 環境の起動・操作

```bash
# コンテナのビルドと起動（app, db, redis）
docker compose up -d --build

# app コンテナに入って作業する
docker compose exec app sh

# PHP / 拡張モジュールの確認
docker compose exec app php -v
docker compose exec app php -m

# ワンショット実行（起動パターン⑥の検証イメージ）
docker compose run --rm app php artisan --version

# 終了・停止
docker compose down

# Chapter 7 で SQS 互換コンテナ（ElasticMQ）を追加起動する場合
docker compose --profile sqs up -d
```

---

## ディレクトリ構成

```text
.
├── Dockerfile                # PHP 8.4 CLI Alpine + Composer + 必須拡張
├── docker-compose.yml        # app / db / redis (+ sqs プロファイル)
├── docker/
│   ├── php/php.ini           # PHP CLI 設定（メモリ上限・タイムゾーン等）
│   └── mysql/my.cnf          # MySQL 8.0 設定（デッドロックログ有効化等）
├── docs/
│   └── notes/                # 章別の学習記録
├── road_map.md               # 体系的カリキュラムと進捗管理
└── README.md
```

---

## 章別学習記録インデックス

各章の学び・検証結果・コマンド例・ハマりどころは章別ファイルで管理します。

- [Chapter 1: 最小環境の構築と Artisan コマンド基礎](docs/notes/chapter-01.md)
- Chapter 2: 大量データ処理とメモリ管理 *(予定: `docs/notes/chapter-02.md`)*
- Chapter 3: トランザクション境界・DBロック・冪等性 *(予定: `docs/notes/chapter-03.md`)*
- Chapter 4: 排他制御とスケジューリング（起動パターン①） *(予定: `docs/notes/chapter-04.md`)*
- Chapter 5: Laravel におけるテスト手法の習得 *(予定: `docs/notes/chapter-05.md`)*
- Chapter 6: 非同期キューと常駐ワーカー（起動パターン②・③） *(予定: `docs/notes/chapter-06.md`)*
- Chapter 7: HTTP・イベント駆動(SQS)・ワンショット実行（起動パターン④・⑤・⑥） *(予定: `docs/notes/chapter-07.md`)*
- Chapter 8: 総合演習 *(予定: `docs/notes/chapter-08.md`)*

---

## 開発・Git ワークフロー

1. 作業ごとにトピックブランチを作成する（例: `feat/chapter-01-setup`）
2. 実装・検証・学習記録（`docs/notes/chapter-XX.md`）および `road_map.md` を更新する
3. 変更内容を確認し、コミット & プッシュする
4. `gh pr create` で Pull Request を作成し、内容確認後にマージする
