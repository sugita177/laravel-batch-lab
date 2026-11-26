# Laravel Batch & Async Architecture 学習ロードマップ

実務レベルの大規模データ処理と、**6通りの起動アーキテクチャ**をすべてローカル環境で再現・検証するための体系的カリキュラムです。
各章の完了時にチェックボックスを更新し、学習記録（`docs/notes/chapter-XX.md`）とあわせて振り返りを残します。

---

## 進捗サマリー

| Chapter | テーマ | ステータス | 学習記録 |
| :--- | :--- | :---: | :--- |
| Chapter 1 | 最小環境の構築と Artisan コマンド基礎 | 未着手 | [chapter-01.md](docs/notes/chapter-01.md) |
| Chapter 2 | 大量データ処理とメモリ管理 | 未着手 | `docs/notes/chapter-02.md` |
| Chapter 3 | トランザクション境界・DBロック・冪等性（リラン設計） | 未着手 | `docs/notes/chapter-03.md` |
| Chapter 4 | 排他制御とスケジューリング（起動パターン①） | 未着手 | `docs/notes/chapter-04.md` |
| Chapter 5 | Laravel におけるテスト手法の習得（テスト先行学習） | 未着手 | `docs/notes/chapter-05.md` |
| Chapter 6 | 非同期キューと常駐ワーカー（起動パターン②・③） | 未着手 | `docs/notes/chapter-06.md` |
| Chapter 7 | HTTP・イベント駆動(SQS)・ワンショット実行（起動パターン④・⑤・⑥） | 未着手 | `docs/notes/chapter-07.md` |
| Chapter 8 | 総合演習（実務想定バッチの設計・実装・テスト） | 未着手 | `docs/notes/chapter-08.md` |

---

## Chapter 1: 最小環境の構築と Artisan コマンド基礎

### 学習項目・演習
- [ ] Docker コンテナ（`app`, `db`, `redis`）の起動と接続確認
- [ ] コンテナ内での Laravel プロジェクト初期化（Composer）と `.env` 設定（MySQL / Redis）
- [ ] Artisan コマンドの構造理解（`signature`, `description`, `handle()`）
- [ ] 引数・オプション設計（必須・任意・デフォルト値・配列・フラグ）とバリデーション
- [ ] 標準入出力（`info`, `warn`, `error`, `table`, `withProgressBar`）と終了コード（`Command::SUCCESS` / `FAILURE` / `INVALID`）
- [ ] **[実務観点]** バッチ専用ログチャンネルと構造化ログ設計（実行ID、処理件数、所要時間の記録）

### 学習メモ
- **学習日**: YYYY-MM-DD
- **学んだ要点**:
  - （完了時に記入）
- **ハマりどころ**:
  - （完了時に記入）

---

## Chapter 2: 大量データ処理とメモリ管理

### 学習項目・演習
- [ ] 検証用テーブル設計と Factory / バルクインサート（`DB::table()->insert()`）による数万〜数十万件のデータ高速生成
- [ ] `Model::all()` による OOM（`Allowed memory size exhausted`）の再現と `memory_get_peak_usage()` での実測
- [ ] `chunk()`、`chunkById()`、`lazy()`、`lazyById()`、`cursor()` の内部挙動（SQL・PDOバッファリング・メモリ消費）の比較検証
- [ ] データ更新（ステータス更新等）を伴う処理で `chunk()`（OFFSET ページネーション）を使った際に起きる**レコードスキップの罠**の再現と `chunkById()` による対策
- [ ] **[実務観点]** Eloquent モデル生成コスト vs Query Builder、`DB::disableQueryLog()`、`EXPLAIN` によるインデックス・フルスキャン確認

### 学習メモ
- **学習日**: YYYY-MM-DD
- **学んだ要点**:
  - （完了時に記入）
- **ハマりどころ**:
  - （完了時に記入）

---

## Chapter 3: トランザクション境界・DBロック・冪等性（リラン設計）

### 学習項目・演習
- [ ] 一括 `DB::transaction()` による InnoDB 行ロック／ギャップロックの長時間化と、別プロセス競合によるロック待ち・デッドロック（Error 1213）の再現
- [ ] `SHOW ENGINE INNODB STATUS` によるデッドロック原因の読み解き
- [ ] チャンク単位の部分コミット設計と、`lockForUpdate()` / `SKIP LOCKED` の挙動理解
- [ ] 状態遷移管理（`pending` → `processing` → `completed` / `failed`）と途中例外発生からの再実行（リラン）設計
- [ ] 何度再実行しても二重計上・不整合を起こさない**冪等性（Idempotency）設計**（ユニーク制約、Upsert、冪等キー）
- [ ] **[実務観点]** `pcntl` 拡張を使った `SIGTERM` / `SIGINT` シグナルハンドリング（`trap()` によるグレースフルシャットダウン）

### 学習メモ
- **学習日**: YYYY-MM-DD
- **学んだ要点**:
  - （完了時に記入）
- **ハマりどころ**:
  - （完了時に記入）

---

## Chapter 4: 排他制御とスケジューリング（起動パターン①：OS Cron + Scheduler）

### 学習項目・演習
- [ ] Laravel Scheduler（`routes/console.php`）と `schedule:run` / `schedule:work` / OS `cron` の仕組み理解
- [ ] `withoutOverlapping()` の内部挙動と有効期限（`expiresAt`）の落とし穴
- [ ] `Cache::lock()`（Redis アトミックロック）を用いた明示的な排他制御と異常終了時のTTL設計
- [ ] 複数台サーバー構成を想定した `onOneServer()` の仕組みと、2プロセス同時実行での排他検証
- [ ] **[実務観点]** スケジューラの可観測性（`before` / `after` / `onSuccess` / `onFailure` フック、実行履歴・Heartbeat 監視の設計）

