# 設定値

## ファイル構成

```text
nvim/
├── init.lua              エントリポイント（leader の設定 → config/* → lazy.nvim）
├── lazy-lock.json        プラグインのバージョン固定
├── docs/                 このドキュメント
└── lua/
    ├── config/
    │   ├── options.lua   エディタオプション・autocmd・ファイルタイプ判定
    │   ├── keymaps.lua   基本キーマップ
    │   ├── errorlog.lua  エラーログ（:ErrorLog* コマンド）
    │   └── lazy.lua      lazy.nvim の起動と設定
    └── plugins/          プラグインの spec（ファイルごとに自動で読み込まれる）
        ├── alpha.lua        ダッシュボード
        ├── claude.lua       Claude Code 連携、Snacks（エクスプローラーなど）
        ├── colorscheme.lua  カラースキーム
        ├── completion.lua   補完・スニペット
        ├── editor.lua       コメント・囲み文字・括弧補完・Diffview など
        ├── hex.lua          バイナリ編集
        ├── lsp.lua          LSP・フォーマッター
        ├── php.lua          Blade テンプレート
        ├── telescope.lua    あいまい検索
        ├── treesitter.lua   構文解析
        └── ui.lua           バッファタブ・ステータスライン・gitsigns・which-key など
```

## エディタオプション

定義: `lua/config/options.lua`

### 表示

| オプション | 値 | 説明 |
| --- | --- | --- |
| `number` / `relativenumber` | on / on | 行番号を相対表示（カーソル行は絶対行番号） |
| `signcolumn` | `yes` | サイン列を常に表示 |
| `cursorline` | on | カーソル行を強調 |
| `scrolloff` / `sidescrolloff` | 8 / 8 | カーソルの上下 / 左右に残す行数・列数 |
| `wrap` | off | 長い行を折り返さない |
| `termguicolors` | on | 24bit カラー |
| `showmode` | off | モードはステータスラインに表示 |
| `cmdheight` | 1 | コマンドラインの高さ |
| `pumheight` | 12 | 補完メニューの最大行数 |
| `list` / `listchars` | on / `tab:» ` `trail:·` `nbsp:␣` | タブ・行末スペース・ノーブレークスペースを表示 |
| `fillchars` | `eob: ` | バッファ末尾の `~` を表示しない |
| `winborder` | `rounded` | フロートウィンドウを角丸の枠で表示（LSP の設定を読み込んだ時点で設定） |

### インデント

| オプション | 値 |
| --- | --- |
| `expandtab` | on（スペースでインデント） |
| `shiftwidth` / `tabstop` / `softtabstop` | 4 |
| `smartindent` | on |

ファイルタイプ別:

| ファイルタイプ | インデント |
| --- | --- |
| html, css, scss, javascript, typescript, javascriptreact, typescriptreact, json, jsonc, yaml, lua, nix | 2 スペース |
| go | タブ（幅 4。gofmt に合わせる） |
| その他 | 4 スペース |

### 検索・入力

| オプション | 値 | 説明 |
| --- | --- | --- |
| `ignorecase` / `smartcase` | on / on | 小文字だけなら大文字小文字を区別せず、大文字を含めば区別する |
| `hlsearch` / `incsearch` | on / on | 検索結果をハイライト、入力中から検索 |
| `timeoutlen` | 400 | キーの組み合わせを待つ時間（ms） |
| `updatetime` | 250 | カーソル停止（CursorHold）までの時間（ms）。自動ホバーなどに使う |
| `completeopt` | `menu,menuone,noselect` | 候補が 1 つでもメニューを出し、自動で選択しない |
| `mouse` | `a` | すべてのモードでマウスを使う |
| `clipboard` | `unnamedplus` | ヤンク・削除・貼り付けでシステムのクリップボードを使う |

### ファイル・ウィンドウ

| オプション | 値 | 説明 |
| --- | --- | --- |
| `undofile` | on | ファイルを閉じても undo 履歴を残す |
| `swapfile` / `backup` | off / off | スワップファイルとバックアップを作らない |
| `autoread` | on | 外部での変更を読み込む |
| `splitright` / `splitbelow` | on / on | 縦分割は右、横分割は下に開く |
| `synmaxcol` | 300 | 300 列より右はシンタックスハイライトしない |

