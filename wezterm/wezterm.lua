-- WezTerm 設定ファイル

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- カラースキーム
config.color_scheme = 'Afterglow'

-- フォント設定
config.font = wezterm.font_with_fallback({
  '0xProto Nerd Font',
  'HackGenNerd',
  'Menlo',
})

config.font_size = 13.0
config.line_height = 1.2

-- ウィンドウ設定
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}

config.window_decorations = 'RESIZE'
config.window_background_opacity = 0.90
config.text_background_opacity = 1.0

-- タブバー設定
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = true
config.show_tab_index_in_tab_bar = false

-- カーソル設定
config.default_cursor_style = 'SteadyBlock'

-- スクロールバー設定
config.enable_scroll_bar = true

-- キーバインド設定
config.keys = {
  -- タブ操作
  {
    key = 't',
    mods = 'CMD',
    action = wezterm.action { SpawnTab = 'CurrentPaneDomain' },
  },
  {
    key = 'w',
    mods = 'CMD',
    action = wezterm.action { CloseCurrentTab = { confirm = true } },
  },
  {
    key = 'n',
    mods = 'CMD',
    action = wezterm.action { SpawnCommandInNewWindow = {} },
  },
  -- ペイン分割
  {
    key = 'd',
    mods = 'CMD',
    action = wezterm.action { SplitHorizontal = { domain = 'CurrentPaneDomain' } },
  },
  {
    key = 'd',
    mods = 'CMD|SHIFT',
    action = wezterm.action { SplitVertical = { domain = 'CurrentPaneDomain' } },
  },
  -- ペイン移動
  {
    key = 'h',
    mods = 'CMD',
    action = wezterm.action { ActivatePaneDirection = 'Left' },
  },
  {
    key = 'l',
    mods = 'CMD',
    action = wezterm.action { ActivatePaneDirection = 'Right' },
  },
  {
    key = 'k',
    mods = 'CMD|SHIFT',
    action = wezterm.action { ActivatePaneDirection = 'Up' },
  },
  {
    key = 'j',
    mods = 'CMD|SHIFT',
    action = wezterm.action { ActivatePaneDirection = 'Down' },
  },
  -- ペインサイズ調整
  {
    key = 'H',
    mods = 'CMD|SHIFT',
    action = wezterm.action { AdjustPaneSize = { 'Left', 5 } },
  },
  {
    key = 'L',
    mods = 'CMD|SHIFT',
    action = wezterm.action { AdjustPaneSize = { 'Right', 5 } },
  },
  {
    key = 'K',
    mods = 'CMD|SHIFT',
    action = wezterm.action { AdjustPaneSize = { 'Up', 5 } },
  },
  {
    key = 'J',
    mods = 'CMD|SHIFT',
    action = wezterm.action { AdjustPaneSize = { 'Down', 5 } },
  },
  -- ペイン削除
  {
    key = 'x',
    mods = 'CMD|SHIFT',
    action = wezterm.action { CloseCurrentPane = { confirm = true } },
  },
}

-- マウス設定
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = wezterm.action { PasteFrom = 'Clipboard' },
  },
}

-- 起動時のシェル（ログインシェルとして起動して .zshrc を読み込む）
config.default_prog = { '/bin/zsh', '-l' }

-- 警告音を無効化
config.audible_bell = 'Disabled'

-- ベルを無効化
config.visual_bell = {
  fade_in_function = 'EaseIn',
  fade_in_duration_ms = 0,
  fade_out_function = 'EaseOut',
  fade_out_duration_ms = 0,
}

-- 設定を返す
return config