### 学習メモ
- **学習日**: YYYY-MM-DD
- **学んだ要点**:
  - （完了時に記入）
- **ハマりどころ**:
  - （完了時に記入）

---

## Chapter 5: Laravel におけるテスト手法の習得（テスト先行学習）

> ※ Chapter 6 以降の非同期・複雑なバッチのテストを書く前に、Laravel のテスト基盤と検証パターンを集中的に習得する。

### 学習項目・演習
- [ ] テスト環境の分離設計（`.env.testing`、テスト専用DB、`RefreshDatabase` vs `DatabaseTransactions` の挙動と使い分け）
- [ ] Artisan コマンドのテスト（`$this->artisan()`, `expectsOutput()`, `expectsOutputToContain()`, `assertSuccessful()`, `assertFailed()`, `assertExitCode()`）
- [ ] 時刻依存バッチのテスト（`$this->travel()`, `$this->travelTo()`, `Carbon::setTestNow()`）
- [ ] フェイク・モックの習得（`Queue::fake()`, `Bus::fake()`, `Event::fake()`, `Cache` ロック競合状態の再現テスト）
- [ ] チャンク処理・DBトランザクション・冪等性（2回連続実行しても結果が変わらないこと）の Feature テスト実践

### 学習メモ
- **学習日**: YYYY-MM-DD
- **学んだ要点**:
  - （完了時に記入）
- **ハマりどころ**:
  - （完了時に記入）

---

## Chapter 6: 非同期キューと常駐ワーカー（起動パターン②・③：Queue Worker & Scheduler ハイブリッド）

### 学習項目・演習
- [ ] Redis Queue の基本構成と、`php artisan queue:work` vs `queue:listen` の内部挙動の違い
- [ ] メモリリーク・長時間稼働対策（`--max-jobs`, `--max-time`, `--memory`, `--sleep`）
- [ ] デプロイ時のグレースフル再起動（`queue:restart`）と Supervisor によるプロセス監視設計
- [ ] タイムアウト（`timeout` と `retry_after` の関係・二重実行の罠）、リトライ制御（`tries`, `backoff`, `maxExceptions`）、`failed_jobs` からの復旧（`queue:retry`）
- [ ] **[起動パターン③ ハイブリッド]** Scheduler で親ジョブ（または分割ディスパッチ）を投入し、複数ワーカーで並列処理する構成
- [ ] `Bus::batch()` によるジョブ分割・進捗管理（`job_batches`）・コールバック（`then` / `catch` / `finally`）・`allowFailures()`
- [ ] **[実務観点]** キュー優先度設計（`--queue=high,default,low`）と Job Middleware（`WithoutOverlapping`, `RateLimited`, `ThrottlesExceptions`）
- [ ] 上記非同期ジョブ・バッチの自動テスト作成

### 学習メモ
- **学習日**: YYYY-MM-DD
- **学んだ要点**:
  - （完了時に記入）
- **ハマりどころ**:
  - （完了時に記入）

---

## Chapter 7: HTTP/Webhook・イベント駆動（SQS）・ワンショットコンテナ実行（起動パターン④・⑤・⑥）

### 学習項目・演習
- [ ] **[起動パターン④ HTTP / Webhook]** 外部スケジューラ（Cloud Scheduler 等）を模した認証付き HTTP エンドポイント（トークン / HMAC 署名検証）からの起動と、HTTP タイムアウト回避のための非同期ディスパッチ（`202 Accepted` パターン）
- [ ] **[起動パターン⑤ イベント駆動 / SQS]** `docker-compose.yml` の `sqs` プロファイルで ElasticMQ を起動し、Laravel SQS ドライバと連携
- [ ] SQS の可視性タイムアウト（Visibility Timeout）・ロングポーリング・Dead Letter Queue（DLQ）への退避挙動を検証し、Redis Queue との違いを整理
- [ ] **[起動パターン⑥ ワンショットコンテナ]** `docker compose run --rm app php artisan ...` による ECS RunTask / AWS Batch / Cloud Run Jobs 型のコンテナ実行とステートレス設計・終了コード・標準エラー出力（stderr）連携
- [ ] 6通りの起動アーキテクチャの選定基準マトリクス作成（処理時間・冪等性・コスト・障害復旧・運用負荷）

### 学習メモ
- **学習日**: YYYY-MM-DD
- **学んだ要点**:
  - （完了時に記入）
- **ハマりどころ**:
  - （完了時に記入）

---

## Chapter 8: 総合演習（実務想定バッチの設計・実装・テスト）

### 学習項目・演習
- [ ] 実務シナリオ（例：大規模注文データの月次請求・集計バッチ基盤）の要件整理とアーキテクチャ選定
- [ ] 大量データチャンク処理・冪等なリラン設計・排他制御・`Bus::batch` による並列化・シグナルハンドリング・構造化ログの実装
- [ ] 障害注入テスト（チャンク途中での例外発生・ロック競合・ジョブ失敗からの復旧）の実施
- [ ] 包括的な自動テストスイート（Feature / Unit）の実装と全件パス確認
- [ ] 運用 Runbook（監視ポイント・障害時リラン手順・切り戻し手順）のドキュメント化

### 学習メモ
- **学習日**: YYYY-MM-DD
- **学んだ要点**:
  - （完了時に記入）
- **ハマりどころ**:
  - （完了時に記入）
