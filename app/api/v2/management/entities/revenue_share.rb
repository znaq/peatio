# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      module Entities
        STATES = %w[
          «disabled» – initial state.
          «active» – revenue share is active
        ].freeze

        class RevenueShare < Base
          expose(
            :id,
            documentation: {
              type: String,
              desc: 'Revenue share unique identifier.'
            }
          )
          expose(
            :member_uid,
            documentation: {
              type: String,
              desc: 'Member unique identifier.'
            }
          )
          expose(
            :parent_uid,
            documentation: {
              type: String,
              desc: 'Parent unique identifier.'
            }
          )
          expose(
            :percent,
            documentation: {
              type: BigDecimal,
              desc: 'Percentage of revenue share.'
            }
          )
          expose(
            :state,
            documentation: {
              type: String,
              desc: 'The revenue share state. ' + STATES.join(' ')
            }
          )
          expose(
            :created_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'Datetime of revenue share creation.'
            }
          )
        end
      end
    end
  end
end
