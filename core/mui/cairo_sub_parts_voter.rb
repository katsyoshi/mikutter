# -*- coding: utf-8 -*-

miquire :mui, 'sub_parts_helper'

require 'gtk3'
require 'cairo'

class ::Gdk::SubPartsVoter < Gdk::SubParts

  attr_reader :votes, :icon_width, :icon_height, :margin

  def initialize(*args)
    super
    @icon_width, @icon_height, @margin, @votes, @user_icon = 24, 24, 2, get_default_votes.to_a, Hash.new
    @avatar_rect = []
    @icon_ofst = 0
    helper.ssc(:click){ |this, e, x, y|
      ofsty = helper.mainpart_height
      helper.subparts.each{ |part|
        break if part == self
        ofsty += part.height }
      if ofsty <= y and (ofsty + height) >= y
        case e.button
        when 1
          if(x >= @icon_ofst)
            user = get_user_by_point(x)
            if user
              Plugin.call(:open, user)
            end
          end
        end
      end
      false
    }
    last_motion_user = nil
    usertip = Gtk::Tooltips.instance
    helper.ssc(:motion_notify_event){ |this, x, y|
      if 0 != height
        tipset = ''
        ofsty = helper.mainpart_height
        helper.subparts.each{ |part|
          break if part == self
          ofsty += part.height }
        if ofsty <= y and (ofsty + height) >= y
          if(x >= @icon_ofst)
            user = get_user_by_point(x)
            last_motion_user = user
            if user
              tipset = user.idname end end end
        usertip.set_tip(helper.tree, tipset, '')
        if tipset == ''
          last_motion_user = nil
          usertip.disable
        else
          usertip.enable end end
      false }
    helper.ssc(:leave_notify_event){
      usertip.set_tip(helper.tree, '', '')
      usertip.disable
      false
    }
  end

  def get_user_by_point(x)
    if(x >= @icon_ofst)
      node = @avatar_rect.each_with_index.to_a.bsearch{|_| _[0].last > x }
      if node
        @votes[node.last] end end end

  def render(context)
    if get_vote_count != 0
      context.save{
        context.translate(@margin, 0)
        put_title_icon(context)
        put_counter(context)
        put_voter(context) } end
    @last_height = height end

  def height
    if get_vote_count == 0
      0
    else
      icon_height end end

  def add(new)
    if UserConfig[:"#{name}_by_anyone_show_timeline"]
      if not @votes.include?(new)
        before_height = height
        @votes << new
        if(before_height == height)
          helper.on_modify
        else
          helper.reset_height end
        self end end end
  alias << add

  def delete(user)
    if UserConfig[:"#{name}_by_anyone_show_timeline"]
      if not @votes.include?(user)
        before_height = height
        @votes.delete(user)
        if(before_height == height)
          helper.on_modify
        else
          helper.reset_height end
        self end end end

  def name
    raise end

  # このSubPartsのアイコンのPixbufを返す。
  # title_icon_model メソッドをオーバライドしない場合、こちらを必ずオーバライドしなければならない
  def title_icon
    title_icon_model.pixbuf(width: @icon_width, height: @icon_height)
  end

  # このSubPartsのアイコンをあらわすModelを返す。
  # title_icon の内部でしか使われないので、このメソッドを使わないように title_icon を再定義した場合は
  # このメソッドをオーバライドする必要はない。
  def title_icon_model
    raise
  end

  private

  def put_title_icon(context)
    context.save{
      context.set_source_pixbuf(title_icon)
      context.paint }
  end

  def put_counter(context)
    plc = pl_count(context)
    context.set_source_rgb(*(UserConfig[:mumble_basic_color] || [0,0,0]).map{ |c| c.to_f / 65536 })
    context.save{
      context.translate(icon_width + margin, (icon_width/2) - (plc.size[1] / Pango::SCALE / 2))
      context.show_pango_layout(plc) }
    @icon_ofst = ((plc.size[0] / Pango::SCALE + icon_width + margin*2).to_f / icon_width).ceil * icon_width
  end

  def put_voter(context)
    context.translate(@icon_ofst, 0)
    xpos = @icon_ofst
    @avatar_rect = []
    votes.each{ |user|
      left = xpos
      xpos += render_user(context, user)
      @avatar_rect << (left...xpos)
      break if width <= xpos } end

  def render_user(context, user)
    render_icon(context, user)
    icon_width
  end

  def render_icon(context, user)
    context.set_source_pixbuf(user_icon(user))
    context.paint
    context.translate(icon_width, 0)
  end

  def user_icon(user)
    @user_icon[user[:id]] ||= user.icon.load_pixbuf(width: icon_width, height: icon_height){ |pixbuf|
      @user_icon[user[:id]] = pixbuf
      helper.on_modify } end

  def pl_count(context = dummy_context)
    layout = context.create_pango_layout
    layout.wrap = Pango::WRAP_CHAR
    layout.font_description = Pango::FontDescription.new(UserConfig[:mumble_basic_font])
    layout.text = "#{get_vote_count}"
    layout
  end

  def get_vote_count
    votes.size
  end

end
