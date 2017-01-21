# frozen_string_literal: true
# -*- coding: utf-8 -*-
require 'gtk2'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'utils'))
miquire :core, 'message', 'skin'
miquire :mui, 'mtk'
miquire :mui, 'extension'
miquire :mui, 'webicon'
miquire :miku, 'miku'

class Gtk::MessagePicker < Gtk::EventBox
  DEFAULT_CONDITION = [:==, :user, ''.freeze].freeze

  def initialize(conditions, &block)
    conditions = [] unless conditions.is_a? MIKU::List
    super()
    @not = (conditions.respond_to?(:car) and (conditions.car == :not))
    if(@not)
      conditions = (conditions[1] or []).freeze end
    @changed_hook = block
    shell = Gtk::VBox.new
    @container = Gtk::VBox.new
    @function, *exprs = *conditions.to_a
    @function ||= :and
    shell.add(@container)
    shell.closeup(add_button.center)
    exprs.each{|x| add_condition(x) }
    add(Gtk::Frame.new.set_border_width(8).set_label_widget(option_widgets).add(shell))
  end

  def function(new = @function)
    (new ? :or : :and) end

  def option_widgets
    @option_widgets ||= Gtk::HBox.new.
      closeup(Mtk::boolean(lambda{ |new|
                             unless new.nil?
                               @function = function(new)
                               call end
                             @function == :or },
                           'いずれかにマッチする')).
      closeup(Mtk::boolean(lambda{ |new|
                             unless new.nil?
                               @not = new
                               call end
                             @not },
                           '否定')) end

  def add_button
    @add_button ||= gen_add_button end

  def add_condition(expr = DEFAULT_CONDITION)
    pack = Gtk::HBox.new
    close = Gtk::Button.new.add(Skin['close.png'].pixbuf(width: 16, height: 16)).set_relief(Gtk::RELIEF_NONE)
    close.signal_connect(:clicked){
      @container.remove(pack)
      pack.destroy
      call
      false }
    pack.closeup(close.top)
    case expr.first
    when :and, :or, :not
      pack.add(Gtk::MessagePicker.new(expr, &method(:call)))
    else
      pack.add(Gtk::MessagePicker::PickCondition.new(expr, &method(:call))) end
    @container.closeup(pack) end

  def to_a
    result = [@function, *@container.children.map{|x| x.children.last.to_a}.reject(&:empty?)].freeze
    if result.size == 1
      [].freeze
    else
      if @not
        result = [:not, result].freeze end
      result end end

  private

  def call
    if @changed_hook
      @changed_hook.call end end

  def gen_add_button
    container = Gtk::HBox.new
    btn = Gtk::Button.new('条件を追加')
    btn.signal_connect(:clicked){
      add_condition.show_all }
    btn2 = Gtk::Button.new('サブフィルタを追加')
    btn2.signal_connect(:clicked){
      add_condition([:and, DEFAULT_CONDITION]).show_all }
    container.closeup(btn).closeup(btn2) end

  class PickCondition < Gtk::HBox
    def initialize(conditions = DEFAULT_CONDITION, *args, &block)
      super(*args)
      @changed_hook = block
      @condition, @subject, @expr = *conditions.to_a
      build
    end

    def to_a
      [@condition, @subject, @expr].freeze end

    private

    def call
      if @changed_hook
        @changed_hook.call end end

    def build
      extract_condition = Hash[Plugin.filtering(:extract_condition, []).first.map{|ec| [ec.slug, ec]}]
      w_argument = Mtk::input(lambda{ |new|
                                unless new === nil
                                  @expr = new.freeze
                                  call end
                                @expr },
                              nil)
      w_operator = Mtk::chooseone(lambda{ |new|
                                    unless new === nil
                                      @condition = new.to_sym
                                      call end
                                    @condition.to_s },
                                  nil,
                                  Hash[Plugin.filtering(:extract_operator, []).first.map{ |eo| [eo.slug.to_s, eo.name] }])
      w_condition = Mtk::chooseone(lambda{ |new|
                                     unless new === nil
                                       @subject = new.to_sym
                                       call end
                                     sensitivity = extract_condition[@subject][:operator] && 0 != extract_condition[@subject][:args]
                                     w_argument.set_sensitive(sensitivity)
                                     w_operator.set_sensitive(sensitivity)
                                     @subject.to_s },
                                   nil,
                                   Hash[extract_condition.map{ |slug, ec| [slug.to_s, ec.name] }])
      closeup(w_condition)
      closeup(w_operator)
      add(w_argument)
    end
  end

end
