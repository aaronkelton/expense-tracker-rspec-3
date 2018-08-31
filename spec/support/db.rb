RSpec.configure do |c|
  c.before(:suite) do
    Sequel.extension :migration
    Sequel::Migrator.run(DB, 'db/migrations')
    DB[:expenses].truncate
  end

  c.around(:example, :db) do |example|
    # either tag each example with :db that requires DB rollback fnality
    # or use the RSpec configure in spec_helper for global fnality
    DB.transaction(rollback: :always) { example.run }
  end
end
