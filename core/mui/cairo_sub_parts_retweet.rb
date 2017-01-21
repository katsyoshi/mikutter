# frozen_string_literal: true
# -*- coding: utf-8 -*-

miquire :mui, 'sub_parts_voter'

require 'gtk2'
require 'cairo'

class Gdk::SubPartsRetweet < Gdk::SubPartsVoter
  register

  def get_vote_count
    [helper.message[:retweet_count] || 0, super].max
  end

  def get_default_votes
    helper.message.retweeted_by
  end

  memoize def title_icon_model
    Skin.photo('retweet.png')
  end

  def name
    :retweeted end

  Plugin.create(:sub_parts_retweet) do
    on_retweet do |retweets|
      retweets.deach{ |retweet|
        Gdk::MiraclePainter.findbymessage_d(retweet.retweet_source(true)).next{ |mps|
          mps.deach{ |mp|
            if not mp.destroyed? and mp.subparts
              begin
                mp.subparts.find{ |sp| sp.class == Gdk::SubPartsRetweet }.add(retweet[:user])
                mp.on_modify
              rescue Gdk::MiraclePainter::DestroyedError
                nil end end } }.terminate("retweet error") } end

    on_retweet_destroyed do |source, user, retweet_id|
      Gdk::MiraclePainter.findbymessage_d(source).next{ |mps|
        mps.deach{ |mp|
            if not mp.destroyed? and mp.subparts
              begin
                mp.subparts.find{ |sp| sp.class == Gdk::SubPartsRetweet }.delete(user)
                mp.on_modify
              rescue Gdk::MiraclePainter::DestroyedError
                nil end end }.terminate("retweet destroy error")
      }
    end
  end

end


