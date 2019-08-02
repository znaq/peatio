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
    context 'asset operations' do
      subject { build(:transfer, assets: build_list(:asset, 5)) }

      it 'invalidates transfer' do
        expect(subject.valid?).to be_falsey
        expect(subject).to include_ar_error(:base, /invalidates accounting equation/)
      end
    end

    context 'different operations with invalid accounting sum' do
      subject do
        build(:transfer,
              assets: [asset],
              liabilities: [liability],
              revenues: [revenue],
              expenses: [expense])
      end



      context 'with single currency' do
        let(:asset) { build(:asset, credit: 1, currency_id: :btc) }
        let(:liability) { build(:liability, :with_member, credit: 5, currency_id: :btc) }
        let(:revenue) { build(:revenue, credit: 5, currency_id: :btc) }
        let(:expense) { build(:expense, credit: 1, currency_id: :btc) }

        it 'invalidates transfer' do
          expect(subject.valid?).to be_falsey
          expect(subject).to include_ar_error(:base, /invalidates accounting equation for btc/)
        end
      end

      context 'with different currencies' do
        let(:asset) { build(:asset, credit: 1, currency_id: :btc) }
        let(:liability) { build(:liability, :with_member, credit: 5, currency_id: :eth) }
        let(:revenue) { build(:revenue, credit: 5, currency_id: :usd) }
        let(:expense) { build(:expense, credit: 1, currency_id: :btc) }

        it 'invalidates transfer' do
          expect(subject.valid?).to be_falsey
          expect(subject).to include_ar_error(:base, /invalidates accounting equation for btc, eth, usd/)
        end
      end
    end
  end

  describe 'key numerically' do
    it 'greater than 0' do
      existing_transfer = create(:transfer)
      subject.key = existing_transfer
      expect(subject.valid?).to be_falsey
      expect(subject).to include_ar_error(:percent, /must be greater than 0/)
    end

    describe 'less than or equal to' do
      it '100 if state is disabled' do
        subject.percent = 101
        subject.state = :disabled
        expect(subject.valid?).to be_falsey
        expect(subject).to include_ar_error(:percent, /must be less than or equal to 100/)
      end

      it '100 minus sum of active percents for member if active' do
        create(:revenue_share, member: subject.member, percent: 94.5)

        subject.percent = 6
        expect(subject.valid?).to be_falsey
        expect(subject).to include_ar_error(:percent, /must be less than or equal to 5.5/)

        subject.state = :disabled
        expect(subject.valid?).to be_truthy

        subject.state = :active
        subject.member = create(:member)
        expect(subject.valid?).to be_truthy
      end
    end
  end

  describe 'state inclusion' do
    context 'nil state' do
      it do
        subject.state = nil
        expect(subject.valid?).to be_falsey
        expect(subject).to include_ar_error(:state, /is not included in the list/)
      end
    end

    context 'invalid state' do
      it do
        subject.state = :invalid
        expect(subject.valid?).to be_falsey
        expect(subject).to include_ar_error(:state, /is not included in the list/)
      end
    end
  end
end
