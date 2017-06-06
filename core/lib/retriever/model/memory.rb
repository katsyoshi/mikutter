# -*- coding: utf-8 -*-
class Retriever::Model::Memory
  include Retriever::DataSource

  def initialize(klass=Retriever::Model)
    @storage = WeakStorage.new(Integer, klass) end

  def findbyid(id, policy)
    if id.is_a? Enumerable
      id.map{ |i| @storage[i] }
    else
      @storage[id] end
  end

  def store_datum(datum)
    @storage[datum.id] = datum
  end
end