Python3 / Ruby / Perl / Node のプロバイダーは無効です。

### ファイルタイプの判定

| ファイル | ファイルタイプ |
| --- | --- |
| `*.v` / `*.vsh` / `*.vv` | `v`（V 言語。Neovim 標準の Verilog 判定を上書き） |
| `*.blade.php` | `blade` |

## 自動で行われる処理

| タイミング | 処理 |
| --- | --- |
| フォーカスが戻る / バッファに入る / カーソルが止まる / ターミナルから戻る | ディスク上の変更を確認して再読み込み（`File changed on disk, buffer reloaded` と通知）。Claude Code の編集がすぐ反映される |
| ヤンク | ヤンクした範囲を 150ms ハイライト |
| 保存 | 300ms 後に LSP の診断（エラー・警告）をエラーログに書き出す |
| LSP が接続 | キーマップを設定し、カーソル停止時の自動ホバーを有効にする |
| `nvim <ファイル>` で起動 | エクスプローラーを開く（カーソルはファイル側） |

### エラーログ

定義: `lua/config/errorlog.lua`

- 場所: `~/.cache/nvim/error.log`（最大 10,000 行。超えると古い行から削除）
- 記録するもの
  - `vim.notify` の WARN / ERROR
  - 保存したファイルの LSP 診断（ERROR / WARN）。保存のたびにそのファイルの古い行を置き換えるので、同じ診断が重複しません
- 形式

```text
[2026-09-29T12:34:56] [notify:ERROR] メッセージ
[2026-09-29T12:34:56] [lsp:WARN] /path/to/file.lua:10:5: メッセージ
```

## 見た目

### カラースキーム

定義: `lua/plugins/colorscheme.lua`

