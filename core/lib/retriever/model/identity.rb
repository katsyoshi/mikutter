# frozen_string_literal: true
# -*- coding: utf-8 -*-
=begin rdoc
Retrieverにこのmixinをincludeすると、findbyid()によってそのIDをもつインスタンスを得ることができる。
利用するclassは、idメソッドを実装している必要がある。
=end
module Retriever::Model::Identity
  module IdentityExtend
    # データソースを返す。
    # findbyidは、このデータソースに対して行われる
    def memory
      @memory ||= Retriever::Model::Memory.new(self) end

    # idキーが _id_ のインスタンスを返す。
    # ==== Args
    # [id] Integer|Enumerable 検索するIDか、IDを列挙するEnumerable
    # ==== Return
    # 次のいずれか
    # [nil] その条件で見つけられなかった場合
    # [Retriever] 見つかった場合
    # [Enumerable] _id_ にEnumerableを渡した場合。列挙される順番は、　_id_　の順番どおり。
    def findbyid(id, policy=Retriever::DataSource::USE_ALL)
      memory.findbyid(id, policy) end

    # :nodoc:
    def generate(args, policy=Retriever::DataSource::USE_ALL)
      return self.findbyid(args, policy) if not(args.is_a? Hash)
      result = self.findbyid(args[:id], policy)
      return result.merge(args) if result
      super(args)
    end

    # :nodoc:
    def new_ifnecessary(hash)
      type_strict hash => tcor(self, Hash)
      result_strict(self) do
        if hash.is_a?(self)
          hash
        elsif hash[:id] and hash[:id] != 0
          memory.findbyid(hash[:id].to_i, Retriever::DataSource::USE_LOCAL_ONLY) or super
        else
          super end end end

    # :nodoc:
    def store_datum(datum)
      memory.store_datum(datum) end
  end

  def self.included(klass)
    klass.extend(IdentityExtend)
  end

  memoize def hash
    self.id.hash ^ self.class.hash end
end
