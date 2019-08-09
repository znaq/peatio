# encoding: UTF-8
# frozen_string_literal: true

class Transfer < ApplicationRecord
  # == Constants ============================================================

  # == Attributes ===========================================================

  # == Extensions ===========================================================

  # == Relationships ========================================================

  # Define has_many relation with Operations::{Asset,Expense,Liability,Revenue}.
  ::Operations::Account::TYPES.map(&:pluralize).each do |op_t|
    has_many op_t.to_sym,
             class_name: "::Operations::#{op_t.to_s.singularize.camelize}",
             as: :reference
  end

  # == Validations ==========================================================

  validates :key, uniqueness: true, presence: true
  validates :kind, presence: true
  validate :validate_accounting_equation

  after_create :update_legacy_balances

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  private

  def update_legacy_balances
    liabilities.where.not(member_id: nil).find_each do |l|
      member = Member.find(l.member_id)
      account = l.account
      legacy_account = member.accounts.find_by(currency: l.currency)

      if account.kind.main?
        if l.credit.nonzero?
          legacy_account.plus_funds(l.credit)
        else
          legacy_account.sub_funds(l.debit)
        end
      elsif account.kind.locked?
        if l.credit.nonzero?
          legacy_account.plus_funds(l.credit)
          legacy_account.lock_funds(l.credit)
        else
          legacy_account.unlock_ans_sub_funds(l.debit)
        end
      end
    end
  end

  # For validating Accounting Equation we use next formula:
  # Assets - Liabilities = Revenues - Expenses
  # Which is equal to:
  # Assets + Expenses - Liabilities - Revenues = 0
  def validate_accounting_equation
    balance_sheet = Hash.new(0)
    (assets + expenses).each do |op|
      balance_sheet[op.currency_id] += op.amount
    end
    (liabilities + revenues).each do |op|
      balance_sheet[op.currency_id] -= op.amount
    end

    balance_sheet.delete_if {|_k,v| v.zero? }

    unless balance_sheet.empty?
      errors.add(:base, "invalidates accounting equation for #{balance_sheet.keys.join(', ')}")
    end
  end
end

# == Schema Information
# Schema version: 20181226170925
#
# Table name: transfers
#
#  id         :integer          not null, primary key
#  key        :integer          not null
#  kind       :string(30)       not null
#  desc       :string(255)      default("")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_transfers_on_key   (key) UNIQUE
#  index_transfers_on_kind  (kind)
#