- [github-nvim-theme](https://github.com/projekt0n/github-nvim-theme) の `github_dark_default`
- コメントはイタリック、キーワードは太字
- 上書き: エクスプローラーの未追跡ファイルを緑（`git.add` = `#3fb950`）にしている

### エクスプローラーの Git 色

ファイル名が Git の状態で色分けされます。ディレクトリには中のファイルの状態が反映されます（変更ファイルを含めば黄、未追跡ファイルだけなら緑）。

| 状態 | 色 |
| --- | --- |
| 未追跡（新規ファイル） | 緑 `#3fb950`（この設定で変更。Snacks の既定はグレー） |
| 変更あり（未ステージ） | 黄 `#d29922` |
| ステージ済み | グレー `#7d8590` |
| 削除 / コンフリクト | 赤 `#f85149` |
| `.gitignore` 対象 | グレー `#8b949e`（既定では非表示。`I` で表示） |

Git の状態がないドットファイルもグレーで表示されます。

### その他の見た目

| 対象 | 設定 |
| --- | --- |
| 診断 | 行末に `●` 付きで表示、重要度順に並べる、挿入モード中は更新しない、フロートは角丸 |
| Telescope のファイル検索 | Git で変更のあるファイル（変更・ステージ・リネーム・未追跡）に `●` を付けて黄（`#d0bc00`、太字）で表示 |
| ステータスライン（lualine） | 全ウィンドウで 1 本。左からモード / ブランチ・差分・診断 / ファイルパス / エンコーディング・改行コード・ファイルタイプ / 進捗 / 行:列 |
| バッファタブ（bufferline） | 常に表示、LSP の診断数を表示、サイドバーの上には `EXPLORER` / `CLAUDE CODE` のラベル |
| gitsigns | サイン列に `▎` などで表示、ステージ済みの変更も表示、未追跡ファイルにも表示、カーソル行の blame を 400ms 後に行末へ表示（`作者, 日付 · コミットメッセージ`） |
| インデントガイド | `▏` で表示、カーソル位置のスコープを強調。help / alpha / dashboard / lazy / mason / notify では非表示 |
| 通知（nvim-notify） | コンパクト表示、フェード、2.5 秒で消える |
| which-key | `modern` プリセット |
| モーションヒント（precognition） | 起動時から表示 |
| ダッシュボード | Neovim のロゴ、ボタン、日付・時刻（1 秒ごとに更新）・プラグイン数・バージョン |

## プラグイン一覧

「読み込み」は、そのプラグインが読み込まれるタイミングです。

| プラグイン | 用途 | 読み込み | 定義 |
| --- | --- | --- | --- |
| lazy.nvim | プラグイン管理 | 起動時 | `config/lazy.lua` |
| github-nvim-theme | カラースキーム | 起動時 | `colorscheme.lua` |
| snacks.nvim | エクスプローラー、ターミナル、入力 UI、画像表示、バッファ削除 | 起動時 | `claude.lua` |
| claudecode.nvim | Claude Code 連携 | キー / コマンド | `claude.lua` |
| alpha-nvim + ascii.nvim | ダッシュボード | 起動直後 | `alpha.lua` |
| nvim-cmp + cmp-nvim-lsp / cmp-buffer / cmp-path / cmp-cmdline / cmp_luasnip | 補完 | 挿入モードに入ったとき | `completion.lua` |
| LuaSnip + friendly-snippets | スニペット | 補完と一緒 | `completion.lua` |
| nvim-lspconfig + fidget.nvim | LSP の設定、進捗表示 | ファイルを開いたとき | `lsp.lua` |
| conform.nvim | フォーマッター | 保存時 / `<leader>cf` / `:ConformInfo` | `lsp.lua` |
| nvim-treesitter + nvim-treesitter-textobjects | 構文ハイライト、インデント、選択 | ファイルを開いたとき | `treesitter.lua` |
| telescope.nvim + telescope-fzf-native / telescope-live-grep-args | あいまい検索 | キー / コマンド | `telescope.lua` |
| bufferline.nvim | バッファタブ | 起動後 | `ui.lua` |
| lualine.nvim | ステータスライン | 起動後 | `ui.lua` |
| gitsigns.nvim | Git の差分表示、hunk 操作、blame | ファイルを開いたとき | `ui.lua` |
| indent-blankline.nvim | インデントガイド | ファイルを開いたとき | `ui.lua` |
| which-key.nvim | キーのヒント | 起動後 | `ui.lua` |
| nvim-notify | 通知 | 最初の通知 | `ui.lua` |
| nvim-web-devicons | ファイルアイコン | 必要なとき | `ui.lua` |
| Comment.nvim | コメント切り替え | ファイルを開いたとき | `editor.lua` |
| nvim-surround | 囲み文字の操作 | ファイルを読み込んだとき | `editor.lua` |
| nvim-autopairs | 括弧の自動補完 | 挿入モードに入ったとき | `editor.lua` |
| mini.bufremove | バッファ削除 | キー | `editor.lua` |
| precognition.nvim | モーションヒント | ファイルを開いたとき | `editor.lua` |
| todo-comments.nvim | TODO / FIXME などのハイライトと検索 | ファイルを開いたとき | `editor.lua` |
| diffview.nvim | Git の差分ビュー | キー / コマンド | `editor.lua` |
| hex.nvim | バイナリの Hex 編集 | キー / コマンド | `hex.lua` |
| vim-blade | Blade のハイライトとインデント | Blade ファイルを開いたとき | `php.lua` |

todo-comments がハイライトするキーワード: `TODO`、`FIX`（`FIXME` / `BUG` / `FIXIT` / `ISSUE`）、`HACK`、`WARN`（`WARNING` / `XXX`）、`PERF`（`OPTIM` / `PERFORMANCE` / `OPTIMIZE`）、`NOTE`（`INFO`）、`TEST`（`TESTING` / `PASSED` / `FAILED`）

## LSP サーバー

定義: `lua/plugins/lsp.lua`。サーバーは Nix でインストールし、`$PATH` にあるものを使います。

| サーバー | 言語 | コマンド | 主な設定 |
| --- | --- | --- | --- |
| `gopls` | Go | `gopls` | 解析 `unusedparams` / `shadow`、`staticcheck`、`gofumpt` |
| `ts_ls` | JavaScript / TypeScript / JSX / TSX / Vue | `typescript-language-server` | Vue の `<script>` 用に `@vue/typescript-plugin` を読み込む（下の注意点を参照） |
| `vue_ls` | Vue（テンプレート・スタイル） | `vue-language-server` | 既定 |
| `html` / `cssls` / `jsonls` / `eslint` | HTML / CSS / JSON / ESLint | `vscode-*-language-server` | 既定 |
| `intelephense` | PHP / Laravel | `intelephense` | ファイルサイズの上限 5MB、PHP 8.3 |
| `clangd` | C / C++ / Objective-C | `clangd` | `--background-index` `--clang-tidy` `--header-insertion=iwyu` `--completion-style=detailed` `--function-arg-placeholders` |
| `asm_lsp` | アセンブリ | `asm-lsp` | 既定 |
| `bashls` | Bash | `bash-language-server` | 既定 |
| `nil_ls` | Nix | `nil` | 既定 |
| `lua_ls` | Lua | `lua-language-server` | LuaJIT、`vim` をグローバルとして認識、Neovim のランタイムをライブラリに追加 |

- すべてのサーバーに nvim-cmp の補完機能を渡しています。
- V 言語の `v_analyzer` は nixpkgs にないため無効です（フォーマットの `v fmt` は使えます）。
- サーバーを追加するときは、`lsp.lua` の `servers` と、Nix のパッケージ（`darwin/configuration.nix` / `nixos/configuration.nix`）の両方に追加します。

### 診断の表示

| 項目 | 設定 |
| --- | --- |
| 行末の表示 | `●` 付き、間隔 4 |
| 並び順 | 重要度順 |
| 挿入モード中 | 更新しない |
| フロート | 角丸の枠。複数のサーバーがあるときは出どころを表示 |

## フォーマッター

定義: `lua/plugins/lsp.lua`（conform.nvim）

| 言語 | フォーマッター |
| --- | --- |
| Go | gofumpt → goimports（順に両方実行） |
| JavaScript / TypeScript / JSX / TSX / Vue / HTML / CSS / SCSS / JSON / YAML / Markdown | prettierd（なければ prettier） |
| C / C++ | clang-format |
| Lua | stylua |
| Nix | nixpkgs-fmt |
| Shell（`sh`） | shfmt |
| PHP | Pint（プロジェクトの `vendor/bin/pint`、なければ `$PATH` の `pint`）。Pint がなければ php-cs-fixer |
| V | `v fmt -w` |

- 手動: `<leader>cf`（非同期。フォーマッターがなければ LSP でフォーマット）
- 保存時: **既定では無効**。`:FormatEnable` で有効にすると、保存時に最大 1.5 秒でフォーマットします（フォーマッターがなければ LSP）

## Treesitter

定義: `lua/plugins/treesitter.lua`（nvim-treesitter の `master` ブランチ）

- ハイライト・インデント・範囲選択（`<C-Space>` / `<BS>`）が有効
- 自動インストールは無効。下にない言語は `:TSInstall <言語>` で入れる
- Neovim 0.12 で `master` ブランチが動くようにする互換処理を入れている

インストールするパーサー:

| 分類 | パーサー |
| --- | --- |
| Go | go, gomod, gosum, gowork |
| Web | html, css, scss, javascript, typescript, tsx, vue, php, php_only, phpdoc, json, jsonc, yaml, toml |
| 低レイヤー | c, cpp, asm, make, cmake |
| V | v |
| 設定・その他 | lua, vim, vimdoc, query, bash, nix, markdown, markdown_inline, diff, git_config, gitcommit, gitignore, gitattributes, regex, comment |

## 補完

定義: `lua/plugins/completion.lua`

| 項目 | 設定 |
| --- | --- |
| 候補の出どころ（優先度順） | LSP → スニペット → パス。これらに候補がないときだけバッファ内の単語（3 文字以上） |
| 表示 | 種類のアイコン・候補・出どころ（`[LSP]` / `[Snip]` / `[Path]` / `[Buf]`）。枠は角丸 |
| ゴーストテキスト | 有効（確定前の候補を薄く表示） |
| スニペット | friendly-snippets（VSCode 形式）を LuaSnip で読み込む |
| コマンドライン | `/` と `?` はバッファ内の単語、`:` はパスとコマンド |

## Telescope

定義: `lua/plugins/telescope.lua`

| 項目 | 設定 |
| --- | --- |
| 除外 | `.git/`、`node_modules/`、`.cache/`、`target/` |
| ファイル検索 | 隠しファイルも対象 |
| 文字列検索 | `<leader>fg` などは live_grep_args（入力をそのまま rg の引数として扱う）。隠しファイルは対象外なので、必要なら `--hidden` を付ける。ダッシュボードの `g`（live_grep）は隠しファイルも対象 |
| 並び替え | fzf-native（smart case） |
| パス表示 | 長いパスは省略 |

## Snacks

定義: `lua/plugins/claude.lua`

| 機能 | 設定 |
| --- | --- |
| エクスプローラー | 左のサイドバー（幅 35）、隠しファイルを表示、Git 状態と診断を表示、現在のファイルに追従、ファイルを開いても閉じない、netrw の代わりに使う |
| ターミナル | Claude Code の表示に使用。フロートで開くときは角丸の枠 |
| 入力 UI | 有効（名前変更などの入力欄） |
| 画像 | 有効（kitty のグラフィックプロトコルで画像を表示） |
| 通知 | 無効（nvim-notify を使う） |

## lazy.nvim

定義: `lua/config/lazy.lua`

| 項目 | 設定 |
| --- | --- |
| 更新チェック | バックグラウンドで自動実行（通知なし） |
| 設定ファイルの変更検知 | 通知なし |
| 無効にした標準プラグイン | gzip、tarPlugin、tohtml、tutor、zipPlugin、netrwPlugin |

## 既知の注意点

実際の動作を確認して見つかった点です。

1. **Treesitter のテキストオブジェクトと移動キーが動かない**
   `treesitter.lua` には `af` / `if` / `ac` / `ic` / `aa` / `ia` と `]f` / `[f` / `]c` / `[c` を設定していますが、キーマップが作られていません。nvim-treesitter は `master` ブランチなのに、nvim-treesitter-textobjects は `main` ブランチ（`lazy-lock.json`）が入っていて、`main` ブランチは `nvim-treesitter.configs` の `textobjects` 設定を読まないためです。依存関係に `branch = "master"` を指定すれば読まれるはずです（未確認）。
2. **`<leader>cl`（`:LspInfo`）がエラーになる**
   Neovim 0.12 には標準の `:lsp` コマンドがあるため、nvim-lspconfig が `:LspInfo` を作りません。代わりに `:checkhealth vim.lsp` を使います。
3. **`<leader>p` はビジュアルモード専用**
   ノーマルモードで押しても何も起きません。
4. **`<leader>bd` が 2 か所で定義されている**
   `ui.lua`（bufferline の spec。`Snacks.bufdelete()`）と `editor.lua`（mini.bufremove）の両方にあり、`ui.lua` 側が使われます。
5. **`<S-h>` / `<S-l>` が 2 か所で定義されている**
   `keymaps.lua` の `:bprevious` / `:bnext` は、`ui.lua` の bufferline 版（`BufferLineCyclePrev` / `Next`）に上書きされています。
6. **macOS では Vue の `<script>` で TypeScript の補完が効かない**
   `lsp.lua` は `@vue/typescript-plugin` を `/nix/store` の中からしか探しません。macOS の `vue-language-server` は Homebrew の npm 版（`/opt/homebrew/lib/node_modules`）で、`darwin/configuration.nix` には入っていないため、プラグインが見つからずに無効になります（テンプレートの機能は動きます）。
7. **macOS の kitty では Alt のキーが届かない**
   `kitty/kitty.conf`（と macOS 用の `macos.conf`）に `macos_option_as_alt` がないため、`<M-e>`（Fast Wrap）やエクスプローラーの `<a-h>` などの Alt キーは使えません。
8. **Hex の自動変換は hex.nvim が読み込まれてから**
   バイナリファイルを開いたときの xxd 表示への自動変換は、`<leader>x…` や `:Hex…` で hex.nvim を一度読み込んだあとから有効になります。
