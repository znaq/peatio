# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      module Helpers
        def set_ets_context!
          Raven.tags_context(
            peatio_version: Peatio::Application::VERSION
          ) if defined?(Raven)
        end
      end
    end
  end
end
