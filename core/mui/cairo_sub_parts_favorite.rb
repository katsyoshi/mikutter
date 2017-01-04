# -*- coding: utf-8 -*-

miquire :mui, 'sub_parts_voter'

require 'gtk3'
require 'cairo'

class Gdk::SubPartsFavorite < Gdk::SubPartsVoter
  register

  def get_vote_count
    [helper.message[:favorite_count] || 0, super].max
  end

  def get_default_votes
    helper.message.favorited_by
  end

  memoize def title_icon_model
    Skin.photo('unfav.png')
  end

  def name
    :favorited end

  Delayer.new{
    Plugin.create(:sub_parts_favorite) do
      onfavorite do |service, user, message|
        Gdk::MiraclePainter.findbymessage_d(message).next{ |mps|
          mps.deach{ |mp|
            if not mp.destroyed?
              mp.subparts.find{ |sp| sp.class == Gdk::SubPartsFavorite }.add(user) end } }
      end

      on_before_favorite do |service, user, message|
        Gdk::MiraclePainter.findbymessage_d(message).next{ |mps|
          mps.deach{ |mp|
            if not mp.destroyed?
              mp.subparts.find{ |sp| sp.class == Gdk::SubPartsFavorite }.add(user) end } }
      end

      on_fail_favorite do |service, user, message|
        Gdk::MiraclePainter.findbymessage_d(message).next{ |mps|
          mps.deach{ |mp|
            if not mp.destroyed?
              mp.subparts.find{ |sp| sp.class == Gdk::SubPartsFavorite }.delete(user) end } }
      end
    end
  }

end
