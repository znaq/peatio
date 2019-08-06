# encoding: UTF-8
# frozen_string_literal: true

describe RevenueShare, 'Validations' do

  subject { build(:transfer) }

  describe 'key' do
    it 'uniqueness' do
      existing_transfer = create(:transfer)
      subject.key = existing_transfer.key
      expect(subject.valid?).to be_falsey
      expect(subject).to include_ar_error(:key, /has already been taken/)
    end

    it 'presence' do
      subject.key = nil
      expect(subject.valid?).to be_falsey
      expect(subject).to include_ar_error(:key, /can't be blank/)
    end
  end

  describe 'kind' do
    it 'presence' do
      subject.kind = nil
      expect(subject.valid?).to be_falsey
      expect(subject).to include_ar_error(:kind, /can't be blank/)
    end
  end

  describe 'accounting equation' do
    context 'single asset operation' do
      subject { build(:transfer, assets: build_list(:asset, 5)) }

      it 'invalidates transfer' do
        expect(subject.valid?).to be_falsey
        expect(subject).to include_ar_error(:base, /invalidates accounting equation/)
      end
    end

    context 'different operations with invalid accounting sum' do
      subject do
        build(:transfer,
              assets: assets,
              liabilities: liabilities,
              revenues: revenues,
              expenses: expenses)
      end

      context 'with single currency' do
        let(:assets) { [build(:asset, credit: 1, currency_id: :btc)] }
        let(:liabilities) { [build(:liability, :with_member, credit: 5, currency_id: :btc)] }
        let(:revenues) { [build(:revenue, credit: 5, currency_id: :btc)] }
        let(:expenses) { [build(:expense, credit: 1, currency_id: :btc)] }

        it 'invalidates transfer' do
          expect(subject.valid?).to be_falsey
          expect(subject).to include_ar_error(:base, /invalidates accounting equation for btc/)
        end
      end

      context 'with different currencies' do
        let(:assets) { [build(:asset, credit: 1, currency_id: :btc)] }
        let(:liabilities) { [build(:liability, :with_member, credit: 5, currency_id: :eth)] }
        let(:revenues) { [build(:revenue, credit: 5, currency_id: :usd)] }
        let(:expenses) { [build(:expense, credit: 1, currency_id: :btc)] }

        it 'invalidates transfer' do
          expect(subject.valid?).to be_falsey
          expect(subject).to include_ar_error(:base, /invalidates accounting equation for btc, eth, usd/)
        end
      end

      context 'multiple operations per operation type' do
        # assets - liabilities = revenues - expenses
        #
        # BTC:
        # (10 + 15) - (9 + 12) = (3 + 5) - (1 + 3)
        # 25 - 21 = 8 - 4
        # BTC accounting is correct.
        let(:asset1) { build(:asset, credit: 10, currency_id: :btc) }
        let(:asset2) { build(:asset, credit: 15, currency_id: :btc) }

        let(:liability1) { build(:liability, :with_member, credit: 9, currency_id: :btc) }
        let(:liability2) { build(:liability, :with_member, credit: 12, currency_id: :btc) }

        let(:revenue1) { build(:revenue, credit: 3, currency_id: :btc) }
        let(:revenue2) { build(:revenue, credit: 5, currency_id: :btc) }

        let(:expense1) { build(:expense, credit: 1, currency_id: :btc) }
        let(:expense2) { build(:expense, credit: 3, currency_id: :btc) }

        # assets - liabilities = revenues - expenses
        #
        # USD:
        # (90 + 25) - (88 + 25) = (4 + 2) - (2 + 1)
        # 115 - 113 = 6 - 3
        # USD accounting is broken.
        let(:asset3) { build(:asset, credit: 90, currency_id: :usd) }
        let(:asset4) { build(:asset, credit: 25, currency_id: :usd) }

        let(:liability3) { build(:liability, :with_member, credit: 88, currency_id: :usd) }
        let(:liability4) { build(:liability, :with_member, credit: 25, currency_id: :usd) }

        let(:revenue3) { build(:revenue, credit: 4, currency_id: :usd) }
        let(:revenue4) { build(:revenue, credit: 2, currency_id: :usd) }

        let(:expense3) { build(:expense, credit: 2, currency_id: :usd) }
        let(:expense4) { build(:expense, credit: 1, currency_id: :usd) }

        let(:assets) { [asset1, asset2, asset3, asset4] }
        let(:liabilities) { [liability1, liability2, liability3, liability4] }
        let(:revenues) { [revenue1, revenue2, revenue3, revenue4] }
        let(:expenses) { [expense1, expense2, expense3, expense4] }

        it 'invalidates transfer' do
          expect(subject.valid?).to be_falsey
          expect(subject).to include_ar_error(:base, /invalidates accounting equation for usd/)
        end
      end
    end

    context 'valid accounting sum' do
      context 'with single currency' do
        # assets - liabilities = revenues - expenses
        #
        # BTC:
        # (30 + 45 - 12) - (9 + 12 - 2) = (28 + 20 - 2) - (1 + 4 - 3)
        # 63 - 19 = 46 - 2
        # BTC accounting is correct.
        let(:asset1) { build(:asset, credit: 10, currency_id: :btc) }
        let(:asset2) { build(:asset, credit: 15, currency_id: :btc) }
        let(:asset3) { build(:asset, :debit, debit: 12, currency_id: :btc) }

        let(:liability1) { build(:liability, :with_member, credit: 9, currency_id: :btc) }
        let(:liability2) { build(:liability, :with_member, credit: 12, currency_id: :btc) }
        let(:liability3) { build(:liability, :debit, :with_member, debit: 2, currency_id: :btc) }

        let(:revenue1) { build(:revenue, credit: 28, currency_id: :btc) }
        let(:revenue2) { build(:revenue, credit: 20, currency_id: :btc) }
        let(:revenue3) { build(:revenue, :debit, debit: 2, currency_id: :btc) }

        let(:expense1) { build(:expense, credit: 1, currency_id: :btc) }
        let(:expense2) { build(:expense, credit: 4, currency_id: :btc) }
        let(:expense3) { build(:expense, :debit, debit: 3, currency_id: :btc) }


        let(:assets) { [asset1, asset2, asset3] }
        let(:liabilities) { [liability1, liability2, liability3] }
        let(:revenues) { [revenue1, revenue2, revenue3] }
        let(:expenses) { [expense1, expense2, expense3] }

        it 'invalidates transfer' do
          expect(subject.save!).to be_truthy
        end
      end
    end
  end
end
