require_relative '../../../app/api'
require 'rack/test'

module ExpenseTracker
  RSpec.describe API do
    include Rack::Test::Methods

    def app
      API.new(ledger: ledger)
    end

    let(:ledger) { instance_double('ExpenseTracker::Ledger') }

    describe 'GET /expenses/:date' do
      context 'when expenses exist on the given date' do
        it 'returns the expense records as JSON' do
          date = '2017-06-12'
          allow(ledger).to receive(:expenses_on)
            .with(date)
            .and_return(['expense_1', 'expense_2'])

          get "/expenses/#{date}"
          parsed = JSON.parse(last_response.body)
          expect(parsed).to eq(['expense_1', 'expense_2'])
        end

        it 'responds with a 200 (OK)' do
          date = '2017-06-12'
          allow(ledger).to receive(:expenses_on)
            .with(date)
            .and_return(['expense_1', 'expense_2'])
          get "/expenses/#{date}"
          expect(last_response.status).to eq(200)
        end
      end

      context 'when there are no expenses on the given date' do
        before do
          allow(ledger).to receive(:expenses_on)
            .with('2017-06-12')
            .and_return([])
        end

        it 'returns an empty array as JSON' do
          get '/expenses/2017-06-12'

          parsed = JSON.parse(last_response.body)
          expect(parsed).to eq([])
        end

        it 'responds with a 200 (OK)' do
          get '/expenses/2017-06-12'
          expect(last_response.status).to eq(200)
        end
      end
    end

    describe 'POST /expenses' do
      context 'when the expense fails validation' do
        let(:expense) { { 'some' => 'data' } }
        before(:each) do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(false, 417, 'Expense incomplete'))
        end

        it 'returns an error message' do
          post '/expenses', JSON.generate(expense)

          get_last_parsed('error' => 'Expense incomplete')
        end

        it 'responds with a 422 (Unprocessable entity)' do
          post '/expenses', JSON.generate(expense)

          expect(last_response.status).to eq(422)
        end
      end

      context 'when the expense is successfully recorded' do
        let(:expense) { { 'some' => 'data' } }
        before(:each) do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(true, 417, nil))
        end


        it 'returns the expense id' do
          post '/expenses', JSON.generate(expense)

          get_last_parsed('expense_id' => 417)
        end

        it 'responds with a 200 (OK)' do
          post '/expenses', JSON.generate(expense)

          expect(last_response.status).to eq(200)
        end
      end

      def get_last_parsed(parsed_sample)
        parsed = JSON.parse(last_response.body)
        expect(parsed).to include(parsed_sample)
      end
    end
  end
end
