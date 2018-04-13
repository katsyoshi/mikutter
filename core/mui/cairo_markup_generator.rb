# -*- coding: utf-8 -*-

require 'gtk2'
miquire :lib, 'diva_hacks'

module Pango
  ESCAPE_RULE = {'&': '&amp;'.freeze ,'>': '&gt;'.freeze, '<': '&lt;'.freeze}.freeze
  class << self

    # テキストをPango.parse_markupで安全にパースできるようにエスケープする。
    def escape(text)
      text.gsub(/[<>&]/){|m| ESCAPE_RULE[m] }
    end

    alias old_parse_markup parse_markup

    # パースエラーが発生した場合、その文字列をerrorで印字する。
    def parse_markup(str)
      begin
        old_parse_markup(str)
      rescue GLib::Error => e
        error str
        raise e end end end end

=begin rdoc
  本文の、描画するためのテキストを生成するモジュール。
=end

module Gdk::MarkupGenerator
  # 表示する際に本文に適用すべき装飾オブジェクトを作成する
  # ==== Return
  # Pango::AttrList 本文に適用する装飾
  def description_attr_list(attr_list=Pango::AttrList.new)
    Plugin[:gtk].score_of(message).inject(0){|start_index, note|
      end_index = start_index + note.title.bytesize
      if !note.respond_to?(:ancestor)
        underline = Pango::AttrUnderline.new(Pango::Underline::SINGLE)
        underline.start_index = start_index
        underline.end_index = end_index
        attr_list.insert(underline)
      end
      end_index
    }
    attr_list
  end

  # Entityを適用したあとのプレーンテキストを返す。
  def plain_description
    Plugin[:gtk].score_of(message).inject(''){|memo, item| memo + item.title }
  end

end
