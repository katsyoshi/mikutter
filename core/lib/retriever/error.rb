# frozen_string_literal: true
# -*- coding: utf-8 -*-
module Retriever
  class RetrieverError < StandardError; end

  class InvalidTypeError < RetrieverError; end

  class InvalidEntityError < RetrieverError; end

  # 実装してもしなくてもいいメソッドが実装されておらず、結果を得られない
  class NotImplementedError < RetrieverError; end

  # IDやURIなどの一意にリソースを特定する情報を使ってデータソースに問い合わせたが、
  # 対応する情報が見つからず、Modelを作成できない
  class ModelNotFoundError < RetrieverError; end

  # URIとして受け付けられない値を渡された
  class InvalidURIError < InvalidTypeError; end

end
