# -*- coding: utf-8 -*-
require_relative 'error'
require_relative 'keep'
require_relative 'model/zombie'
require_relative 'service'

miquire :core, 'environment', 'configloader', 'userconfig'
miquire :lib, 'diva_hacks'

Plugin.create(:world) do

  world_struct = Struct.new(:slug, :name, :proc)

  defdsl :world_setting do |world_slug, world_name, &proc|
    filter_world_setting_list do |settings|
      [settings.merge(world_slug => world_struct.new(world_slug, world_name, proc))]
    end
  end

  # 登録済みアカウントを全て取得するのに使うフィルタ。
  # 登録されているWorld Modelをyielderに格納する。
  filter_worlds do |yielder|
    worlds.each do |world|
      yielder << world
    end
    [yielder]
  end

  # 新たなアカウント _new_ を追加する
  on_world_create do |new|
    register_world(new)
  end

  # アカウント _target_ が変更された時に呼ばれる
  on_world_modify do |target|
    modify_world(target)
  end

  # アカウント _target_ を削除する
  on_world_destroy do |target|
    destroy_world(target)
  end

  # すべてのWorld Modelを順番通りに含むArrayを返す。
  # 各要素は、アカウントの順番通りに格納されている。
  # 外部からこのメソッド相当のことをする場合は、 _worlds_ フィルタを利用すること。
  # ==== Return
  # [Array] アカウントModelを格納したArray
  def worlds
    if @worlds
      @worlds
    else
      atomic do
        load_world_ifn
      end
    end
  end

  # 新たなアカウントを登録する。
  # ==== Args
  # [new] 追加するアカウント(Diva::Model)
  def register_world(new)
    Plugin::World::Keep.account_register new.slug, new.to_hash.merge(provider: new.class.slug)
    @worlds = nil
    Plugin.call(:world_after_created, new)
    Plugin.call(:service_registered, new) # 互換性のため
  rescue Plugin::World::AlreadyExistError
    description = {
      new_world: new.title,
      duplicated_world: @worlds.find{|w| w.slug == new.slug }&.title,
      world_slug: new.slug }
    activity :system, _('既に登録されているアカウントと重複しているため、登録に失敗しました。'),
             description: _('登録しようとしたアカウント「%{new_world}」は、既に登録されている「%{duplicated_world}」と同じ識別子「%{world_slug}」を持っているため、登録に失敗しました。') % description
  end

  def modify_world(target)
    if Plugin::World::Keep.accounts.has_key?(target.slug.to_sym)
      Plugin::World::Keep.account_modify target.slug, target.to_hash.merge(provider: target.class.slug)
      @worlds = nil
    end
  end

  def destroy_world(target)
    Plugin::World::Keep.account_destroy target.slug
    @worlds = nil
    Plugin.call(:service_destroyed, target) # 互換性のため
  end

  def load_world_ifn
    @worlds ||= Plugin::World::Keep.accounts.map { |id, serialized|
      provider = Diva::Model(serialized[:provider])
      if provider
        provider.new(serialized)
      else
        Miquire::Plugin.load(serialized[:provider])
        provider = Diva::Model(serialized[:provider])
        if provider
          provider.new(serialized)
        else
          activity :system, _('アカウント「%{world}」のためのプラグインが読み込めなかったため、このアカウントの登録をmikutterから解除しました。') % {world: id},
                   description: _('アカウント「%{world}」に必要な%{plugin}プラグインが見つからなかったため、このアカウントの登録をmikutterから解除しました。') % {plugin: serialized[:provider], world: id}
          Plugin.call(:world_destroy, Plugin::World::Zombie.new(slug: id))
          nil
        end
      end
    }.compact.freeze
  end
end
