# コマンド一覧

`:` から実行するコマンドです。`<leader>fc` で一覧から検索して実行できます。

多くのプラグインは使うときに読み込まれるため、プラグインのコマンドの一部は最初のキー操作やコマンド実行のあとで使えるようになります（例: Claude Code のコマンドは `<leader>cc` のあとにすべて揃います）。

## この設定で定義しているコマンド

| コマンド | 動作 | 定義 |
| --- | --- | --- |
| `:ErrorLogPath` | エラーログのパス（`~/.cache/nvim/error.log`）を表示 | `config/errorlog.lua` |
| `:ErrorLogClear` | エラーログを空にする | `config/errorlog.lua` |
| `:ErrorLogDump` | 開いているバッファの診断（エラー・警告）をすべてエラーログに追記 | `config/errorlog.lua` |
| `:FormatEnable` | 保存時の自動フォーマットを有効にする（このセッションのみ） | `plugins/lsp.lua` |
| `:FormatDisable` | 保存時の自動フォーマットを無効にする | `plugins/lsp.lua` |
| `:FormatDisable!` | 現在のバッファだけ保存時の自動フォーマットを無効にする | `plugins/lsp.lua` |

保存時の自動フォーマットは起動時は無効です。手動でフォーマットするときは `<leader>cf` を使います。

## Claude Code（claudecode.nvim）

| コマンド | 動作 |
| --- | --- |
| `:ClaudeCode [引数]` | Claude Code の表示 / 非表示。引数は `claude` CLI に渡る（例: `:ClaudeCode --resume`） |
| `:ClaudeCodeOpen [引数]` / `:ClaudeCodeClose` | Claude Code を開く / 閉じる |
| `:ClaudeCodeFocus` | Claude のウィンドウへフォーカス（フォーカス中なら隠す） |
| `:ClaudeCodeSelectModel` | モデルを選んで Claude Code を開く |
| `:ClaudeCodeAdd <パス> [開始行] [終了行]` | ファイルやディレクトリをコンテキストに追加（例: `:ClaudeCodeAdd %`） |
| `:ClaudeCodeSend` | 選択範囲を送る（エクスプローラーではファイルを送る） |
| `:ClaudeCodeTreeAdd` | エクスプローラーで選択中のファイルを追加 |
| `:ClaudeCodeSendText <テキスト>` | テキストを Claude に送って実行（`!` を付けると入力するだけで送信しない） |
| `:ClaudeCodeDiffAccept` / `:ClaudeCodeDiffDeny` | 提案された差分を承認 / 拒否 |
| `:ClaudeCodeCloseAllDiffs` | 保留中の差分をすべて閉じる |
| `:ClaudeCodeStart` / `:ClaudeCodeStop` / `:ClaudeCodeStatus` | 連携サーバーの開始 / 停止 / 状態表示 |

## 検索（Telescope）

| コマンド | 動作 |
| --- | --- |
| `:Telescope` | ピッカーの一覧 |
| `:Telescope <ピッカー>` | 指定したピッカーを開く（例: `find_files`、`live_grep_args`、`git_status`、`oldfiles`） |
| `:Telescope resume` | 直前のピッカーを、前回の入力と結果のまま開き直す |
| `:TodoTelescope [keywords=TODO,FIX]` | TODO などのコメントを検索（キーワードで絞り込める） |
| `:TodoQuickFix` / `:TodoLocList` | TODO などのコメントを quickfix / location list に出す |

## Git

| コマンド | 動作 |
| --- | --- |
| `:DiffviewOpen [リビジョン]` | 差分を開く（例: `:DiffviewOpen`、`:DiffviewOpen main`、`:DiffviewOpen HEAD~1`） |
| `:DiffviewClose` | Diffview を閉じる |
| `:DiffviewFileHistory [パス]` | コミット履歴（例: `:DiffviewFileHistory %` で現在のファイル） |
| `:DiffviewToggleFiles` / `:DiffviewRefresh` | ファイルパネルの表示切り替え / 更新 |
| `:Gitsigns <サブコマンド>` | gitsigns の操作（例: `blame`、`diffthis`、`toggle_current_line_blame`、`setqflist`） |

## LSP・フォーマット

| コマンド | 動作 |
| --- | --- |
| `:checkhealth vim.lsp` | 接続中の LSP サーバーと設定を確認（`:LspInfo` の代わり） |
| `:lsp restart [名前]` / `:lsp stop [名前]` | LSP サーバーを再起動 / 停止（Neovim 0.12 の標準コマンド） |
| `:lsp enable [名前]` / `:lsp disable [名前]` | LSP サーバーを有効 / 無効にする |
| `:ConformInfo` | 現在のバッファで使われるフォーマッターとログを表示 |

## Treesitter

| コマンド | 動作 |
| --- | --- |
| `:TSInstall <言語>` | パーサーをインストール（自動インストールは無効） |
| `:TSUpdate` | パーサーを更新 |
| `:TSInstallInfo` | パーサーのインストール状況 |
| `:InspectTree` | 構文木を表示 |
| `:Inspect` | カーソル位置のハイライトグループを表示 |

## プラグイン管理（lazy.nvim）

| コマンド | 動作 |
| --- | --- |
| `:Lazy` | 管理画面を開く |
| `:Lazy update` | プラグインを更新して `lazy-lock.json` を書き換える |
| `:Lazy sync` | インストール・削除・更新をまとめて実行 |
| `:Lazy restore` | `lazy-lock.json` のバージョンに戻す |
| `:Lazy check` | 更新があるか確認 |
| `:Lazy profile` | 起動時間の内訳を表示 |

更新の確認はバックグラウンドで自動実行されます（通知はしません）。

## 表示・その他

| コマンド | 動作 |
| --- | --- |
| `:IBLToggle` / `:IBLToggleScope` | インデントガイド / スコープ表示の切り替え |
| `:Precognition toggle` | モーションヒントの表示切り替え |
| `:HexToggle` / `:HexDump` / `:HexAssemble` | Hex 表示の切り替え / xxd 形式にする / バイナリに戻す |
| `:GithubThemeCompile` | カラースキームを再コンパイル（テーマ設定が反映されないとき） |
| `:Open <パス or URL>` | OS の既定アプリで開く（Neovim 標準） |
| `:checkhealth` | 環境のチェック |
