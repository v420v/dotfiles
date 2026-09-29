# Neovim 設定ガイド

`~/dotfiles/nvim` の Neovim 設定の使い方です。
現在の設定ファイル（`nvim/lua/**`）と、`lazy-lock.json` で固定されたプラグインの挙動をもとに書いています。

| ドキュメント | 内容 |
| --- | --- |
| [keymaps.md](keymaps.md) | キーマップ一覧 |
| [commands.md](commands.md) | コマンド一覧 |
| [settings.md](settings.md) | オプション・見た目・プラグイン・LSP・フォーマッターの設定値、既知の注意点 |

## 前提

- **Neovim 0.12**（0.12.4 で確認）
- **設定の場所**: home-manager（`home/common.nix`）が `~/.config/nvim` → `~/dotfiles/nvim` のシンボリックリンクを張っています。リポジトリを編集して nvim を再起動すれば反映されます（`home-manager switch` は不要）。
- **プラグイン管理**: [lazy.nvim](https://github.com/folke/lazy.nvim)。バージョンは `nvim/lazy-lock.json` で固定。
- **LSP サーバー・フォーマッター**: Mason は使わず Nix でインストール（`darwin/configuration.nix` / `nixos/configuration.nix`）。
- **フォント**: Nerd Font（アイコン表示に必要）
- **ターミナル**: kitty 推奨（フォントサイズ変更キーと画像プレビューが kitty の機能を使います）
- **リーダーキー**: `Space`（以降 `<leader>` と表記）

## 起動

| コマンド | 動作 |
| --- | --- |
| `nvim` | ダッシュボードを表示 |
| `nvim <ファイル>` | ファイルを開き、左にエクスプローラーも開く（カーソルはファイル側） |
| `nvim .` / `nvim <ディレクトリ>` | エクスプローラーを開く（netrw の代わり） |

ダッシュボードのキー:

| キー | 動作 |
| --- | --- |
| `o` | エクスプローラー |
| `f` | ファイル検索 |
| `i` | 新規ファイル |
| `t` | 一時ファイルを編集 |
| `r` | 最近開いたファイル |
| `g` | 文字列検索（live grep） |
| `l` | Lazy（プラグイン管理画面） |
| `h` | `:checkhealth` |
| `q` | 終了 |

## 画面構成

VSCode / Zed 風の 3 カラムです。

```text
+-------------+---------------------------------+---------------+
| EXPLORER    | [a.lua] [b.lua] [c.lua]         | CLAUDE CODE   |  <- bufferline
+-------------+---------------------------------+---------------+
| file tree   |                                 | claude        |
| (Snacks)    |            editor               | (terminal)    |
|             |                                 |               |
+-------------+---------------------------------+---------------+
| statusline (lualine)                                          |
+---------------------------------------------------------------+
```

- **エクスプローラー**（左、幅 35）: `<leader>e` で表示/非表示、`-` で現在のファイルの位置を表示
- **バッファタブ**（上）: 開いたファイルがタブとして並ぶ。`Shift-h` / `Shift-l` で切り替え、`<leader>bd` で閉じる
- **Claude Code**（右、幅 35%）: `<leader>cc` で表示/非表示
- **ステータスライン**: モード / ブランチ・差分・診断 / ファイルパス / エンコーディング・改行コード・ファイルタイプ / 進捗 / 行:列

## 基本的な使い方

### キーを忘れたら

- `Space` を押して 0.4 秒待つと、which-key が続きのキーを表示します
- `<leader>fk` でキーマップを、`<leader>fc` でコマンドを検索できます

### ファイルを開く・探す

| やりたいこと | キー |
| --- | --- |
| ファイル名で探す | `<leader>ff` |
| 文字列で探す | `<leader>fg` |
| 最近開いたファイル | `<leader>fr` |
| 開いているバッファ | `<leader>fb` / `Shift-h` / `Shift-l` |
| ツリーから開く | `<leader>e` → `j`/`k` で移動して `Enter` |

`<leader>ff` では、Git で変更があるファイルに `●` が付いて黄色で表示されます。

### エクスプローラーでのファイル操作

`a` 新規作成（末尾に `/` でディレクトリ）、`r` 名前変更、`d` 削除、`c` コピー、`m` 移動、`y` / `p` パスのコピー / 貼り付け、`?` キー一覧。
ファイル名は Git の状態で色分けされます（未追跡 = 緑、変更 = 黄、削除 = 赤 など。[settings.md](settings.md#エクスプローラーの-git-色)）。

### コード編集（LSP）

対応言語のファイルを開くと LSP が自動で起動します（対応言語は [settings.md](settings.md#lsp-サーバー)）。

- `gd` 定義へ、`gr` 参照、`K` ホバー（カーソルを止めるだけでも自動表示）、`<leader>rn` リネーム、`<leader>la` コードアクション、`]d` / `[d` 診断へ移動
- VSCode のように `Cmd+クリック`（Linux では `Ctrl+クリック`）で定義へジャンプ、`<C-o>` で戻る
- 補完は入力中に自動で出ます。`Tab` / `Shift-Tab` で選択、`Enter` で確定
- フォーマットは `<leader>cf`。保存時の自動フォーマットは**既定で無効**（`:FormatEnable` で有効化）

### Git

- 変更行の左端にサインが出ます。`]h` / `[h` で移動、`<leader>hp` でプレビュー、`<leader>hs` でステージ、`<leader>hr` で元に戻す
- カーソル行の blame が行末に表示されます（`<leader>hB` で切り替え）
- `<leader>gd` で変更一覧と差分（Diffview）。ファイルパネルで `-` でステージ、`<leader>gq` で閉じる
- `<leader>gs` Git status、`<leader>gc` コミット一覧、`<leader>gH` 現在のファイルの履歴

### Claude Code

1. `<leader>cc` で右側に Claude Code を起動
2. コンテキストを渡す
   - `<leader>cb`: 現在のファイル
   - ビジュアル選択して `<leader>cs`: 選択範囲
   - エクスプローラーでファイルにカーソルを合わせて `<leader>cs`（`Tab` で複数選択可）
   - Telescope の結果で `Ctrl-a`
3. Claude が変更を提案すると差分が開きます。`<leader>ca`（または `:w`）で承認、`<leader>cd` で拒否
4. Claude がファイルを書き換えると、開いているバッファは自動で再読み込みされます

Claude の入力欄では `Shift-Enter` で改行、`Esc` 2 回でノーマルモード（スクロールやコピー用）、`i` で入力に戻ります。

### エラーログ

nvim のエラー・警告と、保存時の LSP 診断（エラー・警告）が `~/.cache/nvim/error.log` に記録されます。
Claude Code などの外部ツールが nvim を開かずにエラーを読めるようにするためのものです（`:ErrorLogPath` / `:ErrorLogClear` / `:ErrorLogDump`）。

## 設定を変更するには

| 変更したいもの | 場所 |
| --- | --- |
| エディタオプション・autocmd | `lua/config/options.lua` |
| 基本キーマップ | `lua/config/keymaps.lua` |
| プラグインのキーマップ | 各プラグイン spec の `keys`（`lua/plugins/*.lua`） |
| プラグインの追加 | `lua/plugins/` に spec を追加 → nvim を再起動すると自動でインストール |
| LSP サーバーの追加 | `lua/plugins/lsp.lua` の `servers` と、Nix 側（`darwin/configuration.nix` / `nixos/configuration.nix`）の両方 |
| プラグインの更新 | `:Lazy update` → 更新された `lazy-lock.json` をコミット |
