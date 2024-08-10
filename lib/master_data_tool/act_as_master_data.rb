require 'active_support/concern'

module MasterDataTool
  module ActAsMasterData
    extend ActiveSupport::Concern

    class_methods do
      def master_data?
        true
      end
    end
  end
end
