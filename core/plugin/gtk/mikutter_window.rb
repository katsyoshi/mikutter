# -*- coding: utf-8 -*-

require "gtk3"
require File.expand_path(File.join(File.dirname(__FILE__), 'toolbar_generator'))
require File.expand_path(File.join(File.dirname(__FILE__), 'account_box'))

class Gtk::MikutterWindow < Gtk::Window

  attr_reader :panes, :statusbar

  def initialize(imaginally, plugin, *args)
    type_strict plugin => Plugin
    super(*args)
    @imaginally = imaginally
    @plugin = plugin
    @container = Gtk::VBox.new(false, 0)
    @panes = Gtk::HBox.new(true, 0)
    account = Gtk::AccountBox.new
    header = Gtk::HBox.new(false, 0)
    @postboxes = Gtk::VBox.new(false, 0)
    add @container.
      closeup(header.
              closeup(account).
              pack_start(@postboxes)).
      pack_start(@panes).
      closeup(create_statusbar)
    Plugin[:gtk].on_service_registered do |service|
      refresh end
    Plugin[:gtk].on_service_destroyed do |service|
      refresh end
  end

  def add_postbox(i_postbox)
    options = {postboxstorage: @postboxes, delegate_other: true}.merge(i_postbox.options||{})
    if options[:delegate_other]
      i_window = i_postbox.ancestor_of(Plugin::GUI::Window)
      options[:delegate_other] = postbox_delegation_generator(i_window) end
    postbox = Gtk::PostBox.new(options)
    @postboxes.pack_start(postbox)
    set_focus(postbox.post) unless options[:delegated_by]
    postbox.no_show_all = false
    postbox.show_all if not Service.to_a.empty?
    postbox end

  private

  def postbox_delegation_generator(window)
    ->(params) do
      postbox = Plugin::GUI::Postbox.instance
      postbox.options = params
      window << postbox end end

  def refresh
    if Service.to_a.empty?
      @postboxes.children.each(&:hide)
    else
      @postboxes.children.each(&:show_all) end end

  # ステータスバーを返す
  # ==== Return
  # Gtk::Statusbar
  def create_statusbar
    statusbar = Gtk::Statusbar.new
    statusbar.push(statusbar.get_context_id("system"), @plugin._("Statusbar default message"))
    @statusbar = statusbar.closeup(status_button(Gtk::HBox.new)) end

  # ステータスバーに表示するWindowレベルのボタンを _container_ にpackする。
  # 返された時点では空で、後からボタンが入る(showメソッドは自動的に呼ばれる)。
  # ==== Args
  # [container] packするコンテナ
  # ==== Return
  # container
  def status_button(container)
    Plugin::Gtk::ToolbarGenerator.generate(container,
                                           Plugin::GUI::Event.new(:window_toolbar, @imaginally, []),
                                           :window) end

end
