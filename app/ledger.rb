module ExpenseTracker
  RecordResult = Struct.new(:success?, :expense_id, :error_message)

  class Ledger
    def record(expense)

    end

    def expenses_on(date)
      # fill in on chapter 6
    end
  end
end
