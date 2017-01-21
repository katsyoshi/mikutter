# frozen_string_literal: true
# -*- coding: utf-8 -*-

require 'gtk2'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'utils'))
miquire :mui, 'crud'

=begin rdoc
  複数選択ウィジェットを作成する。
  これで作成されたウィジェットは、チェックボックスで複数の項目が選択できる。
  各項目は文字列でしか指定できない。
=end

class Gtk::SelectBox < Gtk::CRUD
  ITER_CHECK = 0
  ITER_STRING = 1
  ITER_ID = 2

  include Gtk::TreeViewPrettyScroll

  # _values_ は、{結果に含む値 => 表示される文字列}のHashか、
  # [[結果に含む値, 表示される文字列]]のような配列。
  # 結果に含む値が none の場合、その項目は選択できなくなる
  # _selected_ は、選択されている項目のリスト。<<とdeleteとinclude?を実装している必要がある
  def initialize(values, selected, none=nil, &changed_hook)
    type_strict values => :each
    @selected = ((selected.dup or []) rescue [])
    @none = none
    @changed_hook = changed_hook
    super()
    self.creatable = self.updatable = self.deletable = false
    setting_values values, selected end

  def selected
    @selected.freeze.lazy.select{|_|_ != @none}
  end

  private

  # 初期設定。コンストラクタに渡された項目をListViewに登録する
  def setting_values(values, selected)
    values.each{ |pair|
      id, string = *pair
      iter = model.append
      iter[ITER_ID] = id
      iter[ITER_STRING] = string
      iter[ITER_CHECK] = (selected and @selected.include?(id)) } end

  def column_schemer
    [ { :kind => :active, :widget => :boolean, :type => TrueClass, :label => '選択' },
      { :kind => :text, :widget => :input, :type => String, :label => '項目' },
      { :type => Object }
    ].freeze
  end

  def add_selected(id)
    @selected = @selected.melt
    @selected << id
  end

  def delete_selected(id)
    @selected = @selected.melt
    @selected.delete(id)
  end

  def on_updated(iter)
    if(iter[ITER_CHECK])
      if iter[ITER_ID] == @none
        iter[ITER_CHECK] = false
      else
        add_selected(iter[ITER_ID]) end
    else
      delete_selected(iter[ITER_ID]) end
    if @changed_hook
      @changed_hook.call(*[selected][0, @changed_hook.arity]) end end end
