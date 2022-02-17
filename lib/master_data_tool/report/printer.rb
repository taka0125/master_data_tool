# frozen_string_literal: true

module MasterDataTool
  module Report
    module Printer
      def print(message)
        raise NotImplementedError
      end
    end
  end
end
