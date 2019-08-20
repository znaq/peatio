# enco  ding: UTF-8
# froz  en_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class Currency < API::V2::Entities::Currency
          unexpose(:id)
          unexpose(:explorer_address)
          unexpose(:explorer_transaction)

          expose(
            :code,
            documentation: {
              desc: 'Unique currency code.',
              type: String
            }
          )

          expose(
            :blockchain_key,
            documentation: {
                type: String,
                desc: 'Associated blockchain key which will perform transactions synchronization for currency.'
            },
            if: -> (currency){ currency.coin? }
          )

          expose(
            :min_collection_amount,
            documentation: {
              type: BigDecimal,
              desc: 'Minimal collection amount.'
            }
          )


          expose(
            :position,
            documentation: {
              type: Integer,
              desc: 'Currency position.'
            }
          )

          expose(
            :enabled,
            documentation: {
              type: String,
              desc: 'Currency display status (enabled/disabled).'
            }
          )

          expose(
            :options,
            documentation: {
              type: JSON,
              desc: 'Currency options.'
            },
            if: -> (currency){ currency.coin? }
          )

          expose(
            :created_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'Currency created time in iso8601 format.'
            }
          )

          expose(
            :updated_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'Currency updated time in iso8601 format.'
            }
          )
        end
      end
    end
  end
end
